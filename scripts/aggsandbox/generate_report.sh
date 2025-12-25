#!/usr/bin/env bash
# Generate summary report từ logs
# Usage: ./generate_aggsandbox_report.sh

set -euo pipefail

# Get base directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOG_DIR="${1:-$BASE_DIR/logs/aggsandbox_exp}"
REPORT_FILE="${LOG_DIR}/REPORT_$(date +%Y%m%d_%H%M%S).md"

echo "📊 Generating report from: $LOG_DIR"

if [ ! -f "$LOG_DIR/summary.txt" ]; then
    echo "❌ Summary file not found: $LOG_DIR/summary.txt"
    exit 1
fi

cat > "$REPORT_FILE" << 'EOF'
# AGGSANDBOX EXPERIMENTS REPORT

## Tổng hợp kết quả Baseline vs V5

EOF

# Parse summary và tạo bảng
echo "" >> "$REPORT_FILE"
echo "| Type | N | Exit Code | Elapsed Time | User Time | Sys Time | CPU % | Max RAM (GB) | Fraud | Log File |" >> "$REPORT_FILE"
echo "|------|---|-----------|--------------|-----------|----------|-------|--------------|-------|----------|" >> "$REPORT_FILE"

while IFS=',' read -r line; do
    TYPE=$(echo "$line" | cut -d',' -f1)
    N=$(echo "$line" | sed -n 's/.*N=\([0-9]*\).*/\1/p')
    EXIT=$(echo "$line" | sed -n 's/.*Exit=\([0-9]*\).*/\1/p')
    TIME=$(echo "$line" | sed -n 's/.*Time=\([^,]*\).*/\1/p')
    USER=$(echo "$line" | sed -n 's/.*User=\([^,]*\).*/\1/p')
    SYS=$(echo "$line" | sed -n 's/.*Sys=\([^,]*\).*/\1/p')
    CPU=$(echo "$line" | sed -n 's/.*CPU=\([^,]*\).*/\1/p')
    RAM=$(echo "$line" | sed -n 's/.*RAM=\([^,]*\).*/\1/p')
    FRAUD=$(echo "$line" | sed -n 's/.*Fraud=\([^,]*\).*/\1/p')
    LOG=$(echo "$line" | sed -n 's/.*Log=\(.*\)/\1/p')
    
    echo "| $TYPE | $N | $EXIT | $TIME | $USER | $SYS | $CPU | $RAM | $FRAUD | \`$(basename "$LOG")\` |" >> "$REPORT_FILE"
done < "$LOG_DIR/summary.txt"

echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "Generated: $(date)" >> "$REPORT_FILE"

echo "✅ Report generated: $REPORT_FILE"
cat "$REPORT_FILE"


