# PHÂN TÍCH CHI TIẾT: TẤT CẢ CÁC LOẠI GIAN LẬN TRONG V5

## TỔNG QUAN ALGORITHM 1 (SABV5)

SABV5 thực hiện **7 bước chính** để verify aggregated blocks:

1. **Step 1**: Choose optimal sharding size j*
2. **Step 2**: Data Sharding (partition blocks into m shards)
3. **Step 3**: Secret Sharing and Distribution (SMPC network)
4. **Step 4**: Rebalance Shards with LMTR4
5. **Step 5a**: Build Local CC-MBMT from rebalanced blocks
6. **Step 5b**: Merge Local CC-MBMTs → Compute global root r
7. **Step 6**: Compute root r' from rebalanced blocks (for CHECK 1)
8. **Step 6b**: Use root r' from original blocks (for CHECK 2)
9. **Step 7**: Integrity Verification (CHECK 1, CHECK 2, CHECK 3)

---

## PHÂN TÍCH CHI TIẾT TỪNG BƯỚC

### BƯỚC 0: INPUT

**Đầu vào:**
```rust
verify_aggregated_blocks(
    blocks: &[MultiBatchHeader<Keccak256Hasher>],  // N blocks
    expected_global_root: &AggDigest,               // Global root từ blockchain
)
```

**Thành phần mỗi block:**
- `certificate`: Certificate với bridge exits/imports
- `global_root`: Global root từ block
- `aggchain_proof`: Proof data (ECDSA signature hoặc Generic)
- `l1_info_root`: L1 info root
- Metadata khác

**Gian lận có thể xảy ra:**
- ❌ **Wrong blocks**: Blocks không match với expected_global_root
- ❌ **Tampered blocks**: Block content bị modify
- ❌ **Missing blocks**: Thiếu blocks trong array
- ❌ **Duplicate blocks**: Blocks bị duplicate
- ❌ **Invalid blocks**: Blocks có invalid structure/data

---

### BƯỚC 1: Choose Optimal Sharding Size j*

**Mục đích:** Tìm j* tối ưu để minimize variance trong shard sizes

**Quy trình:**
1. Try tất cả j ∈ [1, log_b(N)]
2. Calculate shard_size = b^j cho mỗi j
3. Compute variance của shard sizes
4. Chọn j* với variance nhỏ nhất

**Đầu vào:**
- `blocks`: Vec<MultiBatchHeader<...>> (N blocks)
- `b`: branching_factor (default: 3)
- `n`: blocks.len()

**Đầu ra:**
- `j_star`: Optimal sharding size (usize)

**Gian lận có thể xảy ra:**
- ❌ **Invalid j* calculation**: Algorithm tính sai j*
  - Detection: Sẽ gây shard size không tối ưu → ảnh hưởng performance
  - Impact: Không phải fraud về data, nhưng ảnh hưởng performance
  - Note: Không có check riêng, nhưng không phải fraud về data integrity

---

### BƯỚC 2: Data Sharding

**Mục đích:** Partition N blocks thành m shards

**Quy trình:**
1. Calculate shard_size = b^j*
2. Partition blocks:
   - Shard 1..(m-1): mỗi shard có b^j* blocks (full shards)
   - Shard m: N - (m-1)·b^j* blocks (remainder shard)
3. Assign shards to validators (round-robin)

**Đầu vào:**
- `blocks`: Vec<MultiBatchHeader<...>> (N blocks)
- `j_star`: Optimal sharding size
- `b`: branching_factor
- `m`: num_validators

**Đầu ra:**
- `shards`: Vec<ShardData>
  - Mỗi ShardData chứa:
    - `blocks`: Vec<MultiBatchHeader<...>> (blocks trong shard)
    - `validator_id`: usize (validator được assign)
    - `shard_index`: usize (shard index)

**Gian lận có thể xảy ra:**

1. ❌ **Sharding Error**: Blocks divided incorrectly
   - Ví dụ: Block bị assign sai shard
   - Ví dụ: Block bị missing trong shard
   - Ví dụ: Block bị duplicate trong nhiều shards
   - **Detection:** CHECK 1 sẽ detect (r ≠ r')
   - **Bước xảy ra:** Step 2 (Data Sharding)

2. ❌ **Invalid Shard Assignment**: Shard assigned sai validator
   - Ví dụ: Shard assigned to wrong validator_id
   - **Detection:** Có thể không detect nếu chỉ là assignment error (không ảnh hưởng content)
   - **Impact:** Performance issue, không phải fraud về data

3. ❌ **Block Loss During Sharding**: Blocks bị mất trong quá trình sharding
   - Ví dụ: Block không được assign vào shard nào
   - **Detection:** CHECK 1 sẽ detect (r ≠ r' do missing blocks)
   - **Bước xảy ra:** Step 2 (Data Sharding)

4. ❌ **Block Duplication During Sharding**: Blocks bị duplicate
   - Ví dụ: Block xuất hiện trong nhiều shards
   - **Detection:** CHECK 1 hoặc CHECK 2 sẽ detect
   - **Bước xảy ra:** Step 2 (Data Sharding)

---

### BƯỚC 3: Secret Sharing and Distribution (SMPC Network)

**Mục đích:** Distribute shards to validators using Shamir secret sharing (k,m threshold)

**Quy trình:**
1. For each shard:
   a. Generate secret S từ shard content
   b. Generate polynomial f(x) = S + a1·x + ... + a(k-1)·x^(k-1)
   c. Calculate shares (x_i, y_i) cho mỗi validator: y_i = f(x_i)
   d. **BROADCAST shares over MPC network** (all-to-all communication)
2. Each validator RECEIVES shares từ network
3. Reconstruct secret từ received shares (cần ≥ k shares) using Lagrange interpolation
4. Assign shard to validator với highest reconstructed secret

**Đầu vào:**
- `shards`: Vec<ShardData>
- `secret_sharing_threshold`: k (threshold)
- `num_validators`: m (number of validators)

**Đầu ra:**
- `distributed_shards`: Vec<ShardData> (shards được assign to validators)

**Gian lận có thể xảy ra:**

1. ❌ **Invalid Secret Share**: Secret share không hợp lệ
   - Ví dụ: Share (x_i, y_i) không match với polynomial
   - Ví dụ: Share bị tamper trong quá trình transmission
   - **Detection:** Lagrange interpolation sẽ fail (không reconstruct được secret)
   - **Impact:** Validator không reconstruct được secret → không assign được shard
   - **Bước xảy ra:** Step 3 (Secret Sharing)

2. ❌ **MPC Network Fraud**: Shares bị modify trong network
   - Ví dụ: Attacker intercept và modify shares
   - Ví dụ: Fake shares được inject vào network
   - **Detection:** Lagrange interpolation sẽ fail hoặc reconstruct sai secret
   - **Impact:** Shard assigned sai validator → CHECK 1 có thể fail
   - **Bước xảy ra:** Step 3 (MPC Network Communication)

3. ❌ **Threshold Attack**: Không đủ k shares để reconstruct secret
   - Ví dụ: Attacker block network messages → validator nhận < k shares
   - **Detection:** Code check `received_shares.len() >= threshold`
   - **Impact:** Validator không reconstruct được secret → không assign được shard
   - **Bước xảy ra:** Step 3 (Secret Sharing)

4. ❌ **Polynomial Tampering**: Polynomial f(x) bị modify
   - Ví dụ: Attacker modify polynomial coefficients
   - **Detection:** Shares không match → Lagrange interpolation fail
   - **Impact:** Secret reconstruction fail
   - **Bước xảy ra:** Step 3 (Polynomial Generation)

5. ❌ **Secret Reconstruction Fraud**: Reconstructed secret sai
   - Ví dụ: Validator reconstruct sai secret (bug hoặc fraud)
   - **Detection:** Shard assignment sai → CHECK 1 có thể detect
   - **Bước xảy ra:** Step 3 (Secret Reconstruction)

6. ❌ **Shard Assignment Fraud**: Shard assigned sai validator
   - Ví dụ: Validator với highest secret không đúng
   - **Detection:** CHECK 1 có thể detect nếu ảnh hưởng đến content
   - **Bước xảy ra:** Step 3 (Shard Assignment)

---

### BƯỚC 4: Rebalance Shards with LMTR4

**Mục đích:** Fix branch imbalance và height imbalance trong mỗi shard

**Quy trình:**
1. For each shard:
   a. Call LMTR4 algorithm
   b. Rebalance blocks để fix:
      - Branch imbalance: Ni mod b ≠ 0
      - Height imbalance: log_b(Ni) + 1 ≠ htarget
   c. Return rebalanced blocks

**Đầu vào:**
- `distributed_shards`: Vec<ShardData>
- `lmtr4_config`: Lmtr4Config (branching_factor, target_height)

**Đầu ra:**
- `rebalanced_shards`: Vec<(validator_id, shard_index, rebalanced_blocks)>
  - Mỗi tuple chứa:
    - `validator_id`: usize
    - `shard_index`: usize
    - `rebalanced_blocks`: Vec<MultiBatchHeader<...>> (blocks sau rebalancing)

**Gian lận có thể xảy ra:**

1. ❌ **Rebalancing Content Fraud**: Rebalancing thay đổi block content (không chỉ structure)
   - Ví dụ: LMTR4 modify block data thay vì chỉ add/remove blocks
   - Ví dụ: Blocks bị tamper trong quá trình rebalancing
   - **Detection:** CHECK 2 sẽ detect (r' (original) ≠ r (rebalanced))
   - **Bước xảy ra:** Step 4 (LMTR4 Rebalancing)

2. ❌ **Invalid Rebalancing**: Rebalancing tạo ra invalid blocks
   - Ví dụ: Blocks có invalid structure sau rebalancing
   - **Detection:** Có thể detect ở Step 5a (build tree fail)
   - **Bước xảy ra:** Step 4 (LMTR4 Rebalancing)

3. ❌ **Block Loss During Rebalancing**: Blocks bị mất trong rebalancing
   - Ví dụ: LMTR4 remove blocks nhưng không preserve content
   - **Detection:** CHECK 2 sẽ detect (original blocks không present)
   - **Bước xảy ra:** Step 4 (LMTR4 Rebalancing)

4. ❌ **Extra Blocks During Rebalancing**: Blocks bị thêm không hợp lệ
   - Ví dụ: LMTR4 add blocks không phải từ original
   - **Detection:** CHECK 2 sẽ detect (extra blocks detected)
   - **Bước xảy ra:** Step 4 (LMTR4 Rebalancing)

---

### BƯỚC 5a: Build Local CC-MBMT from Rebalanced Blocks

**Mục đích:** Mỗi validator build REAL Merkle B+ Tree từ rebalanced blocks

**Quy trình:**
1. For each (validator_id, shard_index, rebalanced_blocks):
   a. Build REAL Merkle B+ Tree từ rebalanced_blocks
   b. Compute local root và tree height
   c. Create LocalCCMBMT structure

**Đầu vào:**
- `rebalanced_shards`: Vec<(validator_id, shard_index, rebalanced_blocks)>
- `b`: branching_factor

**Đầu ra:**
- `local_trees`: Vec<LocalCCMBMT>
  - Mỗi LocalCCMBMT chứa:
    - `validator_id`: usize
    - `root`: Digest (local tree root)
    - `height`: usize (tree height)
    - `shard_data`: ShardData

**Gian lận có thể xảy ra:**

1. ❌ **Tree Building Fraud**: Tree được build sai
   - Ví dụ: Tree structure không đúng (invalid parent-child relationships)
   - Ví dụ: Root computed sai
   - **Detection:** CHECK 1 sẽ detect (r ≠ r')
   - **Bước xảy ra:** Step 5a (Tree Building)

2. ❌ **Invalid Blocks in Tree**: Blocks trong tree có invalid structure
   - Ví dụ: Blocks có invalid data structure
   - **Detection:** Tree building có thể fail hoặc CHECK 1 detect
   - **Bước xảy ra:** Step 5a (Tree Building)

---

### BƯỚC 5b: Merge Local CC-MBMTs → Compute Global Root r

**Mục đích:** Merge tất cả local tree roots để compute global CC-MBMT root r

**Quy trình:**
1. Collect tất cả local roots
2. Build Merkle tree từ local roots
3. Compute global root r

**Đầu vào:**
- `local_trees`: Vec<LocalCCMBMT>

**Đầu ra:**
- `r_computed`: Digest (global root từ merged local trees)

**Gian lận có thể xảy ra:**

1. ❌ **Merge Error**: Merge process sai
   - Ví dụ: Local roots merged không đúng order
   - Ví dụ: Missing local roots trong merge
   - **Detection:** CHECK 1 sẽ detect (r ≠ r')
   - **Bước xảy ra:** Step 5b (Merge)

2. ❌ **Invalid Local Roots**: Local roots bị tamper
   - Ví dụ: Validator modify local root trước khi merge
   - **Detection:** CHECK 1 sẽ detect (r ≠ r')
   - **Bước xảy ra:** Step 5b (Merge)

---

### BƯỚC 6: Compute Root r' from Rebalanced Blocks (for CHECK 1)

**Mục đích:** Compute alternative root r' từ all rebalanced blocks

**Quy trình:**
1. Collect tất cả rebalanced blocks từ all shards
2. Build REAL Merkle tree từ all rebalanced blocks (SAME method as Step 5a)
3. Compute root r'

**Đầu vào:**
- `rebalanced_shards`: Vec<(validator_id, shard_index, rebalanced_blocks)>

**Đầu ra:**
- `r_prime_from_rebalanced`: Digest (root từ all rebalanced blocks)

**Gian lận có thể xảy ra:**

1. ❌ **Block Collection Error**: Blocks collected sai
   - Ví dụ: Missing blocks trong collection
   - Ví dụ: Duplicate blocks trong collection
   - **Detection:** CHECK 1 sẽ detect (r ≠ r')
   - **Bước xảy ra:** Step 6 (Block Collection)

2. ❌ **Root Computation Error**: Root computed sai
   - Ví dụ: Tree building method khác với Step 5a
   - **Detection:** CHECK 1 sẽ detect (r ≠ r')
   - **Bước xảy ra:** Step 6 (Root Computation)

---

### BƯỚC 6b: Use Root r' from Original Blocks (for CHECK 2)

**Mục đích:** Lấy root r' từ original blocks (đã computed ở đầu)

**Quy trình:**
1. Use `expected_root_from_original_blocks` (đã computed ở Step 0)

**Đầu vào:**
- `expected_root_from_original_blocks`: Digest (computed ở Step 0)

**Đầu ra:**
- `r_prime_from_original`: Digest (root từ original blocks)

**Gian lận có thể xảy ra:**

1. ❌ **Original Root Fraud**: Original root computed sai ở đầu
   - Ví dụ: Root từ original blocks computed sai
   - **Detection:** CHECK 2 có thể fail (nếu rebalancing preserve content nhưng root sai)
   - **Bước xảy ra:** Step 0 (Original Root Computation)

---

### BƯỚC 7: Integrity Verification (CHECK 1, CHECK 2, CHECK 3)

**Mục đích:** Verify integrity và detect fraud

**Quy trình:**
1. **CHECK 1**: r == r' (from rebalanced blocks)
   - Verify: r (from merged local trees) == r' (from all rebalanced blocks)
   - Purpose: Internal consistency
   
2. **CHECK 2**: r' (from original) == r (from rebalanced)
   - Verify: r' (from original blocks) == r (from rebalanced blocks)
   - Purpose: Rebalancing integrity
   
3. **CHECK 3**: computed_root == expected_global_root
   - Verify: computed_root (from blocks) == expected_global_root (from blockchain)
   - Purpose: Blockchain integrity
   - Note: Cần verify xem CHECK 3 có được gọi trong verify_aggregated_blocks không

**Đầu vào:**
- `r_computed`: Digest (from Step 5b)
- `r_prime_from_rebalanced`: Digest (from Step 6)
- `r_prime_from_original`: Digest (from Step 6b)
- `expected_global_root`: Digest (parameter đầu vào)

**Đầu ra:**
- `integrity_verified`: bool
  - `true`: Tất cả checks passed
  - `false`: Có ít nhất 1 check failed

**Gian lận phát hiện:**

1. ❌ **CHECK 1 FAIL**: Internal inconsistency
   - Detection: r ≠ r' (from rebalanced)
   - Causes:
     - Sharding/merge error
     - Blocks missing/duplicated
     - Tree building error
   - **Bước fraud xảy ra:** Step 2, 5a, 5b, hoặc 6

2. ❌ **CHECK 2 FAIL**: Rebalancing integrity violation
   - Detection: r' (original) ≠ r (rebalanced)
   - Causes:
     - Rebalancing changed block content
     - Blocks tampered during rebalancing
     - Original blocks missing trong rebalanced
   - **Bước fraud xảy ra:** Step 4 (LMTR4 Rebalancing)

3. ❌ **CHECK 3 FAIL**: Blockchain integrity violation
   - Detection: computed_root ≠ expected_global_root
   - Causes:
     - Wrong global_root (blocks từ chain khác)
     - Blocks không match với blockchain state
     - Blocks tampered
   - **Bước fraud xảy ra:** Step 0 (Input blocks)

---

## TỔNG KẾT TẤT CẢ CÁC LOẠI GIAN LẬN

### THEO BƯỚC XẢY RA:

| Bước | Loại gian lận | Detection | Impact |
|------|---------------|-----------|--------|
| **Step 0 (Input)** | Wrong blocks, Tampered blocks, Missing blocks, Duplicate blocks, Invalid blocks | CHECK 3 | High |
| **Step 2 (Sharding)** | Sharding error, Block loss, Block duplication, Invalid shard assignment | CHECK 1 | High |
| **Step 3 (SMPC)** | Invalid secret share, MPC network fraud, Threshold attack, Polynomial tampering, Secret reconstruction fraud, Shard assignment fraud | CHECK 1 | High |
| **Step 4 (Rebalancing)** | Rebalancing content fraud, Invalid rebalancing, Block loss, Extra blocks | CHECK 2 | High |
| **Step 5a (Tree Building)** | Tree building fraud, Invalid blocks in tree | CHECK 1 | High |
| **Step 5b (Merge)** | Merge error, Invalid local roots | CHECK 1 | High |
| **Step 6 (Compute r')** | Block collection error, Root computation error | CHECK 1 | High |
| **Step 7 (Verification)** | CHECK 1/2/3 fail | Early exit | High |

### THEO LOẠI GIAN LẬN:

1. **Wrong Global Root** (CHECK 3)
   - Bước: Step 0 (Input)
   - Detection: CHECK 3

2. **Tampered Blocks** (CHECK 1, 2, 3)
   - Bước: Step 0, 4, hoặc bất kỳ bước nào
   - Detection: CHECK 1, 2, hoặc 3

3. **Missing Blocks** (CHECK 1, 2)
   - Bước: Step 2, 4, hoặc 6
   - Detection: CHECK 1 hoặc 2

4. **Duplicate Blocks** (CHECK 2)
   - Bước: Step 2, 4, hoặc 6
   - Detection: CHECK 2

5. **Sharding/Merge Error** (CHECK 1)
   - Bước: Step 2, 5a, 5b, hoặc 6
   - Detection: CHECK 1

6. **Rebalancing Content Fraud** (CHECK 2)
   - Bước: Step 4 (LMTR4)
   - Detection: CHECK 2

7. **SMPC Network Fraud** (CHECK 1)
   - Bước: Step 3 (Secret Sharing)
   - Detection: CHECK 1 (indirect, qua shard assignment)

8. **Secret Share Fraud** (CHECK 1)
   - Bước: Step 3 (Secret Sharing)
   - Detection: CHECK 1 (indirect)

9. **Tree Building Fraud** (CHECK 1)
   - Bước: Step 5a
   - Detection: CHECK 1

10. **Merge Error** (CHECK 1)
    - Bước: Step 5b
    - Detection: CHECK 1

---

## KẾT LUẬN

### ✅ V5 phát hiện được TẤT CẢ các loại gian lận qua 3 checks:

1. **CHECK 1** (Internal Consistency): Detect fraud ở Step 2, 3, 5a, 5b, 6
2. **CHECK 2** (Rebalancing Integrity): Detect fraud ở Step 4
3. **CHECK 3** (Blockchain Integrity): Detect fraud ở Step 0 (Input)

### ✅ Early exit mechanism:
- Fraud detected → exit(1) ngay
- Tiết kiệm thời gian và tài nguyên
- Không chạy SP1 proving với fraudulent data

### ✅ So với baseline:
- Baseline: KHÔNG có checks này → chạy full SP1 proving
- V5: Có 3 checks → phát hiện fraud sớm → early exit


