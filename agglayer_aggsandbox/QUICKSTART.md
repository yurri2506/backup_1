# 🚀 Quick Start - Multi-L2 Experiments

Chỉ cần 3 bước để chạy experiments!

## Bước 1: Clone repos (lần đầu)

```bash
# Clone AggLayer
git clone https://github.com/agglayer/agglayer
cd agglayer && cargo build --release && cd ..

# Clone AggSandbox
git clone https://github.com/agglayer/aggsandbox
cd aggsandbox && make install && cd ..

# Clone repo này (artifacts + scripts)
git clone <your-repo-url> agglayer_aggsandbox
```

## Bước 2: Chạy experiments

```bash
cd agglayer_aggsandbox/scripts
./run_multi_l2_experiments.sh
```

**Xong!** Scripts sẽ tự động:
- ✅ Khởi động AggSandbox multi-L2
- ✅ Setup SP1 local server
- ✅ Chạy Baseline experiments (N=1,5,10,20,50)
- ✅ Chạy SABV+LMTR experiments (N=1,5,10,20,50)
- ✅ Monitor resources (dstat)

## Bước 3: Theo dõi

### Attach vào tmux session
```bash
tmux attach -t multi_l2_experiments
```

### Xem logs real-time
```bash
# Tất cả logs
tail -f ../logs/multi_l2/run.log

# Baseline
tail -f ../logs/multi_l2/baseline/proof_*.log

# SABV+LMTR
tail -f ../logs/multi_l2/sabv_lmtr/proof_*.log

# Resources
tail -f ../logs/multi_l2/dstat.log
```

### Dừng experiments
```bash
./stop_experiments.sh
```

## Tùy chỉnh (optional)

### Thay đổi exit counts
```bash
EXIT_COUNTS="1 10 50 100" ./run_multi_l2_experiments.sh
```

### Thay đổi số L2
```bash
NUM_L2=3 ./run_multi_l2_experiments.sh
```

### Custom paths
```bash
AGGLAYER_DIR=/path/to/agglayer \
AGGSANDBOX_DIR=/path/to/aggsandbox \
./run_multi_l2_experiments.sh
```

## Kết quả

Sau khi chạy xong, kiểm tra:
```bash
ls -lh ../logs/multi_l2/

# Baseline proofs
ls ../logs/multi_l2/baseline/proofs/

# SABV+LMTR proofs
ls ../logs/multi_l2/sabv_lmtr/proofs/

# Metrics
cat ../logs/multi_l2/dstat.log
```

## Troubleshooting

### Lỗi "docker not found"
```bash
sudo apt-get install -y docker.io docker-compose
sudo usermod -aG docker $USER
# Logout & login lại
```

### Lỗi "aggsandbox not found"
```bash
cd ../aggsandbox
make install
```

### Lỗi "cargo not found"
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
```

### Experiments bị treo
```bash
# Check tmux
tmux list-sessions
tmux attach -t multi_l2_experiments

# Check logs
tail -100 ../logs/multi_l2/run.log

# Restart
./stop_experiments.sh
./run_multi_l2_experiments.sh
```

## Requirements

- **OS:** Linux (Ubuntu 20.04+)
- **RAM:** ≥64GB
- **CPU:** ≥16 cores
- **Disk:** ≥100GB free
- **Tools:** docker, rust, tmux, dstat
