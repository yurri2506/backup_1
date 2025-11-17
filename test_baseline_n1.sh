#!/usr/bin/env bash
# Test baseline với N=1 để so sánh với V5

set -e

BIN_DIR="/home/ubuntu/thanhhuyen/agglayer"
LOG_DIR="/home/ubuntu/thanhhuyen/logs/fraud_test"
PROOF_DIR="/home/ubuntu/thanhhuyen/proofs/fraud_test"

mkdir -p "$LOG_DIR" "$PROOF_DIR"
cd "$BIN_DIR"

echo "═══════════════════════════════════════════════════════════"
echo "🔄 TEST BASELINE - N=1 (để so sánh với V5)"
echo "═══════════════════════════════════════════════════════════"
echo ""

N=1
LOG_FILE="$LOG_DIR/baseline_n${N}_$(date +%Y%m%d_%H%M%S).log"
PROOF_SUBDIR="$PROOF_DIR/baseline_n${N}"

mkdir -p "$PROOF_SUBDIR"

echo "📊 Configuration:"
echo "  • N exits: $N"
echo "  • Note: Baseline KHÔNG CÓ --wrong-global-root parameter"
echo "  • Baseline sẽ chạy full SP1 proving (không có SABV5 layer)"
echo "  • Log: $LOG_FILE"
echo ""

export RUST_LOG=sp1_sdk=info,sp1=info,pessimistic_proof=info
export SP1_PROVER=cpu
export RAYON_NUM_THREADS=8
export SHARD_BATCH_SIZE=1
export TRACE_GEN_WORKERS=1

echo "🔄 Running Baseline (ppgen.rs) với N=$N..."
echo "   ⚠️  Lưu ý: Baseline không có SABV5 layer, sẽ chạy full SP1 proving"
echo ""

# Run baseline - expect full SP1 proving
/usr/bin/time -v cargo run --release \
    -p pessimistic-proof-test-suite \
    --bin ppgen \
    -- \
    --n-exits "$N" \
    --n-imported-exits "$N" \
    --proof-dir "$PROOF_SUBDIR" \
    2>&1 | tee "$LOG_FILE" || EXIT_CODE=$?

EXIT_CODE=${EXIT_CODE:-${PIPESTATUS[0]}}

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "📊 KẾT QUẢ BASELINE"
echo "═══════════════════════════════════════════════════════════"
echo ""

if grep -q "Elapsed (wall clock)" "$LOG_FILE"; then
    ELAPSED=$(grep "Elapsed (wall clock)" "$LOG_FILE" | tail -1 | sed -n 's/.*: \([0-9:]*\).*/\1/p')
    USER_TIME=$(grep "User time" "$LOG_FILE" | tail -1 | awk '{print $4}')
    SYS_TIME=$(grep "System time" "$LOG_FILE" | tail -1 | awk '{print $4}')
    MAX_RSS=$(grep "Maximum resident set size" "$LOG_FILE" | tail -1 | awk '{print $6}')
    
    echo "✅ Baseline completed"
    echo "   Exit code: $EXIT_CODE"
    echo "   ⏱️  Elapsed time: $ELAPSED"
    echo "   ⏱️  User time: $USER_TIME"
    echo "   ⏱️  System time: $SYS_TIME"
    echo "   💾 Max memory: $MAX_RSS KB"
    echo ""
    echo "📊 So sánh với V5:"
    echo "   • V5 (fraud detected): ~1:01.90 (early exit)"
    echo "   • Baseline (full SP1): $ELAPSED"
    echo ""
    
    # Check if SP1 proving ran
    if grep -q "proving\|proof\|SP1" "$LOG_FILE"; then
        echo "✅ Baseline chạy full SP1 proving (như dự đoán)"
    fi
else
    echo "⚠️  Không thể extract time từ log"
fi

echo ""
echo "📄 Log file: $LOG_FILE"
echo ""

