use std::{path::PathBuf, time::Instant};

use agglayer_primitives::Digest as AggDigest;
use agglayer_types::{Address, Certificate, NetworkId, PessimisticRootInput};
use clap::Parser;
use pessimistic_proof::keccak::Keccak256Hasher;
use pessimistic_proof::{unified_bridge::CommitmentVersion, PessimisticProofOutput};
use pessimistic_proof_core::{LmtrAlgorithm, LmtrConfig, SabvAlgorithm, SabvConfig};
use pessimistic_proof_test_suite::{
    runner::Runner,
    sample_data::{self as data},
};
use serde::{Deserialize, Serialize};
use sp1_sdk::{utils::setup_logger, HashableKey};
use tracing::{info, warn};

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
pub struct VerifierInputs {
    pub prev_local_exit_root: String,
    pub prev_pessimistic_root: String,
    pub l1_info_root: String,
    pub origin_network: NetworkId,
    pub aggchain_hash: String,
    pub new_local_exit_root: String,
    pub new_pessimistic_root: String,
}

impl From<PessimisticProofOutput> for VerifierInputs {
    fn from(v: PessimisticProofOutput) -> Self {
        Self {
            prev_local_exit_root: format!("0x{}", hex::encode(v.prev_local_exit_root)),
            prev_pessimistic_root: format!("0x{}", hex::encode(v.prev_pessimistic_root)),
            l1_info_root: format!("0x{}", hex::encode(v.l1_info_root)),
            origin_network: v.origin_network,
            aggchain_hash: format!("0x{}", hex::encode(v.aggchain_hash)),
            new_local_exit_root: format!("0x{}", hex::encode(v.new_local_exit_root)),
            new_pessimistic_root: format!("0x{}", hex::encode(v.new_pessimistic_root)),
        }
    }
}

fn main() {
    setup_logger();

    let args = PPGenArgs::parse();

    info!("🚀 Starting SABV/LMTR enhanced SP1 proving...");
    info!(
        "📊 Configuration: {} exits, {} validator nodes",
        args.n_exits, args.validator_nodes
    );

    let start = Instant::now();

    // Build sample state and inputs (same as baseline binary)
    let mut state = data::sample_state_00();
    let old_state = state.state_b.clone();

    let bridge_exits = {
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
    let imported_bridge_exits = bridge_exits.clone();

    let certificate = state.apply_events(&imported_bridge_exits, &bridge_exits);

    let l1_info_root = certificate.l1_info_root().unwrap().unwrap_or_default();
    let multi_batch_header = old_state
        .make_multi_batch_header(
            &certificate,
            state.get_signer(),
            l1_info_root,
            PessimisticRootInput::Computed(CommitmentVersion::V2),
            None,
        )
        .expect("Failed to make multi batch header");

    // Use SABV/LMTR enhanced proving if validator_nodes > 0
    if args.validator_nodes > 0 {
        info!(
            "🚀 Applying SABV/LMTR algorithms with {} validator nodes",
            args.validator_nodes
        );
        let validator_nodes: Vec<usize> = (0..args.validator_nodes).collect();

        // Apply SABV/LMTR algorithms before SP1 proving
        info!("✅ Applying SABV/LMTR algorithms...");

        // Initialize SABV algorithm
        let num_validators = validator_nodes.len();
        let secret_sharing_threshold = ((2 * num_validators) / 3) + 1; // 2f+1 threshold
        let sabv_config = SabvConfig {
            batch_size: 500,
            branching_factor: 30,
            num_validators,
            secret_sharing_threshold,
        };
        let sabv_algorithm = SabvAlgorithm::new(sabv_config.clone());

        // Initialize LMTR algorithm
        let lmtr_config = LmtrConfig {
            branching_factor: 30,
            max_height: 10,
            verbose: false,
        };
        let lmtr_algorithm = LmtrAlgorithm::new(lmtr_config);

        // Apply SABV verification
        let blocks = vec![multi_batch_header.clone()];
        // Use real global root from the certificate: l1_info_root is the declared digest
        let global_root: AggDigest = l1_info_root;

        let integrity_verified = sabv_algorithm
            .verify_aggregated_blocks(&blocks, &validator_nodes, &global_root)
            .expect("SABV verification failed");

        if !integrity_verified {
            panic!(
                "SABV integrity verification failed (n={}, t={})",
                num_validators, secret_sharing_threshold
            );
        }

        // Apply LMTR rebalancing
        let target_height = 3;
        let rebalanced_set = lmtr_algorithm
            .rebalance_blocks(&blocks, target_height, sabv_config.branching_factor)
            .expect("LMTR rebalancing failed");

        if rebalanced_set.needs_rebalancing {
            panic!(
                "LMTR indicates rebalancing still needed; aborting proving to enforce correctness"
            );
        }

        // Choose enhanced header (if LMTR produced an optimized header), otherwise fallback to original
        let enhanced_header = rebalanced_set
            .optimized_blocks
            .get(0)
            .cloned()
            .unwrap_or_else(|| multi_batch_header.clone());

        info!(
            "✅ SABV/LMTR algorithms applied, now running REAL SP1 proving with enhanced header..."
        );

        // Now run REAL SP1 proving
        let (proof, vk, new_roots) = Runner::new()
            .generate_plonk_proof(&old_state.into(), &enhanced_header)
            .expect("SABV/LMTR enhanced SP1 proving failed");

        let duration = start.elapsed();
        info!(
            "✅ Successfully generated SABV/LMTR enhanced SP1 proof in {:?}",
            duration
        );

        // Use REAL SP1 results
        let vkey = vk.bytes32().to_string();
        let fixture = PessimisticProofFixture {
            certificate,
            pp_inputs: new_roots.into(),
            signer: state.get_signer(),
            vkey: vkey.clone(),
            public_values: format!("0x{}", hex::encode(proof.public_values.as_slice())),
            proof: format!("0x{}", hex::encode(proof.bytes())),
        };

        // Save proof fixture
        let proof_dir = &args.proof_dir;
        std::fs::create_dir_all(proof_dir).expect("Failed to create proof directory");

        let fixture_path = proof_dir.join(format!("sabv_lmtr_proof_{}exits.json", args.n_exits));
        let fixture_json =
            serde_json::to_string_pretty(&fixture).expect("Failed to serialize proof fixture");
        std::fs::write(&fixture_path, fixture_json).expect("Failed to write proof fixture");

        info!("💾 Proof saved to: {:?}", fixture_path);
        info!("📊 Proof size: {} bytes", proof.bytes().len());
        info!("🎯 SABV/LMTR enhanced SP1 proving completed successfully!");
    } else {
        warn!("⚠️ No validator nodes specified, falling back to standard proving");

        let (proof, vk, new_roots) = Runner::new()
            .generate_plonk_proof(&old_state.into(), &multi_batch_header)
            .expect("Standard SP1 proving failed");

        let duration = start.elapsed();
        info!("✅ Standard SP1 proof generated in {:?}", duration);

        let vkey = vk.bytes32().to_string();
        let fixture = PessimisticProofFixture {
            certificate,
            pp_inputs: new_roots.into(),
            signer: state.get_signer(),
            vkey: vkey.clone(),
            public_values: format!("0x{}", hex::encode(proof.public_values.as_slice())),
            proof: format!("0x{}", hex::encode(proof.bytes())),
        };

        let proof_dir = &args.proof_dir;
        std::fs::create_dir_all(proof_dir).expect("Failed to create proof directory");

        let fixture_path = proof_dir.join(format!("standard_proof_{}exits.json", args.n_exits));
        let fixture_json =
            serde_json::to_string_pretty(&fixture).expect("Failed to serialize proof fixture");
        std::fs::write(&fixture_path, fixture_json).expect("Failed to write proof fixture");

        info!("💾 Standard proof saved to: {:?}", fixture_path);
    }
}
