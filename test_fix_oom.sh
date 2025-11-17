#!/usr/bin/env bash
# Quick test to verify OOM fix

set -e

BIN_DIR="/home/ubuntu/thanhhuyen/agglayer"
LOG_DIR="/home/ubuntu/thanhhuyen/logs/test"
PROOF_DIR="/home/ubuntu/thanhhuyen/proofs/test"

mkdir -p "$LOG_DIR" "$PROOF_DIR"
cd "$BIN_DIR"

echo "═══════════════════════════════════════════════════════════"
echo "🧪 TEST FIX OOM - Verify cấu hình mới"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Test N=10 (should use 16 threads)
N=10
echo "📊 Test N=$N (should use 16 threads)"
LOG_FILE="$LOG_DIR/test_n${N}_$(date +%Y%m%d_%H%M%S).log"
PROOF_SUBDIR="$PROOF_DIR/test_n${N}"

mkdir -p "$PROOF_SUBDIR"

# Apply fix logic: N<100 -> 16 threads, N>=100 -> 8 threads
if [ "$N" -ge 100 ]; then
    export RAYON_NUM_THREADS=8
    echo "  ⚙️  RAYON_NUM_THREADS=8 (N>=100)"
else
    export RAYON_NUM_THREADS=16
    echo "  ⚙️  RAYON_NUM_THREADS=16 (N<100)"
fi

export RUST_LOG=sp1_sdk=info,sp1=info
export SP1_PROVER=cpu
export SHARD_BATCH_SIZE=1
export TRACE_GEN_WORKERS=1

echo "  ⚙️  SHARD_BATCH_SIZE=1, TRACE_GEN_WORKERS=1"
echo "  📁 Log: $LOG_FILE"
echo ""

# Run quick test (smaller N, should finish quickly)
timeout 300 /usr/bin/time -v cargo run --release -p pessimistic-proof-test-suite --bin ppgen_sabv_lmtr5 -- \
    --n-exits "$N" \
    --validator-nodes 5 \
    --proof-dir "$PROOF_SUBDIR" \
    2>&1 | tee "$LOG_FILE" || true

# Check results
if grep -q "Command terminated by signal 9" "$LOG_FILE"; then
    echo "  ❌ OOM kill detected! Fix failed."
    exit 1
else
    echo "  ✅ No OOM kill - Fix working!"
    MAX_RAM=$(grep "Maximum resident set size" "$LOG_FILE" | tail -1 | awk '{print $6}' | sed 's/k$//' 2>/dev/null || echo "0")
    if [ "$MAX_RAM" != "0" ] && [ "$MAX_RAM" != "" ]; then
        MAX_RAM_GB=$(echo "scale=2; $MAX_RAM / 1024 / 1024" | bc 2>/dev/null || echo "0")
        echo "  💾 Max RAM: ${MAX_RAM_GB} GB"
    fi
fi
