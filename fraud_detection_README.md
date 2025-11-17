# Fraud Detection Comparison Scripts

## Mục đích

Chứng minh rằng **V5 (SABV5 + LMTR4) phát hiện gian lận sớm hơn baseline** bằng cách:

1. **Baseline**: Chạy full SP1 proving với fraud data (không phát hiện fraud ở preprocessing level)
2. **V5**: Phát hiện fraud ở SABV5 level và dừng sớm (không cần chạy SP1 proving)

## Cấu trúc Scripts

### 1. `fraud_detection_comparison.sh`
**Main script** - Chạy so sánh cho một N và fraud type cụ thể

```bash
./fraud_detection_comparison.sh [N] [fraud_type]
```

**Ví dụ:**
```bash
./fraud_detection_comparison.sh 10 wrong_global_root
```

**Chức năng:**
- Tạo fraud test data
- Chạy baseline với fraud data → đo thời gian hoàn thành
- Chạy V5 với fraud data → đo thời gian đến khi phát hiện
- So sánh kết quả

### 2. `generate_fraud_data.sh`
Tạo fraud test data

```bash
./generate_fraud_data.sh [N] [fraud_type] [output_dir]
```

**Fraud types:**
- `wrong_global_root`: Blocks không match với blockchain global_root
- `tampered_blocks`: Blocks bị sửa đổi giữa các bước (r != r')
- `invalid_secret_share`: Secret sharing không hợp lệ
- `missing_blocks`: Thiếu blocks trong shards
- `duplicate_blocks`: Blocks bị duplicate

### 3. `run_all_fraud_tests.sh`
Chạy tất cả các loại fraud tests với nhiều N values

```bash
./run_all_fraud_tests.sh
```

**Test configuration:**
- N values: 1, 10, 100
- Fraud types: wrong_global_root, tampered_blocks

## Kết quả mong đợi

### Baseline (ppgen.rs)
- ❌ **KHÔNG phát hiện fraud** ở preprocessing level
- ⏱️ Chạy **full SP1 proving** với fraud data
- 📊 Thời gian: ~N * (thời gian proving per exit)

### V5 (ppgen_sabv_lmtr5.rs)
- ✅ **Phát hiện fraud** ở SABV5 level (early detection)
- ⏱️ **Dừng sớm** sau khi phát hiện (không chạy SP1 proving)
- 📊 Thời gian: ~(SABV5 processing time) << (SP1 proving time)
- 🎯 **Tiết kiệm thời gian** đáng kể

## Output Files

### Log Files
- `logs/fraud_detection/baseline_n{N}_{fraud_type}_*.log`: Baseline log
- `logs/fraud_detection/v5_n{N}_{fraud_type}_*.log`: V5 log

### Results
- `fraud_detection_results/comparison_n{N}_{fraud_type}_*.txt`: So sánh chi tiết
- `fraud_detection_results/summary_*.txt`: Tổng hợp tất cả tests

## Metrics được đo

1. **Fraud Detection**
   - Baseline: Có phát hiện? (Expected: NO)
   - V5: Có phát hiện? (Expected: YES)
   - Stage phát hiện: SABV5, SP1, etc.

2. **Thời gian**
   - Baseline: Elapsed time, User time, System time
   - V5: Elapsed time, SABV5 processing time, User time, System time

3. **Time Savings**
   - So sánh thời gian giữa baseline và V5
   - Chứng minh V5 tiết kiệm thời gian nhờ early detection

## Usage Example

```bash
# 1. Make scripts executable
chmod +x fraud_detection_comparison.sh
chmod +x generate_fraud_data.sh
chmod +x run_all_fraud_tests.sh

# 2. Run single test
./fraud_detection_comparison.sh 10 wrong_global_root

# 3. Run all tests
./run_all_fraud_tests.sh

# 4. View results
cat fraud_detection_results/comparison_n10_wrong_global_root_*.txt
cat fraud_detection_results/summary_*.txt
```

## Lưu ý

1. **Fraud Injection**: Hiện tại fraud được inject bằng cách thay đổi global_root parameter. Các fraud types khác cần implementation cụ thể.

2. **V5 Early Exit**: V5 sẽ exit với code 1 khi phát hiện fraud (trừ khi dùng `--allow-fraud-testing` flag).

3. **Baseline Behavior**: Baseline sẽ chạy full SP1 proving ngay cả với fraud data, không có early detection.

4. **Test Mode**: Nếu muốn test SP1 với fraud data, dùng `--allow-fraud-testing` flag (chỉ dùng cho testing, không dùng production).

## Kết luận mong đợi

**V5 phát hiện gian lận sớm hơn baseline** nhờ:
1. **SABV5 fraud detection layer** - Phát hiện fraud TRƯỚC khi chạy SP1 proving
2. **Early exit mechanism** - Dừng ngay khi phát hiện, tiết kiệm tài nguyên
3. **Time savings** - Tiết kiệm đáng kể thời gian so với baseline


