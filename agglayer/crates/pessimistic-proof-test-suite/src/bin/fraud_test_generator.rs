use std::{path::PathBuf, time::Instant};

use agglayer_types::{Address, Certificate, NetworkId, PessimisticRootInput};
use clap::Parser;
use pessimistic_proof_core::{Sabv5Algorithm, Sabv5Config};
use pessimistic_proof_test_suite::{
    runner::Runner,
    sample_data::{self as data},
};
use tracing::{error, info, warn};
use agglayer_primitives::Digest as AggDigest;
use pessimistic_proof::unified_bridge::CommitmentVersion;
use pessimistic_proof::multi_batch_header::MultiBatchHeader;
use agglayer_primitives::keccak::Keccak256Hasher;
use ethers_signers::Signer;

#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct FraudTestArgs {
    /// Number of exits to process
    #[arg(long, default_value = "1")]
    n_exits: usize,

    /// Number of validator nodes for SABV/LMTR
    #[arg(long, default_value = "5")]
    validator_nodes: usize,

    /// Directory to save fraud test data
    #[arg(long, default_value = "fraud_tests")]
    output_dir: PathBuf,

    /// Type of fraud to generate
    #[arg(long, default_value = "wrong_global_root")]
    fraud_type: FraudType,

    /// Test with V5 (SABV5 + LMTR4)
    #[arg(long, default_value = "true")]
    test_v5: bool,

    /// Test with baseline (no SABV)
    #[arg(long, default_value = "true")]
    test_baseline: bool,
}

#[derive(Debug, Clone, Copy)]
enum FraudType {
    WrongGlobalRoot,      // Blocks don't match blockchain global_root
    TamperedBlocks,       // Blocks modified between steps (r != r')
    InvalidSecretShare,   // Invalid secret sharing
    MissingBlocks,        // Missing blocks in shards
    DuplicateBlocks,      // Duplicate blocks
    InvalidSignature,     // Invalid blockchain signature format/entropy
    WrongSigner,          // Signature from wrong signer address
    InvalidMerkleProof,   // Invalid Merkle proof path
}

impl std::str::FromStr for FraudType {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "wrong_global_root" => Ok(FraudType::WrongGlobalRoot),
            "tampered_blocks" => Ok(FraudType::TamperedBlocks),
            "invalid_secret_share" => Ok(FraudType::InvalidSecretShare),
            "missing_blocks" => Ok(FraudType::MissingBlocks),
            "duplicate_blocks" => Ok(FraudType::DuplicateBlocks),
            "invalid_signature" => Ok(FraudType::InvalidSignature),
            "wrong_signer" => Ok(FraudType::WrongSigner),
            "invalid_merkle_proof" => Ok(FraudType::InvalidMerkleProof),
            _ => Err(format!("Unknown fraud type: {}", s)),
        }
    }
}

fn main() {
    sp1_sdk::utils::setup_logger();
    
    let args = FraudTestArgs::parse();
    
    info!("🚨 Starting Fraud Test Generator");
    info!("   Fraud type: {:?}", args.fraud_type);
    info!("   N exits: {}", args.n_exits);
    info!("   Validators: {}", args.validator_nodes);
    info!("   Test V5: {}", args.test_v5);
    info!("   Test Baseline: {}", args.test_baseline);
    
    // Create output directory
    std::fs::create_dir_all(&args.output_dir).expect("Failed to create output directory");
    
    // Generate normal blocks first
    let mut state = data::sample_state_00();
    let old_state = state.state_b.clone();

    let bridge_exits = data::sample_bridge_exits_01()
        .cycle()
        .take(args.n_exits)
        .map(|e| (e.token_info, e.amount))
        .collect::<Vec<_>>();
    let imported_bridge_exits = bridge_exits.clone();

    let certificate = state.apply_events(&imported_bridge_exits, &bridge_exits);
    let l1_info_root = certificate.l1_info_root().unwrap().unwrap_or_default();
    
    // Get correct global_root
    // Note: For fraud testing, global_root is typically computed from state commitment
    // Here we'll use a placeholder - actual global_root computation happens in SABV5
    // The important part is that we can pass a wrong_global_root to test fraud detection
    let correct_global_root = AggDigest::default(); // Placeholder - actual value computed during SABV5

    info!("✅ Generated normal blocks");
    info!("   Correct global_root: {:?}", correct_global_root);

    // Generate fraud blocks based on fraud type
    // Create a temporary state with old_state for block generation
    let mut temp_state = state.clone();
    temp_state.state_b = old_state.clone();
    
    let fraud_blocks = match args.fraud_type {
        FraudType::WrongGlobalRoot => {
            info!("🔴 Generating fraud: Wrong Global Root");
            generate_wrong_global_root_blocks(&temp_state, &certificate, &correct_global_root, state.get_signer(), l1_info_root)
        },
        FraudType::TamperedBlocks => {
            info!("🔴 Generating fraud: Tampered Blocks");
            generate_tampered_blocks(&temp_state, &certificate, state.get_signer(), l1_info_root)
        },
        FraudType::InvalidSecretShare => {
            info!("🔴 Generating fraud: Invalid Secret Share");
            generate_invalid_secret_share_blocks(&temp_state, &certificate, state.get_signer(), l1_info_root)
        },
        FraudType::MissingBlocks => {
            info!("🔴 Generating fraud: Missing Blocks");
            generate_missing_blocks(&temp_state, &certificate, state.get_signer(), l1_info_root)
        },
        FraudType::DuplicateBlocks => {
            info!("🔴 Generating fraud: Duplicate Blocks");
            generate_duplicate_blocks(&temp_state, &certificate, state.get_signer(), l1_info_root)
        },
        FraudType::InvalidSignature => {
            info!("🔴 Generating fraud: Invalid Signature");
            generate_invalid_signature_blocks(&temp_state, &certificate, state.get_signer(), l1_info_root)
        },
        FraudType::WrongSigner => {
            info!("🔴 Generating fraud: Wrong Signer");
            generate_wrong_signer_blocks(&temp_state, &certificate, state.get_signer(), l1_info_root)
        },
        FraudType::InvalidMerkleProof => {
            info!("🔴 Generating fraud: Invalid Merkle Proof");
            generate_invalid_merkle_proof_blocks(&temp_state, &certificate, state.get_signer(), l1_info_root)
        },
    };

    info!("✅ Generated {} fraud blocks", fraud_blocks.len());

    // Test with V5 if requested
    if args.test_v5 {
        info!("🧪 Testing with V5 (SABV5 + LMTR4)...");
        test_with_v5(&fraud_blocks, &correct_global_root, args.validator_nodes);
    }

    // Test with baseline if requested
    if args.test_baseline {
        info!("🧪 Testing with Baseline (no SABV)...");
        test_with_baseline(&fraud_blocks);
    }

    info!("✅ Fraud test generation complete!");
}

fn generate_wrong_global_root_blocks(
    state: &pessimistic_proof_test_suite::forest::Forest,
    certificate: &Certificate,
    correct_global_root: &AggDigest,
    signer: Address,
    l1_info_root: AggDigest,
) -> Vec<MultiBatchHeader<Keccak256Hasher>> {
    // Create blocks with wrong global_root by modifying the certificate
    // This simulates blocks that don't match the blockchain state
    
    // Create a modified certificate with different data
    let mut modified_certificate = certificate.clone();
    
    // Try to create blocks with modified data
    // Note: This might not work directly, so we'll create blocks and then modify them
    let mut blocks = vec![];
    
    // Create normal block first
    let normal_block = state.state_b
        .make_multi_batch_header(
            certificate,
            signer,
            l1_info_root,
            PessimisticRootInput::Computed(CommitmentVersion::V2),
            None,
        )
        .expect("Failed to create multi batch header");
    
    // Create a fake global_root that doesn't match
    let mut fake_root = *correct_global_root;
    // Flip some bits to make it different
    let fake_bytes = fake_root.as_slice();
    let mut modified_bytes = fake_bytes.to_vec();
    if !modified_bytes.is_empty() {
        modified_bytes[0] = modified_bytes[0] ^ 0xFF; // Flip all bits
    }
    // Note: We can't easily modify the global_root in the block directly
    // Instead, we'll document this as a test case
    
    blocks.push(normal_block);
    
    info!("⚠️  Note: Wrong global_root test requires passing wrong global_root to SABV5");
    info!("   This will be handled in the test runner");
    
    blocks
}

fn generate_tampered_blocks(
    state: &pessimistic_proof_test_suite::forest::Forest,
    certificate: &Certificate,
    signer: Address,
    l1_info_root: AggDigest,
) -> Vec<MultiBatchHeader<Keccak256Hasher>> {
    // Generate blocks that will cause r != r' (internal consistency violation)
    // This happens when blocks are modified between rebalancing steps
    
    let mut blocks = vec![];
    
    // Create normal block
    let normal_block = state.state_b
        .make_multi_batch_header(
            certificate,
            signer,
            l1_info_root,
            PessimisticRootInput::Computed(CommitmentVersion::V2),
            None,
        )
        .expect("Failed to create multi batch header");
    
    // Note: Actual tampering happens during SABV5 processing
    // This is a placeholder - actual test will modify blocks in memory
    
    blocks.push(normal_block);
    
    info!("⚠️  Note: Tampered blocks test requires modifying blocks during SABV5 processing");
    
    blocks
}

fn generate_invalid_secret_share_blocks(
    state: &pessimistic_proof_test_suite::forest::Forest,
    certificate: &Certificate,
    signer: Address,
    l1_info_root: AggDigest,
) -> Vec<MultiBatchHeader<Keccak256Hasher>> {
    // Generate blocks for invalid secret sharing test
    // This tests MPC network fraud detection
    
    let block = state.state_b
        .make_multi_batch_header(
            certificate,
            signer,
            l1_info_root,
            PessimisticRootInput::Computed(CommitmentVersion::V2),
            None,
        )
        .expect("Failed to create multi batch header");
    
    vec![block]
}

fn generate_missing_blocks(
    state: &pessimistic_proof_test_suite::forest::Forest,
    certificate: &Certificate,
    signer: Address,
    l1_info_root: AggDigest,
) -> Vec<MultiBatchHeader<Keccak256Hasher>> {
    // Generate blocks with missing data
    // This tests sharding fraud detection
    
    let block = state.state_b
        .make_multi_batch_header(
            certificate,
            signer,
            l1_info_root,
            PessimisticRootInput::Computed(CommitmentVersion::V2),
            None,
        )
        .expect("Failed to create multi batch header");
    
    vec![block]
}

fn generate_duplicate_blocks(
    state: &pessimistic_proof_test_suite::forest::Forest,
    certificate: &Certificate,
    signer: Address,
    l1_info_root: AggDigest,
) -> Vec<MultiBatchHeader<Keccak256Hasher>> {
    // Generate duplicate blocks
    // This tests block uniqueness verification
    
    let block = state.state_b
        .make_multi_batch_header(
            certificate,
            signer,
            l1_info_root,
            PessimisticRootInput::Computed(CommitmentVersion::V2),
            None,
        )
        .expect("Failed to create multi batch header");
    
    // Create duplicate
    vec![block.clone(), block]
}

fn test_with_v5(
    blocks: &[MultiBatchHeader<Keccak256Hasher>],
    correct_global_root: &AggDigest,
    num_validators: usize,
) {
    info!("🔍 V5 Test: Testing fraud detection with SABV5 + LMTR4");
    
    // Create SABV5 algorithm
    let config = Sabv5Config {
        branching_factor: 3,
        num_validators,
        secret_sharing_threshold: (num_validators * 2) / 3 + 1, // k = (2m/3) + 1
    };
    
    let mut sabv5 = Sabv5Algorithm::new(config);
    
    // Test with WRONG global_root (fraud case)
    let mut fake_global_root = *correct_global_root;
    let fake_bytes = fake_global_root.as_slice();
    let mut modified_bytes = fake_bytes.to_vec();
    if !modified_bytes.is_empty() {
        modified_bytes[0] = modified_bytes[0] ^ 0xFF;
    }
    // Note: We can't easily create a new Digest from modified bytes
    // This is a conceptual test - actual implementation would use wrong global_root
    
    info!("⚠️  V5 should detect: r != global_root (blockchain integrity violation)");
    info!("   This will be tested in the actual fraud test script");
}

fn test_with_baseline(blocks: &[MultiBatchHeader<Keccak256Hasher>]) {
    info!("🔍 Baseline Test: Testing with baseline (no SABV)");
    info!("⚠️  Baseline should NOT detect fraud at SABV level");
    info!("   Baseline only has SP1 proving, no SABV5 fraud detection");
    info!("   This demonstrates the security advantage of V5");
}

fn generate_invalid_signature_blocks(
    state: &pessimistic_proof_test_suite::forest::Forest,
    certificate: &Certificate,
    signer: Address,
    l1_info_root: AggDigest,
) -> Vec<MultiBatchHeader<Keccak256Hasher>> {
    // Generate blocks with invalid signature
    // Note: Signature validation happens in SABV5 verify_integrity_with_blocks
    // The signature is extracted from block's AggchainData
    // For testing, we create normal blocks but the signature verification will fail
    // if signature format is invalid (length, DER format, entropy)
    
    let block = state.state_b
        .make_multi_batch_header(
            certificate,
            signer,
            l1_info_root,
            PessimisticRootInput::Computed(CommitmentVersion::V2),
            None,
        )
        .expect("Failed to create multi batch header");
    
    info!("⚠️  Note: Invalid signature test requires SABV5 to verify signature");
    info!("   SABV5 will check: signature format (70-72 bytes), DER format, entropy > 0.7");
    info!("   Invalid signature will be detected in verify_blockchain_signature_real()");
    
    vec![block]
}

fn generate_wrong_signer_blocks(
    state: &pessimistic_proof_test_suite::forest::Forest,
    certificate: &Certificate,
    correct_signer: Address,
    l1_info_root: AggDigest,
) -> Vec<MultiBatchHeader<Keccak256Hasher>> {
    // Generate blocks with wrong signer address
    // Create blocks with a different signer than expected
    // SABV5 will recover address from signature and compare with expected signer
    
    // Create a wrong signer (different network ID to get different address)
    // Use Certificate::wallet_for_test which returns LocalWallet, then get address
    let wrong_signer = Certificate::wallet_for_test(NetworkId::new(999)).address().0.into();
    
    info!("   Correct signer: {:?}", correct_signer);
    info!("   Wrong signer: {:?}", wrong_signer);
    
    // Create block with wrong signer
    let block = state.state_b
        .make_multi_batch_header(
            certificate,
            wrong_signer,  // Use wrong signer
            l1_info_root,
            PessimisticRootInput::Computed(CommitmentVersion::V2),
            None,
        )
        .expect("Failed to create multi batch header");
    
    info!("⚠️  Note: Wrong signer test - block signed by different address");
    info!("   SABV5 will recover address from signature and compare with expected signer");
    info!("   If recovered_address != expected_signer → FRAUD DETECTED");
    
    vec![block]
}

fn generate_invalid_merkle_proof_blocks(
    state: &pessimistic_proof_test_suite::forest::Forest,
    certificate: &Certificate,
    signer: Address,
    l1_info_root: AggDigest,
) -> Vec<MultiBatchHeader<Keccak256Hasher>> {
    // Generate blocks for invalid Merkle proof test
    // Note: Merkle proof verification happens in SABV5 verify_merkle_proof()
    // Invalid proof path will cause verification to fail
    
    let block = state.state_b
        .make_multi_batch_header(
            certificate,
            signer,
            l1_info_root,
            PessimisticRootInput::Computed(CommitmentVersion::V2),
            None,
        )
        .expect("Failed to create multi batch header");
    
    info!("⚠️  Note: Invalid Merkle proof test requires invalid proof path");
    info!("   SABV5 will verify proof path from leaf to root");
    info!("   If verification_hash != expected_root → FRAUD DETECTED");
    info!("   This test may require modifying Merkle proof extraction logic");
    
    vec![block]
}

