#!/usr/bin/env bash
# Summary script để kiểm tra kết quả fraud detection test

echo "═══════════════════════════════════════════════════════════"
echo "📊 FRAUD DETECTION TEST SUMMARY"
echo "═══════════════════════════════════════════════════════════"
echo ""

LOG_DIR="/home/ubuntu/thanhhuyen/logs/fraud_test"
LATEST_LOG=$(ls -t "$LOG_DIR"/*.log 2>/dev/null | head -1)

if [ -z "$LATEST_LOG" ]; then
    echo "❌ No test log found"
    exit 1
fi

echo "📁 Log file: $LATEST_LOG"
echo ""

# Check fraud detection
if grep -q "FRAUD TEST MODE" "$LATEST_LOG"; then
    echo "✅ Fraud test mode activated"
else
    echo "❌ Fraud test mode NOT activated"
fi

if grep -q "SABV5: Fraud detected" "$LATEST_LOG"; then
    echo "✅ Fraud detected by SABV5"
else
    echo "❌ Fraud NOT detected"
fi

# Check exit code
if grep -q "Command terminated by signal 9\|OOM" "$LATEST_LOG"; then
    echo "⚠️  OOM kill detected"
elif tail -10 "$LATEST_LOG" | grep -q "Elapsed.*0:"; then
    ELAPSED=$(grep "Elapsed" "$LATEST_LOG" | tail -1 | awk '{print $8}')
    echo "⏱️  Elapsed time: $ELAPSED"
fi

# Check if early exit
if grep -q "Exiting immediately\|Early exit\|exit code 1" "$LATEST_LOG"; then
    echo "✅ Early exit detected (fraud detected, did not run SP1 proving)"
else
    echo "⚠️  No early exit detected (may have run SP1 proving)"
fi

echo ""
echo "📋 Key log lines:"
echo "---"
grep -E "FRAUD|Fraud|fraud detected|early exit|Exiting" "$LATEST_LOG" | tail -10
echo "---"

