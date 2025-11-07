#!/bin/bash

################################################################################
# V5 BENCHMARK SCRIPT - Sequential Execution (like Baseline)
# 
# Chạy lần lượt từng N, không parallel - giống baseline
# 
# Usage:
#   ./sabv_lmtr_v5.sh [N1] [N2] [N3] ...
# 
# Examples:
#   ./sabv_lmtr_v5.sh 1              # Chạy N=1
#   ./sabv_lmtr_v5.sh 10 50 100      # Chạy N=10, rồi N=50, rồi N=100 (tuần tự)
#   ./sabv_lmtr_v5.sh 1 10 50 100 500 # Chạy tất cả tuần tự
################################################################################

# Don't exit on error - continue with next N even if one fails
set +e

# Configuration
BIN_DIR="/home/ubuntu/thanhhuyen/agglayer"
LOG_DIR="/home/ubuntu/thanhhuyen/logs/v5_seq"
PROOF_DIR="/home/ubuntu/thanhhuyen/proofs/v5"

# Default N values (nếu không có args)
DEFAULT_N_VALUES=(1 10 50 100 500)

################################################################################
# Function: run_benchmark_sequential
# Run benchmarks sequentially (lần lượt) - giống baseline
################################################################################
run_benchmark_sequential() {
    # Get N values from arguments or use defaults
    if [ $# -gt 0 ]; then
        N_VALUES=("$@")
    else
        N_VALUES=("${DEFAULT_N_VALUES[@]}")
    fi
    
    echo "🚀 Starting V5 Sequential Benchmark (lần lượt như baseline)"
    echo "N values: ${N_VALUES[@]}"
    echo "Proof dir: $PROOF_DIR"
    echo "Log dir: $LOG_DIR"
    echo ""
    echo "⚠️  Chạy TUẦN TỰ - mỗi N sẽ chạy xong rồi mới chạy N tiếp theo"
    echo ""
    
    cd "$BIN_DIR"
    
    for N in "${N_VALUES[@]}"; do
        echo "════════════════════════════════════════════════════════════════════════════"
        echo "🔢 Starting N=$N at $(date '+%Y-%m-%d %H:%M:%S')"
        echo "════════════════════════════════════════════════════════════════════════════"
        echo ""
        
        mkdir -p "$LOG_DIR" "$PROOF_DIR"
        LOG_FILE="$LOG_DIR/v5_n${N}.log"
        START_TIME=$(date +%s)
        
        # Run the benchmark - WAIT for completion (sequential)
        # Optimize for maximum CPU usage (16 cores, 64GB RAM)
        export RAYON_NUM_THREADS=16
        export RUST_LOG=sp1_sdk=info,sp1=info
        export SP1_PROVER=cpu
        export SP1_CARGO_PROVE_PATH=/home/ubuntu/.sp1/bin/cargo-prove
        # SP1 optimization settings - adjust based on N to avoid OOM
        # IMPORTANT: Baseline uses DEFAULT settings (SHARD_BATCH_SIZE=1, TRACE_GEN_WORKERS=1)
        # Baseline can run N=700 with ~20-30GB memory
        # V5 was using (4, 8) for N=500 → 64GB+ memory → OOM kill!
        # 
        # Memory usage scales with parallelization:
        #   - SHARD_BATCH_SIZE=4, TRACE_GEN_WORKERS=8 → ~60GB (OK for N<=300, too much for N>=500)
        #   - SHARD_BATCH_SIZE=3, TRACE_GEN_WORKERS=6 → ~45GB (try for N>=500)
        #   - SHARD_BATCH_SIZE=2, TRACE_GEN_WORKERS=4 → ~30-40GB (fallback)
        #   - SHARD_BATCH_SIZE=1, TRACE_GEN_WORKERS=1 → ~15-20GB (safe, like baseline)
        export SHARD_SIZE=2097152          # 2^21 (can keep this)
        if [ "$N" -gt 300 ]; then
            # N>300: Use (3, 6) to avoid OOM - test if this works for N=500,700
            export SHARD_BATCH_SIZE=3          # Process 3 shards in parallel
            export TRACE_GEN_WORKERS=6         # 6 workers
        else
            # N<=300: Use (4, 8) - proven to work for N=100,300
            export SHARD_BATCH_SIZE=4          # Process 4 shards in parallel
            export TRACE_GEN_WORKERS=8         # 8 workers
        fi
        
        # Run benchmark và capture exit code
        /usr/bin/time -v cargo run --release -p pessimistic-proof-test-suite --bin ppgen_sabv_lmtr5 -- \
            --n-exits "$N" \
            --validator-nodes 5 \
            --proof-dir "$PROOF_DIR" \
            --allow-fraud-testing \
            2>&1 | tee "$LOG_FILE"
        
        EXIT_CODE=${PIPESTATUS[0]}
        
        # Continue even if failed (sequential - don't stop)
        END_TIME=$(date +%s)
        DURATION=$((END_TIME - START_TIME))
        
        echo ""
        if [ $EXIT_CODE -eq 0 ]; then
            echo "✅ N=$N completed successfully in ${DURATION}s ($(date '+%Y-%m-%d %H:%M:%S'))"
        else
            echo "❌ N=$N FAILED with exit code $EXIT_CODE after ${DURATION}s"
        fi
        echo ""
        echo "════════════════════════════════════════════════════════════════════════════"
        echo ""
        
        # Wait a bit before starting next N (optional, for stability)
        sleep 2
    done
    
    echo "════════════════════════════════════════════════════════════════════════════"
    echo "🎉 All benchmarks completed!"
    echo "════════════════════════════════════════════════════════════════════════════"
    echo ""
    echo "📊 Results:"
    echo "   Logs: $LOG_DIR/v5_n*.log"
    echo "   Proofs: $PROOF_DIR/"
}

################################################################################
# Main execution
################################################################################

# Parse arguments
if [ $# -eq 0 ]; then
    # No arguments - use defaults
    run_benchmark_sequential
elif [ "$1" == "help" ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    echo "Usage: $0 [N1] [N2] [N3] ..."
    echo ""
    echo "Chạy V5 benchmark TUẦN TỰ (lần lượt) - giống baseline"
    echo ""
    echo "Examples:"
    echo "  $0                    # Chạy mặc định: N=1,10,50,100,500"
    echo "  $0 1                  # Chạy N=1"
    echo "  $0 10 50 100          # Chạy N=10, rồi N=50, rồi N=100 (tuần tự)"
    echo "  $0 1 10 50 100 500    # Chạy tất cả tuần tự"
    echo ""
    echo "⚠️  Lưu ý: Chạy TUẦN TỰ - mỗi N sẽ chạy xong rồi mới chạy N tiếp theo"
else
    # Has arguments - use provided N values
    run_benchmark_sequential "$@"
fi

