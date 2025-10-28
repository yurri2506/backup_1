#!/bin/bash

set -e

PROOF_DIR="/home/ubuntu/proofs/v4"
LOG_DIR="/home/ubuntu/logs"
N_VALUES=(1 5 10 20 50 100 200 500 700)

cd ~/thanhhuyen/agglayer/crates/pessimistic-proof-test-suite

echo "🚀 Starting V4 Sequential Benchmark"
echo "N values: ${N_VALUES[@]}"
echo "Proof dir: $PROOF_DIR"
echo "Log dir: $LOG_DIR"
echo ""

for N in "${N_VALUES[@]}"; do
    echo "=========================================="
    echo "🔢 Starting N=$N"
    echo "=========================================="
    echo ""
    
    LOG_FILE="$LOG_DIR/v4_n${N}.log"
    START_TIME=$(date +%s)
    
    # Run with CPU/RAM monitoring in background
    (
        while kill -0 $$ 2>/dev/null; do
            ps aux | grep ppgen_sabv_lmtr4 | grep -v grep | awk '{print $3,$4}' >> "$LOG_DIR/v4_n${N}_system.csv" 2>/dev/null || true
            sleep 5
        done
    ) &
    MONITOR_PID=$!
    
    # Run the benchmark
    cargo run --release --bin ppgen_sabv_lmtr4 -- \
        --n-exits "$N" \
        --validator-nodes 3 \
        --proof-dir "$PROOF_DIR" \
        2>&1 | tee "$LOG_FILE"
    
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    
    # Kill monitor
    kill $MONITOR_PID 2>/dev/null || true
    
    echo ""
    echo "✅ N=$N completed in ${DURATION}s"
    echo ""
done

echo "=========================================="
echo "🎉 All benchmarks completed!"
echo "=========================================="

