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
pub mod sabv2;
pub mod lmtr2;
pub mod sabv3;
pub mod lmtr3;
pub mod sabv4;
pub mod lmtr4;
pub mod sabv5;

pub use sabv::{SabvAlgorithm, SabvConfig};
pub use lmtr::{LmtrAlgorithm, LmtrConfig, RebalancedSet};
pub use sabv2::{Sabv2Algorithm, Sabv2Config};
pub use lmtr2::{Lmtr2Algorithm, Lmtr2Config, Rebalanced2Set};
pub use sabv3::{Sabv3Algorithm, Sabv3Config};
pub use lmtr3::{Lmtr3Algorithm, Lmtr3Config, RebalancedShard};
pub use sabv4::{Sabv4Algorithm, Sabv4Config};
pub use lmtr4::{Lmtr4Algorithm, Lmtr4Config};
pub use sabv5::{Sabv5Algorithm, Sabv5Config};
