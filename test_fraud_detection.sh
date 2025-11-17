#!/usr/bin/env bash
# Test fraud detection với wrong global_root

set -e

BIN_DIR="/home/ubuntu/thanhhuyen/agglayer"
LOG_DIR="/home/ubuntu/thanhhuyen/logs/fraud_test"
PROOF_DIR="/home/ubuntu/thanhhuyen/proofs/fraud_test"

mkdir -p "$LOG_DIR" "$PROOF_DIR"
cd "$BIN_DIR"

echo "═══════════════════════════════════════════════════════════"
echo "🔍 TEST FRAUD DETECTION - Wrong Global Root"
echo "═══════════════════════════════════════════════════════════"
echo ""

N=1
LOG_FILE="$LOG_DIR/fraud_test_n${N}_$(date +%Y%m%d_%H%M%S).log"
PROOF_SUBDIR="$PROOF_DIR/fraud_test_n${N}"

mkdir -p "$PROOF_SUBDIR"

# Generate wrong global_root (random 64 hex chars = 32 bytes)
WRONG_ROOT=$(openssl rand -hex 32)
echo "📊 Configuration:"
echo "  • N exits: $N"
echo "  • Wrong global_root: 0x$WRONG_ROOT"
echo "  • Expected: V5 should detect fraud and exit early (exit code 1)"
echo "  • Log: $LOG_FILE"
echo ""

export RUST_LOG=sp1_sdk=info,sp1=info,pessimistic_proof=info
export SP1_PROVER=cpu
export RAYON_NUM_THREADS=8
export SHARD_BATCH_SIZE=1
export TRACE_GEN_WORKERS=1

echo "🔴 Running V5 with wrong global_root (fraud test)..."
echo ""

# Run với wrong global_root - expect exit code 1 (fraud detected)
/usr/bin/time -v cargo run --release -p pessimistic-proof-test-suite --bin ppgen_sabv_lmtr5 -- \
    --n-exits "$N" \
    --validator-nodes 5 \
    --proof-dir "$PROOF_SUBDIR" \
    --wrong-global-root "0x$WRONG_ROOT" \
    2>&1 | tee "$LOG_FILE" || EXIT_CODE=$?

EXIT_CODE=${EXIT_CODE:-${PIPESTATUS[0]}}

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "📊 KẾT QUẢ"
echo "═══════════════════════════════════════════════════════════"
echo ""

if [ $EXIT_CODE -eq 1 ]; then
    echo "✅ TEST PASSED: Fraud detected (exit code 1)"
    if grep -q "SABV5: Fraud detected" "$LOG_FILE"; then
        echo "✅ Fraud detection message found in log"
    fi
    if grep -q "FRAUD TEST MODE" "$LOG_FILE"; then
        echo "✅ Fraud test mode activated"
    fi
    ELAPSED=$(grep "Elapsed" "$LOG_FILE" | tail -1 | awk '{print $8}' || echo "N/A")
    echo "⏱️  Elapsed time: $ELAPSED (should be short - early exit)"
    echo ""
    echo "✅ KẾT LUẬN: V5 phát hiện fraud và dừng sớm (KHÔNG chạy SP1 proving)"
elif [ $EXIT_CODE -eq 0 ]; then
    echo "❌ TEST FAILED: Fraud NOT detected (exit code 0)"
    echo "⚠️  V5 should have detected fraud and exited with code 1"
    exit 1
else
    echo "⚠️  TEST ERROR: Unexpected exit code $EXIT_CODE"
    echo "Check log: $LOG_FILE"
    exit 1
fi
