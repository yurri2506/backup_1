#!/bin/bash

# V4 REAL Algorithm Test Script
SESSION_NAME="sabv4_lmtr4_ppgen"
BIN_DIR="/home/ubuntu/thanhhuyen/agglayer"
LOG_DIR="/home/ubuntu/thanhhuyen/logs/sabv4_lmtr4"
PROOF_DIR="/home/ubuntu/thanhhuyen/proofs/v4"

echo "🚀 Starting V4 REAL Algorithm Test with SP1 Proving"
echo "📁 Log directory: $LOG_DIR"
mkdir -p "$LOG_DIR" "$PROOF_DIR"

# Create tmux session
tmux new-session -d -s "$SESSION_NAME" -c "$BIN_DIR"

# Split into 4 panes
tmux split-window -h -t "$SESSION_NAME":0
tmux split-window -v -t "$SESSION_NAME":0.0
tmux split-window -v -t "$SESSION_NAME":0.1

# Pane 0.0: V4 REAL Algorithm Execution
tmux send-keys -t "$SESSION_NAME":0.0 "echo '🎯 V4 REAL Algorithm Test Starting...'" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "date" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo 'Running V4 REAL algorithms with SP1 proving...'" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "/usr/bin/time -v RUST_LOG=sp1_sdk=debug,sp1=debug SP1_PROVER=cpu SP1_CARGO_PROVE_PATH=/home/ubuntu/.sp1/bin/cargo-prove cargo run --release -p pessimistic-proof-test-suite --bin ppgen_sabv_lmtr4 -- --n-exits 1 --validator-nodes 5 --proof-dir $PROOF_DIR 2>&1 | tee $LOG_DIR/v4_n1_$(date +%Y%m%d_%H%M%S).log" C-m

# Pane 0.1: System monitoring
tmux send-keys -t "$SESSION_NAME":0.1 "echo '📊 System Monitoring for V4 REAL Algorithm'" C-m
tmux send-keys -t "$SESSION_NAME":0.1 "while true; do echo \"\$(date): CPU=\$(top -bn1 | grep 'Cpu(s)' | awk '{print \$2}' | cut -d'%' -f1)%, RAM=\$(free | grep Mem | awk '{printf \"%.1f%%\", \$3/\$2 * 100.0}'), Load=\$(uptime | awk '{print \$(NF-2)}' | cut -d',' -f1)\"; sleep 30; done" C-m

# Pane 0.2: Log monitoring
tmux send-keys -t "$SESSION_NAME":0.2 "echo '📝 V4 REAL Algorithm Log Monitor'" C-m
tmux send-keys -t "$SESSION_NAME":0.2 "tail -f $LOG_DIR/v4_n1_*.log 2>/dev/null || echo 'Waiting for log file...'" C-m

# Pane 0.3: Process monitoring
tmux send-keys -t "$SESSION_NAME":0.3 "echo '🔍 Process Monitor for V4 REAL Algorithm'" C-m
tmux send-keys -t "$SESSION_NAME":0.3 "while true; do echo \"\$(date): V4 processes:\"; ps aux | grep -E '(ppgen_sabv_lmtr4|cargo)' | grep -v grep; echo '---'; sleep 60; done" C-m

echo "✅ V4 REAL Algorithm tmux session created: $SESSION_NAME"
echo "🔗 Attach with: tmux attach -t $SESSION_NAME"
echo "📊 Monitor logs in: $LOG_DIR"
echo "🎯 V4 uses REAL algorithms - NOT a simulator!"
echo "🔐 REAL Shamir Secret Sharing + REAL ECDSA + REAL Tree Optimization + REAL SP1"


