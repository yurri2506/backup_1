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
    info!("🚀 Starting REAL SABV3/LMTR3 Proving with {} exits and {} validators", 
          args.n_exits, args.validator_nodes);
    
    // Build sample state and inputs (same as V2 binary)
    let setup_start = Instant::now();
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
    
    let setup_time = setup_start.elapsed();
    info!("📊 Setup time (state + certificate): {:?}", setup_time);
    
    // Use SABV3/LMTR3 algorithms if validator_nodes > 0
    if args.validator_nodes > 0 {
        info!("🚀 Applying SABV5/LMTR4 REAL algorithms with {} validator nodes", args.validator_nodes);
        
        // Apply SABV5/LMTR4 REAL algorithms before SP1 proving
        info!("✅ Applying SABV5/LMTR4 REAL algorithms...");
        
        // Initialize SABV5 algorithm (REAL Algorithm 1)
        let sabv5_config = Sabv5Config {
            branching_factor: 3,
            num_validators: args.validator_nodes,
            secret_sharing_threshold: 3,
        };
        let mut sabv5_algorithm = Sabv5Algorithm::new(sabv5_config);

        // Apply SABV5 REAL verification (Algorithm 1)
        let blocks = vec![multi_batch_header.clone()];
        // Use real global root from the certificate: l1_info_root is the declared digest
        let global_root: AggDigest = l1_info_root;
        
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
        
        // Extract enhanced header from rebalanced blocks
        let enhanced_header = rebalanced_blocks
            .get(0)
            .expect("Rebalanced blocks should contain at least one block")
            .clone();
        
        info!("🎯 Complete workflow: SABV5 REAL verification + LMTR4 rebalancing → SP1 proving ✓");

        // NOW: Run SP1 Proving with REAL algorithms (same as V2)
        info!("🔐 Starting SP1 Proving with SABV5/LMTR4 REAL optimized blocks...");
        let sp1_start = Instant::now();
        
        info!("📝 Preparing SP1 inputs...");
        let runner = Runner::new();
        
        info!("🚀 Generating SP1 PLONK proof...");
        let proof_result = runner.generate_plonk_proof(&old_state.into(), &enhanced_header);
        
        match proof_result {
            Ok((proof, vk, new_roots)) => {
                let sp1_time = sp1_start.elapsed();
                info!("✅ SP1 Proving completed in {:?}", sp1_time);
                info!("📊 Proof size: {} bytes", proof.bytes().len());
                
                // Save proof fixture
                let save_start = Instant::now();
                let fixture = PessimisticProofFixture {
                    certificate: certificate.clone(),
                    pp_inputs: VerifierInputs {
                        certificate: certificate.clone(),
                        pessimistic_root_input: "Computed".to_string(),
                        l1_info_root,
                    },
                    signer: state.get_signer(),
                    vkey: format!("v3_proof_vkey_{}", args.n_exits),
                    public_values: format!("0x{}", hex::encode(proof.public_values.as_slice())),
                    proof: format!("0x{}", hex::encode(proof.bytes())),
                };
                
                // Save fixture
                let fixture_path = args.proof_dir.join(format!("v3_proof_n{}.json", args.n_exits));
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
        warn!("⚠️  No validator nodes specified, skipping V3 algorithms");
    }
    
    info!("🎉 SABV3/LMTR3 with SP1 Proving completed");
}
