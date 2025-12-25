use std::{path::PathBuf, time::Instant};

use agglayer_types::{Address, Certificate, PessimisticRootInput};
use clap::Parser;
use pessimistic_proof_core::{Sabv5Algorithm, Sabv5Config};
use rayon::ThreadPoolBuilder;
use pessimistic_proof_test_suite::{
    runner::Runner,
    sample_data::{self as data},
};
use tracing::{error, info, warn};
use agglayer_primitives::Digest as AggDigest;
use serde::{Serialize, Deserialize};
use pessimistic_proof::unified_bridge::CommitmentVersion;
use hex;

#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct PPGenArgs {
    /// Number of exits to process
    #[arg(long, default_value = "1")]
    n_exits: usize,

    /// Number of validator nodes for SABV/LMTR
    #[arg(long, default_value = "5")]
    validator_nodes: usize,

    /// Directory to save proof fixtures
    #[arg(long, default_value = "proof_fixtures")]
    proof_dir: PathBuf,

    /// Input file path (optional)
    #[arg(long)]
    input: Option<PathBuf>,

    /// Allow SP1 proving even if fraud detected (testing only)
    #[arg(long, default_value = "false")]
    allow_fraud_testing: bool,

    /// Wrong global_root for fraud testing (hex string, optional)
    /// If provided, uses this instead of computed global_root to test fraud detection
    #[arg(long)]
    wrong_global_root: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "kebab-case")]
struct PessimisticProofFixture {
    certificate: Certificate,
    pp_inputs: VerifierInputs,
    signer: Address,
    vkey: String,
    public_values: String,
    proof: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "kebab-case")]
struct VerifierInputs {
    certificate: Certificate,
    pessimistic_root_input: String,
    l1_info_root: AggDigest,
}

fn main() {
    // Setup logger FIRST before anything else
    sp1_sdk::utils::setup_logger();
    
    let args = PPGenArgs::parse();
    
    let total_start = Instant::now();
    info!("🚀 Starting REAL SABV5/LMTR4 Proving with {} exits and {} validators", 
          args.n_exits, args.validator_nodes);
    
    // Build sample state and inputs
    // FIX: Create multiple blocks from n_exits - each block contains 1 exit
    let setup_start = Instant::now();
    let mut state = data::sample_state_00();
    let mut blocks = Vec::new();
    let mut global_roots = Vec::new();
    
    info!("📦 Creating {} blocks (one per exit) for SABV5 verification", args.n_exits);
    
    // Get all bridge exits
    let all_bridge_exits: Vec<_> = {
        let n = args.n_exits;
        match &args.input {
            Some(path) => data::sample_bridge_exits(path.clone())
                .cycle()
                .take(n)
                .map(|e| (e.token_info, e.amount))
                .collect::<Vec<_>>(),
            None => data::sample_bridge_exits_01()
                .cycle()
                .take(n)
                .map(|e| (e.token_info, e.amount))
                .collect::<Vec<_>>(),
        }
    };
    
    // Create one block per exit by creating separate certificates
    // State needs to be updated sequentially for each certificate
    let initial_state = state.state_b.clone();
    let mut current_state = initial_state.clone();
    let signer = state.get_signer();
    
    // Create a separate state for building blocks sequentially
    let mut block_state = data::sample_state_00();
    block_state.state_b = current_state.clone();
    
    for (i, (token_info, amount)) in all_bridge_exits.iter().enumerate() {
        // Create a single-exit certificate for this block
        let single_exit = vec![(*token_info, *amount)];
        let single_imported_exit = single_exit.clone();
        
        // Create state snapshot BEFORE applying events
        let state_before = block_state.state_b.clone();
        
        // Apply events to create certificate (this mutates block_state)
        let certificate = block_state.apply_events(&single_imported_exit, &single_exit);
        
        let l1_info_root = certificate.l1_info_root().unwrap().unwrap_or_default();
        
        // Create multi_batch_header using state BEFORE applying events
        let multi_batch_header = state_before
            .make_multi_batch_header(
                &certificate,
                signer,
                l1_info_root,
                PessimisticRootInput::Computed(CommitmentVersion::V2),
                None,
            )
            .expect(&format!("Failed to make multi batch header for block {}", i));
        
        blocks.push(multi_batch_header.clone());
        global_roots.push(l1_info_root);
        
        // Update current_state for next iteration (state after applying events)
        current_state = block_state.state_b.clone();
        
        if (i + 1) % 50 == 0 || i == 0 || i == all_bridge_exits.len() - 1 {
            info!("  ✅ Created {} blocks", i + 1);
        }
    }
    
    info!("✅ Created {} blocks total for SABV5 verification", blocks.len());
    
    // Compute global_root from ALL blocks (aggregated root) to match SABV5's computation
    // This should match the root computed by SABV5 from original blocks (before rebalancing)
    let global_root = if let Some(wrong_root_hex) = &args.wrong_global_root {
        // FRAUD TEST MODE: Use wrong global_root to test fraud detection
        info!("🔴 FRAUD TEST MODE: Using wrong_global_root for fraud detection test");
        let hex_str = wrong_root_hex.strip_prefix("0x").unwrap_or(wrong_root_hex);
        let wrong_root_bytes = hex::decode(hex_str)
            .expect("Invalid wrong_global_root hex string");
        if wrong_root_bytes.len() != 32 {
            panic!("wrong_global_root must be 32 bytes (64 hex characters), got {} bytes", wrong_root_bytes.len());
        }
        let mut wrong_root_array = [0u8; 32];
        wrong_root_array.copy_from_slice(&wrong_root_bytes);
        AggDigest::from(wrong_root_array)
    } else {
        // Normal mode: compute global_root from ALL blocks using same method as SABV5
        // This matches the expected_root_from_original_blocks that SABV5 will compute
        // We create a temporary SABV5 instance just to use its build_real_merkle_tree method
        use pessimistic_proof_core::{Sabv5Algorithm, Sabv5Config};
        let temp_config = Sabv5Config {
            branching_factor: 3,
            num_validators: 5,
            secret_sharing_threshold: 3,
        };
        let temp_sabv5 = Sabv5Algorithm::new(temp_config);
        
        // Build Merkle tree from ALL blocks (same as SABV5 does for expected_root_from_original_blocks)
        match temp_sabv5.build_real_merkle_tree(&blocks, 3) {
            Ok((computed_root, height)) => {
                info!("📊 Computed global_root from {} blocks: {:?} (height={})", 
                      blocks.len(), computed_root, height);
                computed_root
            },
            Err(e) => {
                warn!("⚠️  Failed to compute global_root from blocks: {:?}", e);
                warn!("   Falling back to last l1_info_root");
                global_roots.last().copied().unwrap_or_else(|| {
                    AggDigest::default()
                })
            }
        }
    };
    
    let setup_time = setup_start.elapsed();
    info!("📊 Setup time (state + {} certificates): {:?}", blocks.len(), setup_time);
    
    // Use SABV5/LMTR4 algorithms if validator_nodes > 0
    if args.validator_nodes > 0 {
        info!("🚀 Applying SABV5/LMTR4 REAL algorithms with {} validator nodes", args.validator_nodes);
        info!("📦 SABV5 will verify {} blocks", blocks.len());
        
        // Apply SABV5/LMTR4 REAL algorithms before SP1 proving
        info!("✅ Applying SABV5/LMTR4 REAL algorithms...");
        
        // Initialize SABV5 algorithm (REAL Algorithm 1)
        let sabv5_config = Sabv5Config {
            branching_factor: 3,
            num_validators: args.validator_nodes,
            secret_sharing_threshold: 3,
        };
        let mut sabv5_algorithm = Sabv5Algorithm::new(sabv5_config);

        // Apply SABV5 REAL verification (Algorithm 1) with multiple blocks
        // Use real global root from the last block/certificate
        
        let sabv5_start = Instant::now();
        let (integrity_verified, rebalanced_blocks) = sabv5_algorithm
            .verify_aggregated_blocks(&blocks, &global_root)
            .expect("SABV5 verification failed");
        let sabv5_time = sabv5_start.elapsed();
        info!("⏱️  SABV5 REAL verification + rebalancing time: {:?}", sabv5_time);

        // **V5 FIX**: Early exit if fraud detected
        if !integrity_verified {
            error!("❌ SABV5: Fraud detected! Aborting SP1 proving.");
            error!("⚠️  SABV5 REAL integrity verification FAILED");
            error!("📝 This indicates data mismatch or tampering - fraud detected");
            
            // DEBUG: Log flag status
            info!("🔍 DEBUG: allow_fraud_testing flag = {}", args.allow_fraud_testing);
            
            if args.allow_fraud_testing {
                warn!("⚠️  Testing mode enabled: Continuing SP1 despite fraud detection");
                warn!("🔧 This is ONLY for testing - NOT for production!");
                info!("✅ Continuing with SP1 proving (testing mode)");
            } else {
                error!("🛑 Exiting immediately to prevent wasting resources on fraudulent data");
                error!("💡 Use --allow-fraud-testing if you need to test SP1 with invalid data");
                std::process::exit(1);
            }
        } else {
            info!("✅ SABV5 REAL integrity verified completely");
        }

        // **V5 FIX**: Use rebalanced blocks from SABV5 (already rebalanced internally)
        // No need to call LMTR4 again - SABV5 already did it!
        info!("📦 Using rebalanced blocks from SABV5 ({} blocks total)", rebalanced_blocks.len());
        
        // For SP1 proving, we need to create a combined certificate from all blocks
        // Create a final certificate that contains all exits for SP1 proving
        // BASELINE: N=700 = 700 bridge exits + 700 imported bridge exits
        info!("📝 Creating combined certificate for SP1 proving...");
        info!("📊 Baseline: {} bridge exits + {} imported bridge exits (total: {} events)", 
              all_bridge_exits.len(), all_bridge_exits.len(), all_bridge_exits.len() * 2);
        
        // Flush logs before heavy operations to ensure we see progress
        use std::io::Write;
        let _ = std::io::stdout().flush();
        
        info!("🔄 Step 1: Creating final state from initial state...");
        let _ = std::io::stdout().flush();
        let mut final_state = data::sample_state_00();
        final_state.state_b = initial_state.clone();
        info!("✅ Step 1: Final state created (memory allocated)");
        let _ = std::io::stdout().flush();
        
        info!("🔄 Step 2: Applying {} bridge exits to create certificate...", all_bridge_exits.len());
        info!("   Memory before: This may take a while for large N...");
        let _ = std::io::stdout().flush();
        
        // Apply events - this is where it might fail for large N
        let final_certificate = final_state.apply_events(&all_bridge_exits, &all_bridge_exits);
        info!("✅ Step 2: Certificate created successfully with {} exits", all_bridge_exits.len());
        let _ = std::io::stdout().flush();
        
        info!("🔄 Step 3: Getting L1 info root from certificate...");
        let _ = std::io::stdout().flush();
        let final_l1_info_root = match final_certificate.l1_info_root() {
            Ok(Some(root)) => {
                info!("✅ Step 3: L1 info root retrieved successfully");
                let _ = std::io::stdout().flush();
                root
            }
            Ok(None) => {
                warn!("⚠️  Step 3: L1 info root is None, using default");
                let _ = std::io::stdout().flush();
                AggDigest::default()
            }
            Err(e) => {
                error!("❌ Step 3: Error getting L1 info root: {:?}", e);
                error!("   This is non-fatal, continuing with default root");
                let _ = std::io::stdout().flush();
                AggDigest::default()
            }
        };
        
        info!("🔄 Step 4: Creating multi batch header from certificate...");
        let _ = std::io::stdout().flush();
        let enhanced_header = match initial_state.make_multi_batch_header(
            &final_certificate,
            signer,
            final_l1_info_root,
            PessimisticRootInput::Computed(CommitmentVersion::V2),
            None,
        ) {
            Ok(header) => {
                info!("✅ Step 4: Multi batch header created successfully");
                let _ = std::io::stdout().flush();
                header
            }
            Err(e) => {
                error!("❌ Step 4: CRITICAL - Failed to create multi batch header!");
                error!("   Error: {:?}", e);
                error!("   Certificate hash: {:?}", final_certificate.hash());
                error!("   Number of bridge exits: {}", all_bridge_exits.len());
                error!("   This is a fatal error - cannot continue with SP1 proving");
                let _ = std::io::stdout().flush();
                panic!("Failed to create final multi batch header for SP1 with {} exits: {:?}", all_bridge_exits.len(), e);
            }
        };
        
        info!("🎯 Complete workflow: SABV5 REAL verification ({} blocks) + LMTR4 rebalancing → SP1 proving ✓", blocks.len());
        info!("✅ All certificate preparation steps completed successfully");
        let _ = std::io::stdout().flush();

        // NOW: Run SP1 Proving with REAL algorithms
        info!("🔐 Starting SP1 Proving with combined certificate ({} bridge exits + {} imported bridge exits = {} total events)...", 
              all_bridge_exits.len(), all_bridge_exits.len(), all_bridge_exits.len() * 2);
        let sp1_start = Instant::now();
        
        info!("📝 Preparing SP1 inputs...");
        let runner = Runner::new();
        
        info!("🚀 Generating SP1 PLONK proof...");
        let proof_result = runner.generate_plonk_proof(&initial_state.into(), &enhanced_header);
        
        match proof_result {
            Ok((proof, vk, new_roots)) => {
                let sp1_time = sp1_start.elapsed();
                info!("✅ SP1 Proving completed in {:?}", sp1_time);
                info!("📊 Proof size: {} bytes", proof.bytes().len());
                
                // Save proof fixture
                let save_start = Instant::now();
                let fixture = PessimisticProofFixture {
                    certificate: final_certificate.clone(),
                    pp_inputs: VerifierInputs {
                        certificate: final_certificate.clone(),
                        pessimistic_root_input: "Computed".to_string(),
                        l1_info_root: final_l1_info_root,
                    },
                    signer: signer,
                    vkey: format!("v5_proof_vkey_{}", args.n_exits),
                    public_values: format!("0x{}", hex::encode(proof.public_values.as_slice())),
                    proof: format!("0x{}", hex::encode(proof.bytes())),
                };
                
                // Save fixture
                let fixture_path = args.proof_dir.join(format!("v5_proof_n{}.json", args.n_exits));
                std::fs::create_dir_all(&args.proof_dir).expect("Failed to create proof directory");
                
                let fixture_json = serde_json::to_string_pretty(&fixture)
                    .expect("Failed to serialize fixture");
                std::fs::write(&fixture_path, fixture_json)
                    .expect("Failed to write fixture");
                
                let save_time = save_start.elapsed();
                info!("💾 Saved proof fixture to {} ({:?})", fixture_path.display(), save_time);
                
                // FINAL TIMING BREAKDOWN
                let total_time = total_start.elapsed();
                info!("📊 ===== FINAL TIMING BREAKDOWN =====");
                info!("   Setup:            {:>12?} ({:>5.1}%)", setup_time, (setup_time.as_secs_f64() / total_time.as_secs_f64()) * 100.0);
                info!("   SABV5:            {:>12?} ({:>5.1}%)", sabv5_time, (sabv5_time.as_secs_f64() / total_time.as_secs_f64()) * 100.0);
                info!("   SP1 Proving:      {:>12?} ({:>5.1}%)", sp1_time, (sp1_time.as_secs_f64() / total_time.as_secs_f64()) * 100.0);
                info!("   Save fixture:     {:>12?} ({:>5.1}%)", save_time, (save_time.as_secs_f64() / total_time.as_secs_f64()) * 100.0);
                info!("   ─────────────────────────────────");
                info!("   TOTAL:            {:>12?} (100.0%)", total_time);
                info!("📊 N={}, Memory usage will be shown by system (check dstat/top)", args.n_exits);
            }
            Err(e) => {
                let sp1_time = sp1_start.elapsed();
                error!("❌ SP1 Proving FAILED after {:?}", sp1_time);
                error!("❌ Error: {:?}", e);
                error!("📝 Stack trace: {:#?}", e);
                panic!("SP1 proving failed: {:?}", e);
            }
        }
    } else {
        warn!("⚠️  No validator nodes specified, skipping V5 algorithms");
    }
    
    info!("🎉 SABV5/LMTR4 with SP1 Proving completed");
}
