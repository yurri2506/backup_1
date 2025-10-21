pub use agglayer_primitives::keccak;

pub mod proof;
pub use proof::{generate_pessimistic_proof, PessimisticProofOutput, ProofError};

pub mod local_balance_tree;

pub mod aggchain_proof;
pub mod local_state;
pub mod multi_batch_header;
pub mod nullifier_tree;

pub use local_state::NetworkState;

include!(concat!(env!("OUT_DIR"), "/version.rs"));
pub const PESSIMISTIC_PROOF_PROGRAM_SELECTOR: [u8; 4] =
    PESSIMISTIC_PROOF_PROGRAM_VERSION.to_be_bytes();

pub mod sabv;
pub mod lmtr;

pub use sabv::{SabvAlgorithm, SabvConfig};
pub use lmtr::{LmtrAlgorithm, LmtrConfig, RebalancedSet};

// Real algorithms for fraud detection
pub mod real_sabv;
pub mod real_lmtr;

pub use real_sabv::{RealSabvAlgorithm, RealSabvConfig};
pub use real_lmtr::{RealLmtrAlgorithm, RealLmtrConfig, RealRebalancedSet};

// Real algorithms v3 for fraud detection
pub mod real_sabv_3;
pub mod real_lmtr_3;

pub use real_sabv_3::{RealSabvAlgorithm3, RealSabvConfig3};
pub use real_lmtr_3::{RealLmtrAlgorithm3, RealLmtrConfig3, RealRebalancedSet3};
