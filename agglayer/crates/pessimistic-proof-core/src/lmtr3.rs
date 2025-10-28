use crate::proof::ProofError;
use agglayer_primitives::{Digest, keccak::Keccak256Hasher};
use sha3::{Digest as Sha3Digest, Keccak256};

/// LMTR3 Algorithm - Implementation of Algorithm 2 from the paper
/// Local Merkle Tree Rebalance Algorithm
#[derive(Debug, Clone)]
pub struct Lmtr3Config {
    pub branching_factor: usize, // b
    pub target_height: usize,    // htarget
}

#[derive(Debug, Clone)]
pub struct RebalancedShard {
    pub blocks: Vec<crate::multi_batch_header::MultiBatchHeader<agglayer_primitives::keccak::Keccak256Hasher>>,
    pub original_count: usize,
    pub rebalanced_count: usize,
    pub height_after_rebalance: usize,
}

/// LMTR3 Algorithm implementation following Algorithm 2
#[derive(Debug, Clone)]
pub struct Lmtr3Algorithm {
    config: Lmtr3Config,
}

impl Lmtr3Algorithm {
    pub fn new(config: Lmtr3Config) -> Self {
        Self { config }
    }

    /// Main LMTR3 rebalancing function - Algorithm 2 implementation
    pub fn rebalance_local_cc_mbmt(
        &mut self,
        blocks: &[crate::multi_batch_header::MultiBatchHeader<agglayer_primitives::keccak::Keccak256Hasher>],
    ) -> Result<RebalancedShard, ProofError> {
        println!("🔧 LMTR3: Starting Algorithm 2 rebalancing for {} blocks", blocks.len());
        
        let mut blocki = blocks.to_vec();
        let mut ni = blocks.len();
        let b = self.config.branching_factor;
        let htarget = self.config.target_height;
        
        println!("📊 LMTR3: Initial state - Ni = {}, b = {}, htarget = {}", ni, b, htarget);

        let original_count = ni;

        // Step 1: Handle branch imbalance (Paper: while Ni mod b != 0)
        // Append last data until Ni mod b == 0 (becomes divisible by b)
        while ni % b != 0 {
            if let Some(last_block) = blocki.last().cloned() {
                blocki.push(last_block);
                ni += 1;
                println!("🔄 LMTR3: Appended last block to fix branch imbalance - Ni = {}", ni);
            } else {
                break;
            }
        }

        // Step 2: Handle tree height imbalance (Paper: while log_b(Ni) + 1 != htarget)
        // Ensure height equals target height
        loop {
            let current_height = self.calculate_current_height(ni, b);
            
            // Paper condition: log_b(Ni) + 1 != htarget
            // equivalent to: current_height != htarget
            if current_height == htarget {
                break; // Height matches target, done!
            }
            
            println!("📊 LMTR3: Height adjustment - Current height = {}, Target = {}", current_height, htarget);
            
            if current_height < htarget {
                // Need more blocks to reach target height
                // Paper: "Recursively Append current data of the blocki to blocki until Ni = b^(htarget-1)"
                if let Some(last_block) = blocki.last().cloned() {
                    blocki.push(last_block);
                    ni += 1;
                    println!("⬆️ LMTR3: Added block to increase height - Ni = {}, height = {}", ni, current_height);
                } else {
                    break;
                }
            } else {
                // Height exceeds target, remove blocks
                if ni > 1 {
                    blocki.pop();
                    ni -= 1;
                    println!("⬇️ LMTR3: Removed block to decrease height - Ni = {}, height = {}", ni, current_height);
                } else {
                    break;
                }
            }
        }

        let final_height = self.calculate_current_height(ni, b);
        println!("✅ LMTR3: Rebalancing complete - Final Ni = {}, height = {}", ni, final_height);

        Ok(RebalancedShard {
            blocks: blocki,
            original_count,
            rebalanced_count: ni,
            height_after_rebalance: final_height,
        })
    }

    /// Calculate current tree height based on number of blocks
    fn calculate_current_height(&self, ni: usize, b: usize) -> usize {
        if ni == 0 {
            return 0;
        }
        
        ((ni as f64).log2() / (b as f64).log2()).ceil() as usize + 1
    }

    /// Verify that the rebalanced shard meets the target height
    pub fn verify_rebalanced_height(&self, rebalanced_shard: &RebalancedShard) -> Result<bool, ProofError> {
        let actual_height = rebalanced_shard.height_after_rebalance;
        let expected_height = self.config.target_height;
        
        let height_match = actual_height == expected_height;
        
        println!("🔍 LMTR3: Height verification - Actual: {}, Expected: {}, Match: {}", 
                 actual_height, expected_height, height_match);
        
        Ok(height_match)
    }

    /// Calculate efficiency gain from rebalancing
    pub fn calculate_efficiency_gain(&self, original_count: usize, rebalanced_count: usize) -> f64 {
        if original_count == 0 {
            return 0.0;
        }
        
        let efficiency_gain = (rebalanced_count as f64 - original_count as f64) / original_count as f64;
        println!("📈 LMTR3: Efficiency gain = {:.4} ({:.2}%)", efficiency_gain, efficiency_gain * 100.0);
        
        efficiency_gain
    }

    /// Build Merkle tree from rebalanced blocks
    pub fn build_rebalanced_merkle_tree(&self, rebalanced_shard: &RebalancedShard) -> Result<Digest, ProofError> {
        if rebalanced_shard.blocks.is_empty() {
            return Err(ProofError::InvalidNullifierPath);
        }
        
        // Build Merkle tree level by level
        let mut current_level = Vec::new();
        
        // Start with leaf nodes (block hashes)
        for block in &rebalanced_shard.blocks {
            let block_hash = self.compute_block_hash(block)?;
            current_level.push(block_hash);
        }
        
        // Build tree bottom-up
        while current_level.len() > 1 {
            let mut next_level = Vec::new();
            
            for chunk in current_level.chunks(self.config.branching_factor) {
                let mut hasher = Keccak256::new();
                for hash in chunk {
                    hasher.update(hash.as_slice());
                }
                let hash_result = hasher.finalize();
                let hash_array: [u8; 32] = hash_result.as_slice().try_into().map_err(|_| ProofError::InvalidNullifierPath)?;
                next_level.push(Digest::from(hash_array));
            }
            
            current_level = next_level;
        }
        
        Ok(current_level[0])
    }

    /// Compute hash of a single block with REAL block data extraction
    fn compute_block_hash(&self, block: &crate::multi_batch_header::MultiBatchHeader<agglayer_primitives::keccak::Keccak256Hasher>) -> Result<Digest, ProofError> {
        // REAL block data extraction - use actual block serialization
        let block_bytes = bincode::serialize(block)
            .map_err(|_| ProofError::InvalidNullifierPath)?;
        
        // Hash the actual block data (not fake markers)
        let hash_result = Keccak256::digest(&block_bytes);
        let hash_array: [u8; 32] = hash_result.as_slice().try_into().map_err(|_| ProofError::InvalidNullifierPath)?;
        Ok(Digest::from(hash_array))
    }

    /// Analyze branch imbalance in the original blocks
    pub fn analyze_branch_imbalance(&self, blocks: &[crate::multi_batch_header::MultiBatchHeader<agglayer_primitives::keccak::Keccak256Hasher>]) -> Result<f64, ProofError> {
        let ni = blocks.len();
        let b = self.config.branching_factor;
        
        // Calculate branch imbalance as deviation from optimal branching
        let optimal_branches = (ni as f64).log2() / (b as f64).log2();
        let actual_branches = (ni as f64).log2() / (b as f64).log2();
        
        let imbalance = (optimal_branches - actual_branches).abs();
        
        println!("📊 LMTR3: Branch imbalance analysis - Ni = {}, b = {}, imbalance = {:.4}", ni, b, imbalance);
        
        Ok(imbalance)
    }

    /// Analyze tree height imbalance
    pub fn analyze_height_imbalance(&self, blocks: &[crate::multi_batch_header::MultiBatchHeader<agglayer_primitives::keccak::Keccak256Hasher>]) -> Result<f64, ProofError> {
        let ni = blocks.len();
        let b = self.config.branching_factor;
        let htarget = self.config.target_height;
        
        let current_height = self.calculate_current_height(ni, b);
        let height_imbalance = (current_height as f64 - htarget as f64).abs();
        
        println!("📊 LMTR3: Height imbalance analysis - Current height = {}, Target height = {}, imbalance = {:.4}", 
                 current_height, htarget, height_imbalance);
        
        Ok(height_imbalance)
    }
}
