#!/usr/bin/env bash

################################################################################
# GENERATE FRAUD TEST DATA
# 
# Tạo fraud test data để test khả năng phát hiện gian lận
# 
# Usage:
#   ./generate_fraud_data.sh [N] [fraud_type] [output_dir]
#   ./generate_fraud_data.sh 10 wrong_global_root ./fraud_data
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default values
N=${1:-10}
FRAUD_TYPE=${2:-"wrong_global_root"}
OUTPUT_DIR=${3:-"$SCRIPT_DIR/fraud_detection_results"}

mkdir -p "$OUTPUT_DIR"

BIN_DIR="$SCRIPT_DIR/agglayer"

echo "🔴 Generating Fraud Test Data"
echo "   • N exits: $N"
echo "   • Fraud type: $FRAUD_TYPE"
echo "   • Output dir: $OUTPUT_DIR"
echo ""

cd "$BIN_DIR"

# Check if fraud_test_generator exists
if ! cargo run --release --bin fraud_test_generator --help > /dev/null 2>&1; then
    echo "⚠️  fraud_test_generator binary not found"
    echo "   Creating fraud data manually..."
    
    # Create a simple fraud data file
    cat > "$OUTPUT_DIR/fraud_data_n${N}_${FRAUD_TYPE}.json" << EOF
{
  "fraud_type": "$FRAUD_TYPE",
  "n_exits": $N,
  "description": "Fraud test data for $FRAUD_TYPE",
  "fraud_injected": true,
  "global_root": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "note": "This is a wrong global_root - V5 should detect this fraud early at SABV5 level"
}
EOF
    
    echo "✅ Fraud data file created: $OUTPUT_DIR/fraud_data_n${N}_${FRAUD_TYPE}.json"
else
    # Use fraud_test_generator
    echo "   Using fraud_test_generator..."
    cargo run --release \
        -p pessimistic-proof-test-suite \
        --bin fraud_test_generator \
        -- \
        --n-exits "$N" \
        --fraud-type "$FRAUD_TYPE" \
        --output-dir "$OUTPUT_DIR" \
        --validator-nodes 5 \
        2>&1 | tee "$OUTPUT_DIR/fraud_gen_n${N}_${FRAUD_TYPE}.log"
    
    echo "✅ Fraud test data generated"
fi

echo ""
echo "📄 Fraud data saved to: $OUTPUT_DIR/fraud_data_n${N}_${FRAUD_TYPE}.json"
echo ""
echo "💡 Note: V5 should detect this fraud early at SABV5 level (before SP1 proving)"
echo "   Baseline will run full SP1 proving without detecting fraud"


