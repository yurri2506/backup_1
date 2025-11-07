#!/bin/bash
# Chạy V5 với N=1, 3 lần trong tmux

set -e

SESSION_NAME="v5_n1_3times"
LOG_DIR="/home/ubuntu/thanhhuyen/logs/v5_seq"

cd /home/ubuntu/thanhhuyen

echo "🧹 Cleaning up old tmux sessions..."
# Kill all old V5 related sessions
for session in $(tmux list-sessions -F "#{session_name}" 2>/dev/null | grep -E "v5|sabv5"); do
    echo "   Killing: $session"
    tmux kill-session -t "$session" 2>/dev/null || true
done
echo "✅ Cleanup done"
echo ""

echo "🚀 Starting V5 Benchmark - N=1 (3 lần) in tmux"
echo "Session: $SESSION_NAME"
echo ""

# Kill existing session if exists
tmux has-session -t "$SESSION_NAME" 2>/dev/null && tmux kill-session -t "$SESSION_NAME" || true

# Create tmux session
echo "Creating tmux session..."
tmux new-session -d -s "$SESSION_NAME" -c "/home/ubuntu/thanhhuyen"

# Split into 3 panes (2 horizontal, then split left pane vertically)
tmux split-window -h -t "$SESSION_NAME":0
tmux split-window -v -t "$SESSION_NAME":0.0

# Wait a bit for panes to be ready
sleep 2

# Verify session exists
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "❌ Error: Failed to create tmux session"
    exit 1
fi
echo "✅ Tmux session created successfully"

# Pane 0.0: Run benchmarks
tmux send-keys -t "$SESSION_NAME":0.0 "cd /home/ubuntu/thanhhuyen" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo '════════════════════════════════════════════════════════════════════════════'" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo '🔢 LẦN 1: N=1'" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo '════════════════════════════════════════════════════════════════════════════'" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "./sabv_lmtr_v5.sh 1 2>&1 | tee $LOG_DIR/v5_n1_run1.log" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo ''" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo '════════════════════════════════════════════════════════════════════════════'" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo '🔢 LẦN 2: N=1'" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo '════════════════════════════════════════════════════════════════════════════'" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "./sabv_lmtr_v5.sh 1 2>&1 | tee $LOG_DIR/v5_n1_run2.log" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo ''" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo '════════════════════════════════════════════════════════════════════════════'" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo '🔢 LẦN 3: N=1'" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo '════════════════════════════════════════════════════════════════════════════'" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "./sabv_lmtr_v5.sh 1 2>&1 | tee $LOG_DIR/v5_n1_run3.log" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo ''" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo '🎉 Đã chạy xong 3 lần N=1'" C-m

# Pane 0.1: Fraud detection test (chạy song song)
tmux send-keys -t "$SESSION_NAME":0.1 "echo '🚨 Fraud Detection Test (chạy song song)'" C-m
tmux send-keys -t "$SESSION_NAME":0.1 "cd /home/ubuntu/thanhhuyen/agglayer" C-m
tmux send-keys -t "$SESSION_NAME":0.1 "export RAYON_NUM_THREADS=16" C-m
tmux send-keys -t "$SESSION_NAME":0.1 "export RUST_LOG=sp1_sdk=info,sp1=info" C-m
tmux send-keys -t "$SESSION_NAME":0.1 "export SP1_PROVER=cpu" C-m
tmux send-keys -t "$SESSION_NAME":0.1 "export SP1_CARGO_PROVE_PATH=/home/ubuntu/.sp1/bin/cargo-prove" C-m
tmux send-keys -t "$SESSION_NAME":0.1 "echo '⚠️  KHÔNG có --allow-fraud-testing (đúng!)'" C-m
tmux send-keys -t "$SESSION_NAME":0.1 "echo 'Expected: Exit code 1 (fraud detected)'" C-m
tmux send-keys -t "$SESSION_NAME":0.1 "echo 'Started: \$(date)'" C-m
tmux send-keys -t "$SESSION_NAME":0.1 "/usr/bin/time -v cargo run --release -p pessimistic-proof-test-suite --bin ppgen_sabv_lmtr5 -- --n-exits 1 --validator-nodes 5 --proof-dir /home/ubuntu/thanhhuyen/proofs/v5_fraud 2>&1 | tee $LOG_DIR/v5_fraud_test.log" C-m
tmux send-keys -t "$SESSION_NAME":0.1 "echo 'Ended: \$(date), Exit code: \$?'" C-m

# Pane 0.2: System monitoring
tmux send-keys -t "$SESSION_NAME":0.2 "echo '📊 System Monitoring'" C-m
tmux send-keys -t "$SESSION_NAME":0.2 "while true; do echo \"\$(date '+%H:%M:%S'): CPU=\$(top -bn1 | grep 'Cpu(s)' | awk '{print \$2}' | cut -d'%' -f1)%, RAM=\$(free -h | grep Mem | awk '{print \$3\"/\"\$2}'), Load=\$(uptime | awk '{print \$(NF-2)}' | cut -d',' -f1)\"; sleep 30; done | tee -a $LOG_DIR/v5_n1_system_monitor.log" C-m

echo ""
echo "════════════════════════════════════════════════════════════════════════════"
echo "✅ Tmux session created: $SESSION_NAME"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""
echo "🔗 Attach with: tmux attach -t $SESSION_NAME"
echo "📊 Logs: $LOG_DIR/v5_n1_run*.log"
echo ""
echo "🚀 Benchmark started - 3 lần N=1"
echo ""
echo "📋 Để kiểm tra:"
echo "   tmux list-sessions"
echo "   tmux attach -t $SESSION_NAME"
echo ""

