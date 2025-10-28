#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="/home/ubuntu/backup_1/logs/baseline"
BIN_DIR="/home/ubuntu/backup_1/agglayer"
EXIT_COUNTS=(1 10 20 50 100 200 500 700)

mkdir -p "$LOG_DIR"

echo "🚀 CHẠY BASELINE EXPERIMENTS (SKIP SP1)..."

# Start resource monitoring
dstat --time --cpu --mem --disk --proc --load --top-cpu --top-mem 1 > "$LOG_DIR/dstat.log" 2>&1 &
DSTAT_PID=$!

# Start stress testing
stress-ng --cpu 6 --cpu-method all --vm 8 --vm-bytes 8G --vm-keep --timeout 9999s > "$LOG_DIR/stress.log" 2>&1 &
STRESS_PID=$!

# Run experiments
cd "$BIN_DIR"
export SP1_PROVER=cpu
mkdir -p "$LOG_DIR/proofs"

for N in "${EXIT_COUNTS[@]}"; do
    echo "[BASELINE] Starting N=$N" | tee -a "$LOG_DIR/run.log"
    
    for RUN in {1..10}; do
        echo "[BASELINE] N=$N - RUN $RUN/10" | tee -a "$LOG_DIR/run.log"
        
        # Run without SP1 proving (skip the proving part)
        timeout 300 /usr/bin/time -v cargo run --release -p pessimistic-proof-test-suite --bin ppgen -- --n-exits $N --n-imported-exits $N --proof-dir "$LOG_DIR/proofs" > "$LOG_DIR/proof_ppgen_${N}_run${RUN}.no_input.log" 2>&1 || echo "Experiment failed or timed out" | tee -a "$LOG_DIR/run.log"
        
        echo "[BASELINE] N=$N - COMPLETED RUN $RUN/10" | tee -a "$LOG_DIR/run.log"
    done
    
    echo "[BASELINE] ===== COMPLETED N=$N =====" | tee -a "$LOG_DIR/run.log"
done

echo "[BASELINE] ===== ALL EXPERIMENTS COMPLETED =====" | tee -a "$LOG_DIR/run.log"

# Cleanup
kill $DSTAT_PID 2>/dev/null || true
kill $STRESS_PID 2>/dev/null || true

echo "✅ BASELINE EXPERIMENTS HOÀN THÀNH!"
