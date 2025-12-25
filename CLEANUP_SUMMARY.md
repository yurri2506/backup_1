# Tổng Kết Dọn Dẹp Files

## ✅ Đã Hoàn Thành

### 1. Di Chuyển Files vào Cấu Trúc Mới
- **34 files** đã được di chuyển vào:
  - `docs/` - Documentation
  - `reports/` - Reports & Data
  - `scripts/experiments/` - Experiment scripts
  - `scripts/utils/` - Utility scripts

### 2. Xóa Symlinks Thừa
- **11 symlinks .sh** đã được xóa khỏi root
- **Giữ lại 1 symlink**: `run_v5_benchmark.sh` (đang được tmux session sử dụng)

## 📁 Cấu Trúc Hiện Tại

```
/home/ubuntu/thanhhuyen/
├── scripts/
│   ├── experiments/    # 12 scripts
│   └── utils/          # 4 scripts
├── docs/               # 8 files
├── reports/            # 12 files
└── run_v5_benchmark.sh # 1 symlink (cho tmux)
```

## ⚠️ Lưu Ý

- `run_v5_benchmark.sh` vẫn ở root vì đang được tmux session `v5_benchmark` sử dụng
- Tất cả files khác đã được tổ chức vào cấu trúc mới
- Không ảnh hưởng đến experiments đang chạy

## 📝 Sử Dụng Mới

Thay vì:
```bash
./run_v5_benchmark.sh
```

Dùng:
```bash
./scripts/experiments/run_v5_benchmark.sh
```

Hoặc vẫn có thể dùng `./run_v5_benchmark.sh` (symlink).
