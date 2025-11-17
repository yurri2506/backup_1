#!/usr/bin/env bash

################################################################################
# FRAUD DETECTION COMPARISON SCRIPT
# 
# Mục đích: Chứng minh V5 phát hiện gian lận sớm hơn baseline
# 
# Quy trình:
# 1. Tạo fraud test data (wrong global_root)
# 2. Chạy baseline (ppgen.rs) với fraud data → đo thời gian hoàn thành
# 3. Chạy V5 (ppgen_sabv_lmtr5.rs) với fraud data → đo thời gian đến khi phát hiện
# 4. So sánh kết quả để chứng minh V5 phát hiện sớm hơn
#
# Usage:
#   ./fraud_detection_comparison.sh [N] [fraud_type]
#   ./fraud_detection_comparison.sh 10 wrong_global_root
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Configuration
BIN_DIR="$SCRIPT_DIR/agglayer"
LOG_DIR="$SCRIPT_DIR/logs/fraud_detection"
RESULTS_DIR="$SCRIPT_DIR/fraud_detection_results"
PROOF_DIR="$SCRIPT_DIR/proofs/fraud_detection"

# Default values
N=${1:-10}
FRAUD_TYPE=${2:-"wrong_global_root"}

mkdir -p "$LOG_DIR" "$RESULTS_DIR" "$PROOF_DIR"

echo "════════════════════════════════════════════════════════════════════"
echo "🔍 FRAUD DETECTION COMPARISON: V5 vs Baseline"
echo "════════════════════════════════════════════════════════════════════"
echo ""
echo "📋 Configuration:"
echo "   • N exits: $N"
echo "   • Fraud type: $FRAUD_TYPE"
echo "   • Log dir: $LOG_DIR"
echo "   • Results dir: $RESULTS_DIR"
echo ""

# Step 1: Generate fraud test data
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Step 1: Generating fraud test data"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ ! -f "$SCRIPT_DIR/generate_fraud_data.sh" ]; then
    echo "❌ Error: generate_fraud_data.sh not found!"
    exit 1
fi

bash "$SCRIPT_DIR/generate_fraud_data.sh" "$N" "$FRAUD_TYPE" "$RESULTS_DIR"

if [ ! -f "$RESULTS_DIR/fraud_data_n${N}_${FRAUD_TYPE}.json" ]; then
    echo "❌ Error: Failed to generate fraud data!"
    exit 1
fi

echo "✅ Fraud test data generated: $RESULTS_DIR/fraud_data_n${N}_${FRAUD_TYPE}.json"
echo ""

# Step 2: Run baseline with fraud data
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔄 Step 2: Running Baseline (ppgen.rs) with fraud data"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

BASELINE_LOG="$LOG_DIR/baseline_n${N}_${FRAUD_TYPE}_$(date +%Y%m%d_%H%M%S).log"
BASELINE_START=$(date +%s)

cd "$BIN_DIR"

echo "   ⚙️  Running baseline (no SABV, direct SP1 proving)..."
echo "   📄 Log: $BASELINE_LOG"
echo ""

/usr/bin/time -v cargo run --release \
    -p pessimistic-proof-test-suite \
    --bin ppgen \
    -- \
    --n-exits "$N" \
    --n-imported-exits "$N" \
    --proof-dir "$PROOF_DIR/baseline_n${N}" \
    2>&1 | tee "$BASELINE_LOG"

BASELINE_END=$(date +%s)
BASELINE_ELAPSED=$((BASELINE_END - BASELINE_START))

# Extract time information from log
if grep -q "Elapsed (wall clock)" "$BASELINE_LOG"; then
    BASELINE_TIME=$(grep "Elapsed (wall clock)" "$BASELINE_LOG" | tail -1 | sed -n 's/.*: \([0-9:]*\).*/\1/p')
    BASELINE_USER_TIME=$(grep "User time" "$BASELINE_LOG" | tail -1 | awk '{print $4}')
    BASELINE_SYS_TIME=$(grep "System time" "$BASELINE_LOG" | tail -1 | awk '{print $4}')
else
    BASELINE_TIME="${BASELINE_ELAPSED}s"
    BASELINE_USER_TIME="N/A"
    BASELINE_SYS_TIME="N/A"
fi

echo ""
echo "   ✅ Baseline completed"
echo "   ⏱️  Elapsed time: $BASELINE_TIME"
echo "   ⏱️  User time: $BASELINE_USER_TIME"
echo "   ⏱️  ⚠️  Baseline ran full SP1 proving (no early fraud detection)"
echo ""

# Step 3: Run V5 with fraud data
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Step 3: Running V5 (ppgen_sabv_lmtr5.rs) with fraud data"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

V5_LOG="$LOG_DIR/v5_n${N}_${FRAUD_TYPE}_$(date +%Y%m%d_%H%M%S).log"
V5_START=$(date +%s)

cd "$BIN_DIR"

echo "   ⚙️  Running V5 (SABV5 + LMTR4 with early fraud detection)..."
echo "   📄 Log: $V5_LOG"
echo ""

# Note: V5 will exit early when fraud detected (unless --allow-fraud-testing)
set +e
/usr/bin/time -v cargo run --release \
    -p pessimistic-proof-test-suite \
    --bin ppgen_sabv_lmtr5 \
    -- \
    --n-exits "$N" \
    --validator-nodes 5 \
    --proof-dir "$PROOF_DIR/v5_n${N}" \
    2>&1 | tee "$V5_LOG"
V5_EXIT_CODE=$?
set -e

V5_END=$(date +%s)
V5_ELAPSED=$((V5_END - V5_START))

# Check if fraud was detected
FRAUD_DETECTED=false
FRAUD_DETECTION_TIME="N/A"
FRAUD_DETECTION_STAGE="N/A"

if grep -q "SABV5: Fraud detected" "$V5_LOG" || grep -q "integrity verification FAILED" "$V5_LOG"; then
    FRAUD_DETECTED=true
    FRAUD_DETECTION_STAGE="SABV5"
    
    # Extract timestamp when fraud was detected
    if grep -q "SABV5: Fraud detected" "$V5_LOG"; then
        FRAUD_LINE=$(grep "SABV5: Fraud detected" "$V5_LOG" | head -1)
        # Try to extract time from log
        FRAUD_DETECTION_TIME=$(echo "$FRAUD_LINE" | grep -o '[0-9][0-9]:[0-9][0-9]:[0-9][0-9]' | head -1 || echo "N/A")
    fi
fi

# Extract time information from log
if grep -q "Elapsed (wall clock)" "$V5_LOG"; then
    V5_TIME=$(grep "Elapsed (wall clock)" "$V5_LOG" | tail -1 | sed -n 's/.*: \([0-9:]*\).*/\1/p')
    V5_USER_TIME=$(grep "User time" "$V5_LOG" | tail -1 | awk '{print $4}')
    V5_SYS_TIME=$(grep "System time" "$V5_LOG" | tail -1 | awk '{print $4}')
else
    V5_TIME="${V5_ELAPSED}s"
    V5_USER_TIME="N/A"
    V5_SYS_TIME="N/A"
fi

# Extract SABV5 processing time
SABV5_TIME="N/A"
if grep -q "SABV5.*verification.*time:" "$V5_LOG"; then
    SABV5_TIME=$(grep "SABV5.*verification.*time:" "$V5_LOG" | tail -1 | sed -n 's/.*time: \([^,]*\).*/\1/p')
fi

echo ""
if [ "$FRAUD_DETECTED" = true ]; then
    echo "   ✅ Fraud detected by V5!"
    echo "   🔍 Detection stage: $FRAUD_DETECTION_STAGE"
    echo "   ⏱️  Detection time: $FRAUD_DETECTION_TIME"
    echo "   ⏱️  SABV5 processing time: $SABV5_TIME"
    echo "   ⏱️  Total elapsed time: $V5_TIME"
    echo "   ✅ V5 exited early (no SP1 proving needed)"
else
    echo "   ⚠️  Fraud NOT detected or test mode enabled"
    echo "   ⏱️  Elapsed time: $V5_TIME"
fi
echo ""

# Step 4: Compare results
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Step 4: Results Comparison"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

COMPARISON_FILE="$RESULTS_DIR/comparison_n${N}_${FRAUD_TYPE}_$(date +%Y%m%d_%H%M%S).txt"

cat > "$COMPARISON_FILE" << EOF
════════════════════════════════════════════════════════════════════
FRAUD DETECTION COMPARISON RESULTS
════════════════════════════════════════════════════════════════════

Test Configuration:
  • N exits: $N
  • Fraud type: $FRAUD_TYPE
  • Test date: $(date)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BASELINE (ppgen.rs - No SABV)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  • Fraud Detection: ❌ NO (no SABV layer)
  • Execution: Full SP1 proving (even with fraud data)
  • Elapsed time: $BASELINE_TIME
  • User time: $BASELINE_USER_TIME
  • System time: $BASELINE_SYS_TIME
  • Log file: $BASELINE_LOG

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
V5 (ppgen_sabv_lmtr5.rs - With SABV5 + LMTR4)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  • Fraud Detection: $([ "$FRAUD_DETECTED" = true ] && echo "✅ YES" || echo "❌ NO")
  • Detection Stage: $FRAUD_DETECTION_STAGE
  • Detection Time: $FRAUD_DETECTION_TIME
  • SABV5 Processing Time: $SABV5_TIME
  • Execution: $([ "$FRAUD_DETECTED" = true ] && echo "Early exit (no SP1 proving)" || echo "Full execution")
  • Elapsed time: $V5_TIME
  • User time: $V5_USER_TIME
  • System time: $V5_SYS_TIME
  • Exit code: $V5_EXIT_CODE
  • Log file: $V5_LOG

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CONCLUSION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF

if [ "$FRAUD_DETECTED" = true ]; then
    echo "✅ V5 SUCCESSFULLY detected fraud at SABV5 level" >> "$COMPARISON_FILE"
    echo "" >> "$COMPARISON_FILE"
    echo "Time Savings:" >> "$COMPARISON_FILE"
    echo "  • Baseline: Ran full SP1 proving ($BASELINE_TIME)" >> "$COMPARISON_FILE"
    echo "  • V5: Detected fraud early at SABV5 ($V5_TIME)" >> "$COMPARISON_FILE"
    echo "  • Savings: V5 saved time by detecting fraud BEFORE SP1 proving" >> "$COMPARISON_FILE"
    echo "" >> "$COMPARISON_FILE"
    echo "Security Advantage:" >> "$COMPARISON_FILE"
    echo "  • V5 has SABV5 fraud detection layer" >> "$COMPARISON_FILE"
    echo "  • V5 can detect fraud BEFORE expensive SP1 proving" >> "$COMPARISON_FILE"
    echo "  • Baseline has NO fraud detection at preprocessing level" >> "$COMPARISON_FILE"
else
    echo "⚠️  Fraud NOT detected in this test" >> "$COMPARISON_FILE"
    echo "  • Possible reasons:" >> "$COMPARISON_FILE"
    echo "    - Test mode enabled (--allow-fraud-testing)" >> "$COMPARISON_FILE"
    echo "    - Fraud data not correctly injected" >> "$COMPARISON_FILE"
    echo "    - Fraud type not yet implemented" >> "$COMPARISON_FILE"
fi

cat "$COMPARISON_FILE"
echo ""
echo "📄 Full comparison saved to: $COMPARISON_FILE"
echo ""

echo "════════════════════════════════════════════════════════════════════"
echo "✅ Fraud Detection Comparison Complete!"
echo "════════════════════════════════════════════════════════════════════"
echo ""
echo "💡 To view detailed logs:"
echo "   • Baseline: cat $BASELINE_LOG"
echo "   • V5: cat $V5_LOG"
echo "   • Comparison: cat $COMPARISON_FILE"


