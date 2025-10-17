# Setup Multi-L2 Experiments trên máy mới

## 1. Prerequisites
```bash
# Docker & Docker Compose
docker --version
docker-compose --version

# Rust & Cargo
rustup --version
cargo --version

# Tools
sudo apt-get install -y dstat stress-ng tmux jq
```

## 2. Clone repos
```bash
# AggLayer (pessimistic proof)
git clone https://github.com/agglayer/agglayer
cd agglayer && cargo build --release && cd ..

# AggSandbox (bridge environment)
git clone https://github.com/agglayer/aggsandbox
cd aggsandbox && make install && cd ..

# Artifacts repo (này)
git clone <your-repo-url> agglayer_aggsandbox
```

## 3. Chạy multi-L2 experiments

### A. Khởi động AggSandbox multi-L2
```bash
cd aggsandbox
cp .env.example .env
source .env
aggsandbox start --multi-l2 --detach
aggsandbox status
```

### B. Tạo bridge data (nhiều L2)
```bash
# L1 -> L2-1
aggsandbox bridge asset --network-id 0 --destination-network-id 1 --amount 1000000000000000000 --token-address 0x0000000000000000000000000000000000000000

# L1 -> L2-2
aggsandbox bridge asset --network-id 0 --destination-network-id 2 --amount 2000000000000000000 --token-address 0x0000000000000000000000000000000000000000

# Xem bridges
aggsandbox show bridges --network-id 0
aggsandbox show bridges --network-id 1
aggsandbox show bridges --network-id 2
```

### C. Chạy AggLayer proof generation
```bash
cd ../agglayer

# Test với data mẫu có sẵn
cargo run --release -p pessimistic-proof-test-suite --bin ppgen -- \
  --n-exits 4 --n-imported-exits 4 \
  --proof-dir ./multi_l2_proofs \
  --sample-path ../agglayer_aggsandbox/artifacts/bridge_test_data_multi_l2.json

# Baseline multi-L2
export SP1_PROVER=cpu
cargo run --release -p pessimistic-proof-test-suite --bin ppgen -- \
  --n-exits 10 --n-imported-exits 10 \
  --proof-dir ./logs/multi_l2_baseline/proofs

# SABV+LMTR multi-L2
cargo run --release -p pessimistic-proof-test-suite --bin ppgen_sabv_lmtr -- \
  --n-exits 10 \
  --proof-dir ./logs/multi_l2_sabv_lmtr/proofs \
  --validator-nodes 5
```

## 4. Experiments tự động (tmux)
```bash
cd ../agglayer_aggsandbox/scripts
# Sửa script để phù hợp với multi-L2
./test_integration.sh
```

## 5. Thu thập metrics
```bash
# Tạo script monitoring
dstat --time --cpu --mem --disk --proc --load 1 > multi_l2_dstat.log &
DSTAT_PID=$!

# Chạy experiments...

# Dừng monitoring
kill $DSTAT_PID
```

## 6. So sánh với baseline đã có
- Baseline (1 L2): ~/thanhhuyen/logs/baseline/
- SABV+LMTR (1 L2): ~/thanhhuyen/logs/sabv_lmtr/
- Multi-L2: ./logs/multi_l2_*/

## Notes
- Multi-L2 tốn thêm ~500MB RAM, ~10-15% CPU per L2
- Khuyến nghị máy có >=64GB RAM, >=16 cores
- Có thể chạy song song nhiều experiments trong tmux sessions
