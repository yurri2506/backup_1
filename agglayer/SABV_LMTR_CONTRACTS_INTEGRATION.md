# SABV/LMTR CONTRACTS INTEGRATION

## Kết nối với Agglayer Contracts

### 1. SP1 Verifier Integration
- **File**: `agglayer-contracts/contracts/verifiers/v4.0.0-rc.3/SP1VerifierPlonk.sol`
- **Interface**: `ISP1Verifier` trong `agglayer-contracts/contracts/v2/interfaces/ISP1Verifier.sol`
- **Function**: `verifyProof(bytes32 programVKey, bytes calldata publicValues, bytes calldata proofBytes)`

### 2. Pessimistic Consensus
- **File**: `agglayer-contracts/contracts/v2/consensus/pessimistic/PolygonPessimisticConsensus.sol`
- **Type**: `CONSENSUS_TYPE = 0`
- **Integration**: Sử dụng SP1 proofs cho pessimistic consensus

### 3. SABV/LMTR Workflow
1. **SABV Algorithm**: Verify aggregated blocks trước khi proving
2. **LMTR Algorithm**: Rebalance Merkle trees để optimize
3. **SP1 Proving**: Generate proof với enhanced batch header
4. **Contract Verification**: Verify proof trên Polygon contracts

### 4. Integration Points
- `ppgen_sabv_lmtr.rs`: Generate enhanced proofs
- `SP1VerifierPlonk.sol`: Verify proofs on-chain
- `PolygonPessimisticConsensus.sol`: Consensus mechanism

---
*Tích hợp SABV/LMTR với Agglayer Contracts hoàn tất*
