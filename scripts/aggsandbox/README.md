# AggSandbox Experiments Scripts

Thư mục chứa các script để chạy experiments với AggSandbox.

## Scripts

### 1. run_all.sh
Script chính để chạy toàn bộ experiments:
- Baseline cho các N values
- V5 (SABV5+LMTR4) cho các N values
- Tự động đo L1 verification metrics

**Usage:**
```bash
./run_all.sh
```

### 2. run_test.sh
Helper script để chạy từng test riêng lẻ (baseline hoặc V5).

**Usage:**
```bash
./run_test.sh <baseline|v5> <N> <sample_path> <log_dir> <proof_dir>
```

### 3. verify_l1.sh
Script để verify proof trên L1 contract và đo metrics.

**Usage:**
```bash
./verify_l1.sh <proof_fixture_json> <summary_file> <log_file>
```

### 4. generate_report.sh
Script để tạo báo cáo từ summary.txt.

**Usage:**
```bash
./generate_report.sh
```

## Logs

Logs được lưu tại: `logs/aggsandbox_exp/`
- `run.log`: Log tổng hợp
- `summary.txt`: Summary CSV format với metrics
- `baseline/`: Proofs và logs baseline
- `v5/`: Proofs và logs V5
