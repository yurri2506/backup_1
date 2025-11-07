#!/bin/bash
# Chạy V5 với N=500 và N=700, mỗi N chạy 5 lần trong tmux

SESSION_NAME="v5_n500_n700_5times"
LOG_DIR="/home/ubuntu/thanhhuyen/logs/v5_seq"

cd /home/ubuntu/thanhhuyen

echo "🚀 Starting V5 Benchmark: N=500 (5 lần) và N=700 (5 lần) in tmux"
echo "Session: $SESSION_NAME"
echo ""

# Kill existing session if exists
tmux has-session -t "$SESSION_NAME" 2>/dev/null && tmux kill-session -t "$SESSION_NAME" || true

# Create tmux session with 3 panes
echo "Creating tmux session..."
tmux new-session -d -s "$SESSION_NAME" -c "/home/ubuntu/thanhhuyen"

# Split into 3 panes: main benchmark, monitoring, and status
tmux split-window -h -t "$SESSION_NAME":0
tmux split-window -v -t "$SESSION_NAME":0.1

# Wait a bit for panes to be ready
sleep 2

# Verify session exists
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "❌ Error: Failed to create tmux session"
    exit 1
fi
echo "✅ Tmux session created successfully"
echo ""

# Pane 0.0: Main benchmark runner
tmux send-keys -t "$SESSION_NAME":0.0 "cd /home/ubuntu/thanhhuyen" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo '════════════════════════════════════════════════════════════════════════════'" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo '🚀 V5 BENCHMARK: N=500 (5 lần) và N=700 (5 lần)'" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo 'Started at: \$(date)'" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo '════════════════════════════════════════════════════════════════════════════'" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo ''" C-m

# N=500: 5 lần
for i in {1..5}; do
    tmux send-keys -t "$SESSION_NAME":0.0 "echo ''" C-m
    tmux send-keys -t "$SESSION_NAME":0.0 "echo '════════════════════════════════════════════════════════════════════════════'" C-m
    tmux send-keys -t "$SESSION_NAME":0.0 "echo '🔢 N=500 - LẦN $i/5'" C-m
    tmux send-keys -t "$SESSION_NAME":0.0 "echo 'Started: \$(date)'" C-m
    tmux send-keys -t "$SESSION_NAME":0.0 "echo '════════════════════════════════════════════════════════════════════════════'" C-m
    tmux send-keys -t "$SESSION_NAME":0.0 "./sabv_lmtr_v5.sh 500 2>&1 | tee $LOG_DIR/v5_n500_run${i}.log" C-m
    tmux send-keys -t "$SESSION_NAME":0.0 "echo '✅ N=500 - LẦN $i/5 completed at: \$(date)'" C-m
done

# N=700: 5 lần
for i in {1..5}; do
    tmux send-keys -t "$SESSION_NAME":0.0 "echo ''" C-m
    tmux send-keys -t "$SESSION_NAME":0.0 "echo '════════════════════════════════════════════════════════════════════════════'" C-m
    tmux send-keys -t "$SESSION_NAME":0.0 "echo '🔢 N=700 - LẦN $i/5'" C-m
    tmux send-keys -t "$SESSION_NAME":0.0 "echo 'Started: \$(date)'" C-m
    tmux send-keys -t "$SESSION_NAME":0.0 "echo '════════════════════════════════════════════════════════════════════════════'" C-m
    tmux send-keys -t "$SESSION_NAME":0.0 "./sabv_lmtr_v5.sh 700 2>&1 | tee $LOG_DIR/v5_n700_run${i}.log" C-m
    tmux send-keys -t "$SESSION_NAME":0.0 "echo '✅ N=700 - LẦN $i/5 completed at: \$(date)'" C-m
done

tmux send-keys -t "$SESSION_NAME":0.0 "echo ''" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo '════════════════════════════════════════════════════════════════════════════'" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo '🎉 TẤT CẢ ĐÃ HOÀN THÀNH!'" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo 'Completed at: \$(date)'" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo '════════════════════════════════════════════════════════════════════════════'" C-m

# Pane 0.1: System monitoring
tmux send-keys -t "$SESSION_NAME":0.1 "echo '📊 System Monitoring'" C-m
tmux send-keys -t "$SESSION_NAME":0.1 "echo '════════════════════════════════════════════════════════════════════════════'" C-m
tmux send-keys -t "$SESSION_NAME":0.1 "while true; do echo \"\$(date '+%H:%M:%S'): CPU=\$(top -bn1 | grep 'Cpu(s)' | awk '{print \$2}' | cut -d'%' -f1)%, RAM=\$(free -h | grep Mem | awk '{print \$3\"/\"\$2}'), Load=\$(uptime | awk '{print \$(NF-2)}' | cut -d',' -f1)\"; sleep 30; done | tee -a $LOG_DIR/v5_n500_n700_system_monitor.log" C-m

# Pane 0.2: Progress tracker
tmux send-keys -t "$SESSION_NAME":0.2 "echo '📈 Progress Tracker'" C-m
tmux send-keys -t "$SESSION_NAME":0.2 "echo '════════════════════════════════════════════════════════════════════════════'" C-m
tmux send-keys -t "$SESSION_NAME":0.2 "while true; do clear; echo '📊 PROGRESS TRACKER - \$(date)'; echo ''; echo 'N=500 Logs:'; ls -lh $LOG_DIR/v5_n500_run*.log 2>/dev/null | wc -l | xargs echo '  Completed:'; echo ''; echo 'N=700 Logs:'; ls -lh $LOG_DIR/v5_n700_run*.log 2>/dev/null | wc -l | xargs echo '  Completed:'; echo ''; echo 'Latest logs:'; ls -lth $LOG_DIR/v5_n*.log 2>/dev/null | head -5; sleep 60; done" C-m

echo ""
echo "════════════════════════════════════════════════════════════════════════════"
echo "✅ Tmux session created: $SESSION_NAME"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""
echo "📋 Layout:"
echo "  • Pane 0.0: Main benchmark (N=500 x5, N=700 x5)"
echo "  • Pane 0.1: System monitoring (CPU, RAM, Load)"
echo "  • Pane 0.2: Progress tracker"
echo ""
echo "🔗 Attach with: tmux attach -t $SESSION_NAME"
echo ""
echo "📁 Logs sẽ được lưu tại:"
echo "  • N=500: $LOG_DIR/v5_n500_run*.log"
echo "  • N=700: $LOG_DIR/v5_n700_run*.log"
echo "  • System monitor: $LOG_DIR/v5_n500_n700_system_monitor.log"
echo ""

