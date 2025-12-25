# Experiment Scripts

Scripts để chạy các thực nghiệm AggLayer V5 và Baseline.

## Cấu trúc

- `run_v5_benchmark.sh` - V5 benchmark với N values khác nhau
- `run_aggsandbox_all.sh` - Chạy tất cả AggSandbox experiments
- `run_fraud_tests_multi_n.sh` - Fraud detection tests
- `baseline_tmx.sh` - Baseline experiments với tmux
- `sabv_lmtr_*.sh` - Các script cho V3, V4, V5 với LMTR

## Usage

Xem từng script để biết cách sử dụng chi tiết.

## Lưu ý

- Các script này có thể đang được sử dụng bởi tmux sessions
- Không xóa hoặc di chuyển khi experiments đang chạy
- Logs được lưu tại `logs/` directory
