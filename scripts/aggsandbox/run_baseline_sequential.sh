#!/usr/bin/env bash
# Script chạy baseline experiments lần lượt (sequential)
# Usage: ./run_baseline_sequential.sh [N1 N2 N3...]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOG_DIR="$BASE_DIR/logs/aggsandbox_exp"
PROOF_DIR="$LOG_DIR/baseline/proofs"

# Get sample file
SAMPLE_FILE="$BASE_DIR/agglayer_aggsandbox/artifacts/bridge_test_data_multi_l2.json"
if [ ! -f "$SAMPLE_FILE" ]; then
    SAMPLE_FILE="$BASE_DIR/agglayer_aggsandbox/artifacts/bridge_test_data_fixed.json"
fi

# N values to run (default: 200 500 700)
N_VALUES="${@:-200 500 700}"

echo "═══════════════════════════════════════════════════════════"
echo "🔬 BASELINE EXPERIMENTS - SEQUENTIAL RUN"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "📁 Sample file: $SAMPLE_FILE"
echo "📁 Log directory: $LOG_DIR"
echo "📊 N values: $N_VALUES"
echo ""
echo "⚠️  Chạy lần lượt từng N (chờ N trước xong mới chạy N tiếp theo)"
echo ""

mkdir -p "$PROOF_DIR"

RUN_TEST_SCRIPT="$SCRIPT_DIR/run_test.sh"

for N in $N_VALUES; do
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "[$(date +%Y-%m-%d_%H:%M:%S)] 🔬 BASELINE N=$N"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Check if already completed
    if grep -q "^baseline,N=$N,Exit=0" "$LOG_DIR/summary.txt" 2>/dev/null; then
        echo "⚠️  Baseline N=$N đã có kết quả trong summary.txt, bỏ qua..."
        echo ""
        continue
    fi
    
    # Run the test
    if [ -n "$SAMPLE_FILE" ] && [ -f "$SAMPLE_FILE" ]; then
        "$RUN_TEST_SCRIPT" baseline "$N" "$SAMPLE_FILE" "$LOG_DIR" "$PROOF_DIR"
    else
        "$RUN_TEST_SCRIPT" baseline "$N" "" "$LOG_DIR" "$PROOF_DIR"
    fi
    
    EXIT_CODE=$?
    
    echo ""
    if [ $EXIT_CODE -eq 0 ]; then
        echo "✅ BASELINE N=$N COMPLETED"
    else
        echo "❌ BASELINE N=$N FAILED (exit code: $EXIT_CODE)"
        echo "⚠️  Dừng lại, không chạy tiếp các N còn lại"
        exit $EXIT_CODE
    fi
    echo ""
done

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "✅ TẤT CẢ BASELINE EXPERIMENTS HOÀN THÀNH"
echo "═══════════════════════════════════════════════════════════"
echo ""


