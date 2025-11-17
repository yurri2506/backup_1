# PHÂN TÍCH CHI TIẾT: FRAUD DETECTION TRONG V5

## TỔNG QUAN

V5 (SABV5 + LMTR4) phát hiện gian lận thông qua **3 checks chính** trong Algorithm 1 (SABV5).

---

## 1. ĐẦU VÀO (INPUT)

### Hàm: `verify_aggregated_blocks()`

**Signature:**
```rust
pub fn verify_aggregated_blocks(
    &mut self,
    blocks: &[MultiBatchHeader<Keccak256Hasher>],
    expected_global_root: &AggDigest,
) -> Result<(bool, Vec<MultiBatchHeader<...>>), ProofError>
```

**Input Parameters:**

1. **`blocks`**: `Vec<MultiBatchHeader<Keccak256Hasher>>`
   - Danh sách các blocks cần verify
   - Mỗi block chứa:
     - `certificate`: Certificate với bridge exits
     - `global_root`: Global root từ block
     - `aggchain_proof`: Proof data (ECDSA signature hoặc Generic)
     - Các metadata khác

2. **`expected_global_root`**: `AggDigest` (32 bytes)
   - Global root mong đợi từ blockchain
   - Dùng để verify blocks có match với blockchain state không
   - **Đây là tham số quan trọng để test fraud**: Pass wrong_global_root để trigger CHECK 3

---

## 2. CÁC LOẠI GIAN LẬN PHÁT HIỆN

### A. CHECK 1: Internal Consistency (r == r')

**Mục đích:** Verify sharding và merge process đúng

**Kiểm tra:**
```
r (from merged local trees, rebalanced blocks) == r' (from all rebalanced blocks)
```

**Quy trình:**
1. Step 5a: Build local CC-MBMT từ rebalanced blocks → Compute r
2. Step 6: Compute r' từ all rebalanced blocks (same data)
3. CHECK 1: r == r'?

**Phát hiện gian lận:**
- ❌ **r ≠ r'** → FRAUD DETECTED
- ⚠️ **Possible causes:**
  - Blocks divided incorrectly between shards
  - Blocks missing hoặc duplicated during sharding
  - Merge process error
  - Data corruption during processing

**Code:**
```rust
let check1_roots_match = r_computed == r_prime_from_rebalanced;
if !check1_roots_match {
    println!("❌ SABV5: Verification FAILED - Internal inconsistency!");
    println!("   ⚠️  FRAUD DETECTED - sharding/merge error or data corruption!");
    return Ok((false, all_rebalanced_blocks));  // integrity_verified = false
}
```

---

### B. CHECK 2: Rebalancing Integrity (r' (original) == r (rebalanced))

**Mục đích:** Verify rebalancing không thay đổi block content (chỉ structure)

**Kiểm tra:**
```
r' (from original blocks) == r (from rebalanced blocks)
```

**Quy trình:**
1. Compute r' từ original blocks (TRƯỚC rebalancing)
2. Compute r từ rebalanced blocks (SAU rebalancing)
3. CHECK 2: r' (original) == r (rebalanced)?

**Phát hiện gian lận:**
- ❌ **r' (original) ≠ r (rebalanced)** → FRAUD DETECTED
- ⚠️ **Possible causes:**
  - Rebalancing changed block content (chỉ được thay đổi structure)
  - Blocks modified during rebalancing
  - Blocks tampered giữa các bước

**Special case:** Nếu block count thay đổi do rebalancing:
- Compare unique blocks bằng hash sets
- Check: `all_original_present && no_extra_blocks`
- Content preserved = true nếu structure changed nhưng content preserved

**Code:**
```rust
let check2_rebalancing_match = if original_block_count != rebalanced_block_count {
    // Compare unique blocks by hash sets
    let all_original_present = original_hashes.is_subset(&unique_rebalanced_hashes);
    let no_extra_blocks = unique_rebalanced_hashes.is_subset(&original_hashes);
    all_original_present && no_extra_blocks
} else {
    // Block count unchanged - compare roots directly
    r_prime_from_original.as_slice() == r_computed.as_slice()
};

if !check2_rebalancing_match {
    println!("❌ SABV5: Verification FAILED - Rebalancing integrity violation!");
    println!("   ⚠️  FRAUD DETECTED - rebalancing changed block content!");
    return Ok((false, all_rebalanced_blocks));  // integrity_verified = false
}
```

---

### C. CHECK 3: Blockchain Integrity (computed_root == expected_global_root)

**Mục đích:** Verify blocks match với blockchain global_root

**Kiểm tra:**
```
computed_root (from blocks) == expected_global_root (from blockchain)
```

**Quy trình:**
1. Compute root từ blocks (after all processing)
2. Compare với `expected_global_root` (parameter đầu vào)
3. CHECK 3: computed_root == expected_global_root?

**Phát hiện gian lận:**
- ❌ **computed_root ≠ expected_global_root** → FRAUD DETECTED
- ⚠️ **Possible causes:**
  - Blocks không match với blockchain state
  - Wrong global_root (blocks từ chain khác)
  - Blocks bị tamper để không match với blockchain

**Note:** CHECK 3 được implement trong `verify_integrity_with_blocks()`, nhưng **cần verify xem có được gọi trong `verify_aggregated_blocks()` không**.

**Code (trong verify_integrity_with_blocks):**
```rust
fn verify_integrity_with_blocks(
    &self, 
    computed_root: &Digest, 
    expected_root: &AggDigest,
    blocks: &[MultiBatchHeader<...>]
) -> Result<bool, ProofError> {
    // CHECK 3: computed_root == expected_root (global_root)
    let root_match = computed_root.as_slice() == expected_root.as_slice();
    if !root_match {
        println!("🔍 SABV5: Root mismatch - computed != expected (global_root)");
        return Ok(false);  // Fraud detected
    }
    Ok(true)
}
```

---

## 3. ĐẦU RA (OUTPUT)

### Return Type: `Result<(bool, Vec<MultiBatchHeader<...>>), ProofError>`

**Output:**

1. **`integrity_verified`**: `bool`
   - **`true`**: Tất cả 3 checks passed, không có fraud
   - **`false`**: Có ít nhất 1 check failed, fraud detected

2. **`rebalanced_blocks`**: `Vec<MultiBatchHeader<...>>`
   - Blocks đã được rebalance bởi LMTR4 (Algorithm 2)
   - Dùng cho SP1 proving nếu `integrity_verified = true`
   - Nếu fraud detected, vẫn return rebalanced_blocks (để debug/logging)

---

## 4. LOGIC XỬ LÝ TRONG V5

### Trong `ppgen_sabv_lmtr5.rs`:

```rust
// Apply SABV5 verification
let sabv5_start = Instant::now();
let (integrity_verified, rebalanced_blocks) = sabv5_algorithm
    .verify_aggregated_blocks(&blocks, &global_root)  // <-- Pass expected_global_root
    .expect("SABV5 verification failed");
let sabv5_time = sabv5_start.elapsed();

// **V5 FIX**: Early exit if fraud detected
if !integrity_verified {
    error!("❌ SABV5: Fraud detected! Aborting SP1 proving.");
    error!("⚠️  SABV5 REAL integrity verification FAILED");
    
    if !args.allow_fraud_testing {
        error!("🛑 Exiting immediately to prevent wasting resources on fraudulent data");
        std::process::exit(1);  // Early exit!
    } else {
        warn!("⚠️  Testing mode enabled: Continuing SP1 despite fraud detection");
    }
} else {
    info!("✅ SABV5 REAL integrity verified completely");
}

// Continue với SP1 proving nếu integrity_verified = true
// (chỉ khi không có fraud hoặc allow_fraud_testing = true)
```

---

## 5. CÁC LOẠI GIAN LẬN CỤ THỂ

### A. Wrong Global Root

**Input:**
```
blocks: Correct blocks với valid data
expected_global_root: Wrong global_root (không match với blocks)
```

**Detection:**
- CHECK 3: `computed_root ≠ expected_global_root`
- Result: `integrity_verified = false`

**Output:**
- Early exit (exit code 1)
- Không chạy SP1 proving
- Time: ~SABV5 processing time (seconds)

**Cách test:**
```bash
# Pass wrong_global_root vào verify_aggregated_blocks
cargo run --release --bin ppgen_sabv_lmtr5 -- \
    --n-exits 10 \
    --validator-nodes 5 \
    --wrong-global-root "0x0000..."  # <-- Wrong root
```

---

### B. Tampered Blocks

**Input:**
```
blocks: Blocks bị modify (content changed)
expected_global_root: Correct global_root
```

**Detection:**
- CHECK 1 hoặc CHECK 2: Roots không match
- Result: `integrity_verified = false`

**Output:**
- Early exit (exit code 1)
- Không chạy SP1 proving
- Time: ~SABV5 processing time (seconds)

---

### C. Missing Blocks

**Input:**
```
blocks: Blocks thiếu một số blocks
expected_global_root: Correct global_root
```

**Detection:**
- CHECK 1: Roots không match (do missing blocks)
- CHECK 2: Original blocks không present trong rebalanced
- Result: `integrity_verified = false`

**Output:**
- Early exit (exit code 1)
- Không chạy SP1 proving
- Time: ~SABV5 processing time (seconds)

---

### D. Duplicate Blocks

**Input:**
```
blocks: Blocks có duplicates
expected_global_root: Correct global_root
```

**Detection:**
- CHECK 2: Extra blocks detected (`no_extra_blocks = false`)
- Result: `integrity_verified = false`

**Output:**
- Early exit (exit code 1)
- Không chạy SP1 proving
- Time: ~SABV5 processing time (seconds)

---

### E. Sharding/Merge Error

**Input:**
```
blocks: Blocks divided incorrectly
expected_global_root: Correct global_root
```

**Detection:**
- CHECK 1: `r ≠ r'` (internal inconsistency)
- Result: `integrity_verified = false`

**Output:**
- Early exit (exit code 1)
- Không chạy SP1 proving
- Time: ~SABV5 processing time (seconds)

---

## 6. SO SÁNH VỚI BASELINE

### BASELINE (ppgen.rs)

**Input:**
- `blocks`: Vec<MultiBatchHeader<...>>
- **KHÔNG có `expected_global_root`**
- **KHÔNG có SABV5 layer**

**Process:**
```
blocks → Direct SP1 proving → Full proof generation
```

**Fraud Detection:**
- ❌ **KHÔNG** (không có SABV5 layer)
- Chạy full SP1 proving ngay cả với fraudulent data

**Output:**
- Full SP1 proof (hoặc error ở cuối nếu SP1 detect)
- Time: ~Full SP1 proving time (minutes/hours)

---

### V5 (ppgen_sabv_lmtr5.rs)

**Input:**
- `blocks`: Vec<MultiBatchHeader<...>>
- `expected_global_root`: AggDigest (from blockchain)
- **CÓ SABV5 layer**

**Process:**
```
blocks → SABV5 verification → Early exit nếu fraud → SP1 proving (nếu không fraud)
```

**Fraud Detection:**
- ✅ **CÓ** (SABV5 layer với 3 checks)
- Phát hiện fraud TRƯỚC khi chạy SP1 proving

**Output:**
- Early exit (exit 1) nếu fraud detected
- Hoặc SP1 proof nếu không có fraud
- Time:
  - Fraud case: ~SABV5 processing time (seconds)
  - Normal case: ~SABV5 time + SP1 proving time

---

## 7. KẾT LUẬN

### ✅ V5 phát hiện được:

1. **Wrong global_root** (CHECK 3)
   - Blocks không match với blockchain state
   - Pass wrong_global_root → Fraud detected

2. **Tampered blocks** (CHECK 1, CHECK 2)
   - Blocks bị modify
   - Rebalancing changed content

3. **Missing blocks** (CHECK 1, CHECK 2)
   - Thiếu blocks trong shards
   - Original blocks không present

4. **Duplicate blocks** (CHECK 2)
   - Blocks bị duplicate
   - Extra blocks detected

5. **Sharding/merge errors** (CHECK 1)
   - Blocks divided incorrectly
   - Merge process error

### ✅ Early exit mechanism:

- Phát hiện fraud → `exit(1)` ngay
- Tiết kiệm thời gian (không chạy SP1 proving)
- Tiết kiệm tài nguyên (CPU, RAM, disk)

### ✅ So với baseline:

| Metric | Baseline | V5 |
|--------|----------|-----|
| Fraud Detection | ❌ NO | ✅ YES |
| Detection Stage | N/A | SABV5 (early) |
| Time (fraud case) | ~Full SP1 | ~SABV5 (seconds) |
| Resource usage | High (full SP1) | Low (early exit) |
| Security layer | SP1 only | SABV5 + SP1 |

---

## 8. CÁCH TEST FRAUD DETECTION

### Test Wrong Global Root:

```bash
# 1. Generate wrong_global_root
WRONG_ROOT="0x$(openssl rand -hex 32)"

# 2. Pass vào V5 (cần modify code để add --wrong-global-root parameter)
cargo run --release --bin ppgen_sabv_lmtr5 -- \
    --n-exits 10 \
    --validator-nodes 5 \
    --wrong-global-root "$WRONG_ROOT" \
    --proof-dir ./proofs/fraud_test

# Expected: Fraud detected, early exit (exit code 1)
```

### Test với scripts:

```bash
# Sử dụng fraud_detection_comparison.sh
./fraud_detection_comparison.sh 10 wrong_global_root
```

---

## 9. LƯU Ý QUAN TRỌNG

### ⚠️ CHECK 3 (global_root verification):

- CHECK 3 được implement trong `verify_integrity_with_blocks()`
- **Cần verify xem có được gọi trong `verify_aggregated_blocks()` không**
- Nếu không được gọi, cần thêm logic để check CHECK 3

### ⚠️ Fraud injection:

- Để test fraud, cần pass `wrong_global_root` vào `verify_aggregated_blocks()`
- Hiện tại `ppgen_sabv_lmtr5.rs` không có `--wrong-global-root` parameter
- Cần add parameter này để test fraud detection

### ⚠️ Baseline comparison:

- Baseline không có SABV5 layer
- Để so sánh công bằng, cần inject fraud vào cả baseline và V5
- Baseline sẽ chạy full SP1 proving với fraud data
- V5 sẽ phát hiện fraud sớm và exit


