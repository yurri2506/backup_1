# AggLayer ↔ AggSandbox Multi-L2 Integration

Repo này chứa **artifacts, scripts và hướng dẫn** để chạy experiments Multi-L2 với AggLayer + AggSandbox.

## 📦 Nội dung

```
agglayer_aggsandbox/
├── QUICKSTART.md                     # ⭐ BẮT ĐẦU TẠI ĐÂY
├── SETUP.md                          # Setup chi tiết
├── README.md                         # File này
├── artifacts/
│   ├── bridge_test_data.json         # Sample: 1 L2
│   ├── bridge_test_data_fixed.json   # Sample: 1 L2 (array format)
│   ├── bridge_test_data_multi_l2.json # Sample: nhiều L2
│   └── 1-certificate-*.json          # Proof mẫu đã tạo
├── scripts/
│   ├── run_multi_l2_experiments.sh   # ⭐ Chạy tất cả experiments
│   ├── stop_experiments.sh           # Dừng experiments
│   └── test_integration.sh           # Test integration đơn giản
└── logs/                             # Logs sẽ được tạo tại đây
    └── multi_l2/                     # (git ignore)
```

## 🚀 Chạy ngay (3 bước)

### 1. Clone repos
```bash
git clone https://github.com/agglayer/agglayer
git clone https://github.com/agglayer/aggsandbox
git clone <your-repo-url> agglayer_aggsandbox
```

### 2. Build
```bash
cd agglayer && cargo build --release && cd ..
cd aggsandbox && make install && cd ..
```

### 3. RUN!
```bash
cd agglayer_aggsandbox/scripts
./run_multi_l2_experiments.sh
```

**Xong!** Tất cả sẽ chạy tự động trong tmux.

👉 **Xem QUICKSTART.md để biết thêm chi tiết.**

## 🎯 Mục đích

- Test **pessimistic proofs** (Baseline + SABV+LMTR) với **nhiều L2 chains**
- So sánh performance: 1-L2 vs Multi-L2
- Tạo dữ liệu thật từ AggSandbox bridge operations
- End-to-end workflow: Bridge → Proof → Verify

## 📊 Experiments tự động

Scripts sẽ chạy:
- **Baseline:** N=1,5,10,20,50 exits
- **SABV+LMTR:** N=1,5,10,20,50 exits với 5 validators
- **AggSandbox:** Multi-L2 mode (L1 + L2-1 + L2-2)
- **Monitoring:** dstat theo dõi CPU/RAM/disk

## 🔗 Links

- [AggLayer](https://github.com/agglayer/agglayer)
- [AggSandbox](https://github.com/agglayer/aggsandbox)
- [SP1](https://github.com/succinctlabs/sp1)

## 📝 Notes

- **Không sửa đổi** code trong agglayer/ hay aggsandbox/
- Chỉ chứa artifacts, scripts và configs
- Logs ở trong `logs/` (git ignore)
- Requirements: Linux, ≥64GB RAM, ≥16 cores

## 🐛 Issues?

Xem **QUICKSTART.md** phần Troubleshooting.
