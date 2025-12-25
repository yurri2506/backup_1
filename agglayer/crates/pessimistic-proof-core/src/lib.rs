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

pub mod lmtr;
pub mod lmtr4;
pub mod sabv;
pub mod sabv5;

pub use lmtr::{LmtrAlgorithm, LmtrConfig, RebalancedSet};
pub use lmtr4::{Lmtr4Algorithm, Lmtr4Config};
pub use sabv::{SabvAlgorithm, SabvConfig};
pub use sabv5::{Sabv5Algorithm, Sabv5Config};
