#!/bin/bash
# Chạy V5 Fraud Detection Test trong tmux

SESSION_NAME="v5_fraud_test"
LOG_DIR="/home/ubuntu/thanhhuyen/logs/v5_seq"

cd /home/ubuntu/thanhhuyen

echo "🚨 Starting V5 Fraud Detection Test in tmux"
echo "Session: $SESSION_NAME"
echo ""

# Kill existing session if exists
tmux has-session -t "$SESSION_NAME" 2>/dev/null && tmux kill-session -t "$SESSION_NAME" || true

# Create tmux session
echo "Creating tmux session..."
tmux new-session -d -s "$SESSION_NAME" -c "/home/ubuntu/thanhhuyen/agglayer"

# Split into 2 panes
tmux split-window -h -t "$SESSION_NAME":0

# Wait a bit for panes to be ready
sleep 2

# Verify session exists
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "❌ Error: Failed to create tmux session"
    exit 1
fi
echo "✅ Tmux session created successfully"

# Pane 0.0: Run fraud detection test
tmux send-keys -t "$SESSION_NAME":0.0 "cd /home/ubuntu/thanhhuyen/agglayer" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo '════════════════════════════════════════════════════════════════════════════'" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo '🚨 V5 FRAUD DETECTION TEST - Early Exit'" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo '════════════════════════════════════════════════════════════════════════════'" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo 'Started at: \$(date)'" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo ''" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "export RAYON_NUM_THREADS=16" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "export RUST_LOG=sp1_sdk=info,sp1=info" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "export SP1_PROVER=cpu" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "export SP1_CARGO_PROVE_PATH=/home/ubuntu/.sp1/bin/cargo-prove" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo '⚠️  KHÔNG có --allow-fraud-testing (đúng!)'" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo 'Expected: Exit code 1 (fraud detected)'" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo ''" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "/usr/bin/time -v cargo run --release -p pessimistic-proof-test-suite --bin ppgen_sabv_lmtr5 -- --n-exits 1 --validator-nodes 5 --proof-dir /home/ubuntu/thanhhuyen/proofs/v5_fraud 2>&1 | tee $LOG_DIR/v5_fraud_test.log" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo ''" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo '════════════════════════════════════════════════════════════════════════════'" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo '✅ FRAUD TEST COMPLETED'" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo 'Ended at: \$(date)'" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo 'Exit code: \$?'" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo '════════════════════════════════════════════════════════════════════════════'" C-m

# Pane 0.1: Monitor log
tmux send-keys -t "$SESSION_NAME":0.1 "echo '📝 Fraud Test Log Monitor'" C-m
tmux send-keys -t "$SESSION_NAME":0.1 "tail -f $LOG_DIR/v5_fraud_test.log 2>/dev/null || echo 'Waiting for log file...'" C-m

echo ""
echo "════════════════════════════════════════════════════════════════════════════"
echo "✅ Tmux session created: $SESSION_NAME"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""
echo "🔗 Attach with: tmux attach -t $SESSION_NAME"
echo "📊 Log: $LOG_DIR/v5_fraud_test.log"
echo ""
echo "🚨 Fraud Detection Test started"
echo "⚠️  Expected: Exit code 1 (fraud detected - early exit)"
echo ""

