#!/usr/bin/env bash
# Quick test N=1 to verify OOM fix (should finish in ~47 minutes)

set -e

BIN_DIR="/home/ubuntu/thanhhuyen/agglayer"
LOG_DIR="/home/ubuntu/thanhhuyen/logs/test"
PROOF_DIR="/home/ubuntu/thanhhuyen/proofs/test"

mkdir -p "$LOG_DIR" "$PROOF_DIR"
cd "$BIN_DIR"

echo "═══════════════════════════════════════════════════════════"
echo "🧪 QUICK TEST - Verify fix OOM (N=1, ~47 minutes)"
echo "═══════════════════════════════════════════════════════════"
echo ""

N=1
LOG_FILE="$LOG_DIR/quick_test_n${N}_$(date +%Y%m%d_%H%M%S).log"
PROOF_SUBDIR="$PROOF_DIR/quick_test_n${N}"

mkdir -p "$PROOF_SUBDIR"

# Apply fix logic
if [ "$N" -ge 100 ]; then
    export RAYON_NUM_THREADS=8
else
    export RAYON_NUM_THREADS=16
fi

export RUST_LOG=sp1_sdk=info,sp1=info
export SP1_PROVER=cpu
export SHARD_BATCH_SIZE=1
export TRACE_GEN_WORKERS=1

echo "  ⚙️  N=$N, RAYON_NUM_THREADS=$RAYON_NUM_THREADS"
echo "  ⚙️  SHARD_BATCH_SIZE=1, TRACE_GEN_WORKERS=1"
echo "  📁 Log: $LOG_FILE"
echo "  ⏱️  Expected: ~47 minutes"
echo ""

/usr/bin/time -v cargo run --release -p pessimistic-proof-test-suite --bin ppgen_sabv_lmtr5 -- \
    --n-exits "$N" \
    --validator-nodes 5 \
    --proof-dir "$PROOF_SUBDIR" \
    2>&1 | tee "$LOG_FILE"

EXIT_CODE=${PIPESTATUS[0]}

echo ""
if grep -q "Command terminated by signal 9" "$LOG_FILE"; then
    echo "  ❌ OOM kill detected! Fix failed."
    exit 1
elif [ $EXIT_CODE -eq 0 ]; then
    echo "  ✅ Test passed! No OOM kill."
    MAX_RAM=$(grep "Maximum resident set size" "$LOG_FILE" | tail -1 | awk '{print $6}' | sed 's/k$//' 2>/dev/null || echo "0")
    if [ "$MAX_RAM" != "0" ] && [ "$MAX_RAM" != "" ]; then
        MAX_RAM_GB=$(echo "scale=2; $MAX_RAM / 1024 / 1024" | bc 2>/dev/null || echo "0")
        echo "  💾 Max RAM: ${MAX_RAM_GB} GB"
    fi
else
    echo "  ⚠️  Test failed with exit code: $EXIT_CODE"
    echo "  📁 Check log: $LOG_FILE"
fi
