#!/usr/bin/env bash

################################################################################
# RUN ALL FRAUD TESTS
# 
# Chạy tất cả các loại fraud tests với nhiều N values khác nhau
# 
# Usage:
#   ./run_all_fraud_tests.sh
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Configuration
N_VALUES=(1 10 100)
FRAUD_TYPES=("wrong_global_root" "tampered_blocks")
RESULTS_DIR="$SCRIPT_DIR/fraud_detection_results"
SUMMARY_FILE="$RESULTS_DIR/summary_$(date +%Y%m%d_%H%M%S).txt"

mkdir -p "$RESULTS_DIR"

echo "════════════════════════════════════════════════════════════════════"
echo "🔍 RUNNING ALL FRAUD DETECTION TESTS"
echo "════════════════════════════════════════════════════════════════════"
echo ""
echo "📋 Test Configuration:"
echo "   • N values: ${N_VALUES[*]}"
echo "   • Fraud types: ${FRAUD_TYPES[*]}"
echo "   • Total tests: $((${#N_VALUES[@]} * ${#FRAUD_TYPES[@]}))"
echo ""

if [ ! -f "$SCRIPT_DIR/fraud_detection_comparison.sh" ]; then
    echo "❌ Error: fraud_detection_comparison.sh not found!"
    exit 1
fi

chmod +x "$SCRIPT_DIR/fraud_detection_comparison.sh"
chmod +x "$SCRIPT_DIR/generate_fraud_data.sh"

# Initialize summary
cat > "$SUMMARY_FILE" << EOF
════════════════════════════════════════════════════════════════════
FRAUD DETECTION TEST SUMMARY
════════════════════════════════════════════════════════════════════

Test Date: $(date)
Test Configuration:
  • N values: ${N_VALUES[*]}
  • Fraud types: ${FRAUD_TYPES[*]}
  • Total tests: $((${#N_VALUES[@]} * ${#FRAUD_TYPES[@]}))

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF

TEST_COUNT=0
PASSED_COUNT=0
FAILED_COUNT=0

# Run all combinations
for N in "${N_VALUES[@]}"; do
    for FRAUD_TYPE in "${FRAUD_TYPES[@]}"; do
        TEST_COUNT=$((TEST_COUNT + 1))
        
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📊 Test $TEST_COUNT: N=$N, Fraud Type=$FRAUD_TYPE"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        
        # Run comparison
        if bash "$SCRIPT_DIR/fraud_detection_comparison.sh" "$N" "$FRAUD_TYPE" 2>&1 | tee "$RESULTS_DIR/test_${TEST_COUNT}_n${N}_${FRAUD_TYPE}.log"; then
            PASSED_COUNT=$((PASSED_COUNT + 1))
            STATUS="✅ PASSED"
        else
            FAILED_COUNT=$((FAILED_COUNT + 1))
            STATUS="❌ FAILED"
        fi
        
        echo ""
        echo "   $STATUS: N=$N, Fraud Type=$FRAUD_TYPE"
        echo ""
        
        # Add to summary
        echo "Test $TEST_COUNT: N=$N, Fraud Type=$FRAUD_TYPE - $STATUS" >> "$SUMMARY_FILE"
    done
done

# Final summary
cat >> "$SUMMARY_FILE" << EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FINAL SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total tests: $TEST_COUNT
Passed: $PASSED_COUNT
Failed: $FAILED_COUNT

EOF

echo ""
echo "════════════════════════════════════════════════════════════════════"
echo "✅ ALL FRAUD DETECTION TESTS COMPLETE!"
echo "════════════════════════════════════════════════════════════════════"
echo ""
echo "📊 Results:"
echo "   • Total tests: $TEST_COUNT"
echo "   • Passed: $PASSED_COUNT"
echo "   • Failed: $FAILED_COUNT"
echo ""
echo "📄 Summary saved to: $SUMMARY_FILE"
echo ""
echo "💡 View detailed results:"
echo "   • Summary: cat $SUMMARY_FILE"
echo "   • Individual tests: ls $RESULTS_DIR/test_*_*.log"


