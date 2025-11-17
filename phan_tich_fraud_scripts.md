# PHÂN TÍCH SCRIPTS FRAUD DETECTION

## TỔNG QUAN

Các scripts đã được tạo để chứng minh **V5 phát hiện gian lận sớm hơn baseline**, nhưng có **vấn đề quan trọng** cần được fix trước khi chạy.

---

## 1. PHÂN TÍCH TỪNG SCRIPT

### 1.1 `fraud_detection_comparison.sh` (Main Script)

#### ✅ Điểm mạnh:
- **Cấu trúc rõ ràng**: 4 bước (Generate → Baseline → V5 → Compare)
- **Đo thời gian chính xác**: Dùng `/usr/bin/time -v` để capture Elapsed, User, System time
- **Parse log tốt**: Extract metrics từ log files (fraud detection, timing, exit codes)
- **Tạo report chi tiết**: Comparison file với đầy đủ thông tin
- **Error handling**: Handle exit code của V5 (expect exit 1 khi fraud detected)

#### ❌ Vấn đề lớn:

**1. KHÔNG thực sự inject fraud vào test execution:**
```bash
# Baseline chạy với normal data (không có fraud)
/usr/bin/time -v cargo run --release \
    -p pessimistic-proof-test-suite \
    --bin ppgen \
    -- \
    --n-exits "$N" \
    --n-imported-exits "$N" \
    --proof-dir "$PROOF_DIR/baseline_n${N}" \

# V5 cũng chạy với normal data (không có fraud)
/usr/bin/time -v cargo run --release \
    -p pessimistic-proof-test-suite \
    --bin ppgen_sabv_lmtr5 \
    -- \
    --n-exits "$N" \
    --validator-nodes 5 \
    --proof-dir "$PROOF_DIR/v5_n${N}" \
```

**Vấn đề**: 
- Fraud data file (`fraud_data_n${N}_${FRAUD_TYPE}.json`) được tạo nhưng **không được sử dụng**
- Baseline và V5 đều chạy với **normal data** (không có fraud)
- Không có cách nào để inject wrong_global_root vào test execution

**2. Baseline không nhận fraud parameter:**
- `ppgen.rs` không có `--wrong-global-root` hoặc `--fraud-data` option
- Cần modify code để inject fraud

**3. V5 không nhận fraud parameter:**
- `ppgen_sabv_lmtr5.rs` không có `--wrong-global-root` option
- Cần pass wrong_global_root vào SABV5 để fraud được detect

---

### 1.2 `generate_fraud_data.sh`

#### ✅ Điểm mạnh:
- **Fallback mechanism**: Tạo manual JSON nếu binary không có
- **Structured data**: Tạo JSON file với metadata

#### ❌ Vấn đề:
- **JSON chỉ là metadata**: Không được sử dụng trong actual test execution
- **Fraud không được inject**: File chỉ chứa thông tin về fraud, không inject vào code

---

### 1.3 `run_all_fraud_tests.sh`

#### ✅ Điểm mạnh:
- **Batch testing**: Chạy nhiều combinations (N values × fraud types)
- **Summary tracking**: Track PASSED/FAILED và tạo summary
- **Error handling**: Handle errors từ comparison script

#### ⚠️ Vấn đề tiềm ẩn:
- **Phụ thuộc vào comparison script**: Nếu có bug, tất cả tests fail
- **Không có validation**: Không check fraud data trước khi chạy

---

## 2. VẤN ĐỀ CHÍNH

### ❌ VẤN ĐỀ LỚN NHẤT: **KHÔNG INJECT FRAUD VÀO TEST EXECUTION**

Hiện tại, scripts:
1. ✅ Tạo fraud data file (metadata)
2. ❌ **KHÔNG sử dụng fraud data trong test execution**
3. ❌ Baseline và V5 đều chạy với **normal data**
4. ❌ Không có cách nào để pass wrong_global_root vào SABV5

**Kết quả**: Scripts sẽ **KHÔNG chứng minh được** V5 phát hiện fraud sớm hơn vì không có fraud được inject!

---

## 3. CÁCH FIX

### 3.1 Giải pháp 1: Add CLI parameter cho V5 (Recommended)

**Modify `ppgen_sabv_lmtr5.rs`:**

```rust
#[derive(Parser, Debug)]
struct PPGenArgs {
    // ... existing args ...
    
    /// Wrong global_root for fraud testing (optional)
    #[arg(long)]
    wrong_global_root: Option<String>,
}

// In main():
let global_root = if let Some(wrong_root_hex) = args.wrong_global_root {
    // Use wrong_global_root for fraud testing
    let wrong_root_bytes = hex::decode(&wrong_root_hex)
        .expect("Invalid wrong_global_root hex");
    AggDigest::try_from(wrong_root_bytes.as_slice())
        .expect("Invalid wrong_global_root length")
} else {
    // Use correct global_root
    global_roots.last().copied().unwrap_or_else(|| {
        AggDigest::default()
    })
};

// SABV5 sẽ detect r != global_root và return integrity_verified=false
let (integrity_verified, rebalanced_blocks) = sabv5_algorithm
    .verify_aggregated_blocks(&blocks, &global_root)
    .expect("SABV5 verification failed");
```

**Update script:**

```bash
# V5 with wrong_global_root
WRONG_ROOT="0x$(openssl rand -hex 32)"
cargo run --release \
    -p pessimistic-proof-test-suite \
    --bin ppgen_sabv_lmtr5 \
    -- \
    --n-exits "$N" \
    --validator-nodes 5 \
    --wrong-global-root "$WRONG_ROOT" \
    --proof-dir "$PROOF_DIR/v5_n${N}"
```

### 3.2 Giải pháp 2: Environment variable

**Modify code để check environment variable:**

```rust
let global_root = if let Ok(wrong_root_hex) = std::env::var("FRAUD_GLOBAL_ROOT") {
    // Use wrong_global_root from env var
    let wrong_root_bytes = hex::decode(&wrong_root_hex)
        .expect("Invalid FRAUD_GLOBAL_ROOT hex");
    AggDigest::try_from(wrong_root_bytes.as_slice())
        .expect("Invalid wrong_global_root length")
} else {
    // Use correct global_root
    global_roots.last().copied().unwrap_or_else(|| {
        AggDigest::default()
    })
};
```

**Update script:**

```bash
# V5 with wrong_global_root via env var
WRONG_ROOT="0x$(openssl rand -hex 32)"
export FRAUD_GLOBAL_ROOT="$WRONG_ROOT"
cargo run --release \
    -p pessimistic-proof-test-suite \
    --bin ppgen_sabv_lmtr5 \
    -- \
    --n-exits "$N" \
    --validator-nodes 5 \
    --proof-dir "$PROOF_DIR/v5_n${N}"
```

### 3.3 Giải pháp 3: Modify baseline để chạy với fraud

**Baseline cũng cần fraud để so sánh công bằng:**

```rust
// Modify ppgen.rs để accept wrong_global_root
// Hoặc tạo blocks với wrong data

// Baseline sẽ chạy full SP1 proving với fraud data
// SP1 có thể detect fraud ở cuối (hoặc không detect)
// Nhưng đã lãng phí thời gian proving
```

---

## 4. LOGIC FRAUD DETECTION TRONG V5

### 4.1 SABV5 Fraud Detection Logic

```rust
// In sabv5.rs
pub fn verify_aggregated_blocks(
    &mut self,
    blocks: &[MultiBatchHeader<...>],
    expected_global_root: &AggDigest,  // <-- Nếu pass wrong_global_root ở đây
) -> Result<(bool, Vec<...>), ProofError> {
    // ... process blocks ...
    
    // CHECK 3: computed_root == expected_global_root
    let root_match = computed_root.as_slice() == expected_global_root.as_slice();
    if !root_match {
        // FRAUD DETECTED!
        return Ok((false, rebalanced_blocks));  // integrity_verified = false
    }
    
    Ok((true, rebalanced_blocks))  // integrity_verified = true
}
```

### 4.2 V5 Early Exit Logic

```rust
// In ppgen_sabv_lmtr5.rs
let (integrity_verified, rebalanced_blocks) = sabv5_algorithm
    .verify_aggregated_blocks(&blocks, &global_root)  // <-- Pass wrong_global_root
    .expect("SABV5 verification failed");

if !integrity_verified {  // <-- Fraud detected!
    error!("❌ SABV5: Fraud detected! Aborting SP1 proving.");
    
    if !args.allow_fraud_testing {
        std::process::exit(1);  // <-- Early exit!
    }
}

// SP1 proving (only if integrity_verified = true)
```

### 4.3 Kết quả mong đợi:

**V5 với wrong_global_root:**
```
SABV5 verification → r != global_root → integrity_verified = false → Early exit (exit 1)
Time: ~SABV5 processing time (seconds)
```

**Baseline với wrong_global_root:**
```
Direct SP1 proving → Full proving → Detect/Not detect ở cuối
Time: ~Full SP1 proving time (minutes/hours)
```

**Time savings:**
- V5: Fraud detected ở SABV5 (early, nhanh)
- Baseline: Fraud detected ở SP1 (late, chậm)
- **V5 tiết kiệm thời gian đáng kể**

---

## 5. ĐỀ XUẤT FIX NGAY

### 5.1 Cần làm gì:

1. **Add `--wrong-global-root` parameter vào `ppgen_sabv_lmtr5.rs`**
2. **Update `fraud_detection_comparison.sh` để sử dụng wrong_global_root**
3. **Update `generate_fraud_data.sh` để tạo wrong_global_root hex**
4. **Test với N=1 trước** để verify logic

### 5.2 Code changes needed:

**File: `agglayer/crates/pessimistic-proof-test-suite/src/bin/ppgen_sabv_lmtr5.rs`**

```rust
#[derive(Parser, Debug)]
struct PPGenArgs {
    // ... existing ...
    
    /// Wrong global_root for fraud testing (hex string, optional)
    #[arg(long)]
    wrong_global_root: Option<String>,
}
```

**In main():**
```rust
let global_root = if let Some(wrong_root_hex) = args.wrong_global_root {
    info!("🔴 FRAUD TEST MODE: Using wrong_global_root");
    let hex_str = wrong_root_hex.strip_prefix("0x").unwrap_or(&wrong_root_hex);
    let wrong_root_bytes = hex::decode(hex_str)
        .expect("Invalid wrong_global_root hex");
    AggDigest::try_from(wrong_root_bytes.as_slice())
        .expect("Invalid wrong_global_root length (must be 32 bytes)")
} else {
    global_roots.last().copied().unwrap_or_else(|| {
        AggDigest::default()
    })
};
```

---

## 6. KẾT LUẬN

### ✅ Scripts hiện tại:
- **Cấu trúc tốt**: 4 bước rõ ràng
- **Logic parse log tốt**: Extract metrics chính xác
- **Report format tốt**: So sánh chi tiết

### ❌ Vấn đề lớn:
- **KHÔNG inject fraud**: Scripts không thực sự inject wrong_global_root vào test
- **Cần modify code**: Add `--wrong-global-root` parameter vào V5

### 💡 Next steps:
1. Add `--wrong-global-root` parameter vào `ppgen_sabv_lmtr5.rs`
2. Update `fraud_detection_comparison.sh` để sử dụng wrong_global_root
3. Test với N=1 để verify logic
4. Chạy full tests sau khi verify

---

## 7. EXPECTED RESULTS SAU KHI FIX

### V5 với wrong_global_root:
```
⏱️  SABV5 REAL verification + rebalancing time: ~X seconds
❌ SABV5: Fraud detected! Aborting SP1 proving.
🛑 Exiting immediately...
Exit code: 1
Total time: ~X seconds (early exit)
```

### Baseline với wrong_global_root:
```
🔄 Running SP1 proving...
⏱️  Elapsed time: ~Y minutes/hours
Exit code: 0 (hoặc 1 nếu SP1 detect)
Total time: ~Y minutes/hours (full proving)
```

### Comparison:
```
Time savings: V5 saved ~(Y - X) time by detecting fraud early
Security advantage: V5 has SABV5 layer, Baseline does not
```

---

**Status**: Scripts sẵn sàng, nhưng cần **modify code** để inject fraud trước khi chạy!


