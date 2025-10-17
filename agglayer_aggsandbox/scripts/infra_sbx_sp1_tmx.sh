#!/usr/bin/env bash
set -euo pipefail

# Non-intrusive infra bootstrap for AggSandbox + SP1
# Creates a dedicated tmux session without touching existing sessions

SESSION_NAME="infra_sbx_sp1"
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGGLAYER_DIR="${AGGLAYER_DIR:-$BASE_DIR/../agglayer}"
AGGSANDBOX_DIR="${AGGSANDBOX_DIR:-$BASE_DIR/../aggsandbox}"
LOG_DIR="$BASE_DIR/logs/infra"

echo "🚀 Infra: AggSandbox (3 L2s) + SP1"
echo "📁 AggLayer: $AGGLAYER_DIR"
echo "📁 AggSandbox: $AGGSANDBOX_DIR"
echo "🗂 Logs: $LOG_DIR"

command -v tmux >/dev/null 2>&1 || { echo "❌ tmux not found"; exit 1; }
command -v aggsandbox >/dev/null 2>&1 || { echo "❌ aggsandbox not found"; exit 1; }
mkdir -p "$LOG_DIR"

# Do not kill existing sessions; create only if absent
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
  echo "ℹ️  tmux session '$SESSION_NAME' already exists. Attach: tmux attach -t $SESSION_NAME"
  exit 0
fi

tmux new-session -d -s "$SESSION_NAME" -c "$BASE_DIR"
tmux set-option -t "$SESSION_NAME" remain-on-exit on

# Pane 0: AggSandbox
tmux send-keys -t "$SESSION_NAME":0.0 "cd $AGGSANDBOX_DIR" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "test -f .env || cp .env.example .env" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "source .env" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo '🔎 Checking AggSandbox status...'" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "(aggsandbox status 2>/dev/null || (echo 'Starting multi-L2 sandbox (3 L2s)...' && aggsandbox start --multi-l2 --detach)) | tee $LOG_DIR/aggsandbox_status.log" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "sleep 15" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo '🌉 Seeding bridge transactions (L1→L2-1,2,3)...' | tee -a $LOG_DIR/aggsandbox.log" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "aggsandbox bridge asset --network-id 0 --destination-network-id 1 --amount 1000000000000000000 --token-address 0x0000000000000000000000000000000000000000 | tee -a $LOG_DIR/aggsandbox.log || true" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "sleep 2" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "aggsandbox bridge asset --network-id 0 --destination-network-id 2 --amount 2000000000000000000 --token-address 0x0000000000000000000000000000000000000000 | tee -a $LOG_DIR/aggsandbox.log || true" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "sleep 2" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "aggsandbox bridge asset --network-id 0 --destination-network-id 3 --amount 3000000000000000000 --token-address 0x0000000000000000000000000000000000000000 | tee -a $LOG_DIR/aggsandbox.log || true" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "sleep 5" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo '✅ Bridge seeding complete (3 L2s)' | tee -a $LOG_DIR/aggsandbox.log" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "aggsandbox logs --follow >> $LOG_DIR/aggsandbox.log 2>&1" C-m

# Pane 1: SP1 local server
tmux split-window -h -t "$SESSION_NAME":0
tmux send-keys -t "$SESSION_NAME":0.1 "cd $AGGLAYER_DIR" C-m
tmux send-keys -t "$SESSION_NAME":0.1 "export SP1_PROVER=cpu" C-m
tmux send-keys -t "$SESSION_NAME":0.1 "/bin/bash /home/ubuntu/thanhhuyen/sp1_local_server.sh >> $LOG_DIR/sp1_server.log 2>&1" C-m

echo "✅ Infra tmux session '$SESSION_NAME' created"
echo "🔗 Attach: tmux attach -t $SESSION_NAME"
echo "🗂 Logs: $LOG_DIR"


