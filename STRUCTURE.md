# Cấu Trúc Files Đã Tổ Chức

## 📁 Cấu Trúc Mới

```
/home/ubuntu/thanhhuyen/
├── docs/                    # Documentation
│   ├── TMUX_HUONG_DAN.md
│   ├── BASELINE_VS_V5_FRAUD_HANDLING.md
│   ├── CÁC_LOẠI_GIAN_LẬN_PHÁT_HIỆN_SỚM_CHI_TIẾT.md
│   ├── THỰC_NGHIỆM_PHÁT_HIỆN_GIAN_LẬN_CHI_TIẾT.md
│   ├── GIẢI_THÍCH_CHI_TIẾT_PROOF_VS_DATA_CORRECTNESS.md
│   ├── kiem_tra_paper.txt
│   └── kiem_tra_thuc_nghiem.txt
│
├── reports/                 # Reports & Data
│   ├── bang_so_lieu_v5_hien_tai.txt
│   ├── tom_tat_so_lieu_v5_moi.txt
│   ├── thong_ke_v5_hien_tai.txt
│   ├── bao_cao_kiem_tra_loi.txt
│   ├── fix_oom_report.txt
│   ├── fraud_test_progress_report.md
│   ├── kiem_tra_chi_tiet_v5.txt
│   ├── v4_tong_hop.txt
│   ├── v5_best_runs.txt
│   ├── v5_tong_hop.txt
│   └── thuc_nghiem_3_ngu_canh.txt
│
├── scripts/
│   ├── experiments/         # Experiment Scripts
│   │   ├── run_v5_benchmark.sh
│   │   ├── run_aggsandbox_all.sh
│   │   ├── run_fraud_tests_multi_n.sh
│   │   ├── run_v5_multi_tmux.sh
│   │   ├── wait_and_run_benchmark.sh
│   │   ├── sabv_lmtr_v4.sh
│   │   ├── sabv_lmtr_v5.sh
│   │   ├── sabv_lmtr_tmx.sh
│   │   ├── sabv_lmtr3_tmx.sh
│   │   ├── sabv_lmtr4_tmx.sh
│   │   ├── sabv2_lmtr2_tmx.sh
│   │   └── baseline_tmx.sh
│   │
│   └── utils/               # Utility Scripts
│       ├── cleanup_tmux.sh
│       ├── demo_fraud_detection.sh
│       ├── generate_aggsandbox_report.sh
│       └── sp1_local_server.sh
│
├── logs/                    # Logs (KHÔNG DI CHUYỂN)
├── proofs/                  # Proofs (KHÔNG DI CHUYỂN)
└── aggsandbox_data/         # AggSandbox data (đã có)
```

## ✅ Đã Di Chuyển

- **34 files** đã được di chuyển vào cấu trúc mới
- **Symlinks** đã được tạo cho backward compatibility
- **Scripts đang chạy** được giữ nguyên path thông qua symlinks

## ⚠️ Lưu Ý

1. **Logs và Proofs**: Không di chuyển - đang được sử dụng
2. **Scripts đang chạy**: Có symlinks ở root để đảm bảo hoạt động
3. **Experiments đang chạy**: Không bị ảnh hưởng

## 📝 Cập nhật Paths

Nếu cần update paths trong scripts mới, tham khảo:
- Scripts: `scripts/experiments/`
- Reports: `reports/`
- Docs: `docs/`

