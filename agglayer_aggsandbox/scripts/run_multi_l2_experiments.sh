#!/usr/bin/env bash
set -euo pipefail

# ============================================
# Multi-L2 AggLayer Experiments Runner
# ============================================

SESSION_NAME="multi_l2_experiments"
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGGLAYER_DIR="${AGGLAYER_DIR:-$BASE_DIR/../agglayer}"
AGGSANDBOX_DIR="${AGGSANDBOX_DIR:-$BASE_DIR/../aggsandbox}"
LOG_DIR="$BASE_DIR/logs/multi_l2"
EXIT_COUNTS="${EXIT_COUNTS:-1 5 10 20 50}"
NUM_L2="${NUM_L2:-2}"

echo "🚀 Starting Multi-L2 AggLayer Experiments"
echo "=========================================="
echo "📁 Base dir: $BASE_DIR"
echo "📁 AggLayer: $AGGLAYER_DIR"
echo "📁 AggSandbox: $AGGSANDBOX_DIR"
echo "📁 Logs: $LOG_DIR"
echo "🔢 Exit counts: $EXIT_COUNTS"
echo "🌐 Number of L2s: $NUM_L2"
echo ""

# Check prerequisites
command -v tmux >/dev/null 2>&1 || { echo "❌ tmux not found"; exit 1; }
command -v dstat >/dev/null 2>&1 || { echo "❌ dstat not found"; exit 1; }
command -v docker >/dev/null 2>&1 || { echo "❌ docker not found"; exit 1; }

# Create log directory
mkdir -p "$LOG_DIR"

# Kill existing session
tmux has-session -t "$SESSION_NAME" 2>/dev/null && tmux kill-session -t "$SESSION_NAME" || true

echo "✅ Creating tmux session: $SESSION_NAME"
tmux new-session -d -s "$SESSION_NAME" -c "$BASE_DIR"

# ============================================
# Pane 0: Resource monitoring (dstat)
# ============================================
echo "📊 [Pane 0] Setting up resource monitoring..."
tmux send-keys -t "$SESSION_NAME":0.0 "mkdir -p $LOG_DIR" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "dstat --time --cpu --mem --disk --proc --load --top-cpu --top-mem 1 > $LOG_DIR/dstat.log 2>&1" C-m

# ============================================
# Pane 1: AggSandbox multi-L2
# ============================================
echo "🌉 [Pane 1] Starting AggSandbox multi-L2..."
tmux split-window -h -t "$SESSION_NAME":0
tmux send-keys -t "$SESSION_NAME":0.1 "cd $AGGSANDBOX_DIR" C-m
tmux send-keys -t "$SESSION_NAME":0.1 "source .env 2>/dev/null || true" C-m
tmux send-keys -t "$SESSION_NAME":0.1 "echo '🛑 Stopping existing sandbox...' && aggsandbox stop 2>/dev/null || true" C-m
tmux send-keys -t "$SESSION_NAME":0.1 "sleep 3" C-m
tmux send-keys -t "$SESSION_NAME":0.1 "echo '🚀 Starting AggSandbox multi-L2...' && aggsandbox start --multi-l2 --detach" C-m
tmux send-keys -t "$SESSION_NAME":0.1 "sleep 10" C-m
tmux send-keys -t "$SESSION_NAME":0.1 "aggsandbox status > $LOG_DIR/aggsandbox_status.log 2>&1" C-m
tmux send-keys -t "$SESSION_NAME":0.1 "echo '✅ AggSandbox ready'" C-m
tmux send-keys -t "$SESSION_NAME":0.1 "aggsandbox logs --follow > $LOG_DIR/aggsandbox.log 2>&1" C-m

# ============================================
# Pane 2: SP1 local server
# ============================================
echo "🔐 [Pane 2] Starting SP1 local server..."
tmux split-window -v -t "$SESSION_NAME":0.1
tmux send-keys -t "$SESSION_NAME":0.2 "cd $AGGLAYER_DIR" C-m
tmux send-keys -t "$SESSION_NAME":0.2 "export SP1_PROVER=cpu" C-m
tmux send-keys -t "$SESSION_NAME":0.2 "export SP1_CIRCUITS_DIR=$AGGLAYER_DIR/sp1/target/release 2>/dev/null || true" C-m
tmux send-keys -t "$SESSION_NAME":0.2 "echo '=== SP1 LOCAL SERVER ===' > $LOG_DIR/sp1_server.log" C-m
tmux send-keys -t "$SESSION_NAME":0.2 "echo 'SP1_PROVER=cpu' >> $LOG_DIR/sp1_server.log" C-m
tmux send-keys -t "$SESSION_NAME":0.2 "while true; do echo \"\$(date): SP1 local server active\" >> $LOG_DIR/sp1_server.log; sleep 60; done" C-m

# ============================================
# Pane 3: Baseline experiments
# ============================================
echo "🧪 [Pane 3] Setting up Baseline experiments..."
tmux split-window -v -t "$SESSION_NAME":0.2
tmux send-keys -t "$SESSION_NAME":0.3 "cd $AGGLAYER_DIR" C-m
tmux send-keys -t "$SESSION_NAME":0.3 "export SP1_PROVER=cpu" C-m
tmux send-keys -t "$SESSION_NAME":0.3 "mkdir -p $LOG_DIR/baseline/proofs" C-m
tmux send-keys -t "$SESSION_NAME":0.3 "sleep 15" C-m
tmux send-keys -t "$SESSION_NAME":0.3 "echo '🔬 Starting Baseline experiments...' | tee -a $LOG_DIR/run.log" C-m
tmux send-keys -t "$SESSION_NAME":0.3 "for N in $EXIT_COUNTS; do echo \"[BASELINE] Running N=\\\$N\" | tee -a $LOG_DIR/run.log; /usr/bin/time -v cargo run --release -p pessimistic-proof-test-suite --bin ppgen -- --n-exits \\\$N --n-imported-exits \\\$N --proof-dir $LOG_DIR/baseline/proofs > $LOG_DIR/baseline/proof_\\\${N}.log 2>&1 || echo \"[ERROR] N=\\\$N failed\" | tee -a $LOG_DIR/run.log; done" C-m
tmux send-keys -t "$SESSION_NAME":0.3 "echo '✅ Baseline DONE' | tee -a $LOG_DIR/run.log" C-m

# ============================================
# Pane 4: SABV+LMTR experiments
# ============================================
echo "🧬 [Pane 4] Setting up SABV+LMTR experiments..."
tmux split-window -h -t "$SESSION_NAME":0.3
tmux send-keys -t "$SESSION_NAME":0.4 "cd $AGGLAYER_DIR" C-m
tmux send-keys -t "$SESSION_NAME":0.4 "export SP1_PROVER=cpu" C-m
tmux send-keys -t "$SESSION_NAME":0.4 "mkdir -p $LOG_DIR/sabv_lmtr/proofs" C-m
tmux send-keys -t "$SESSION_NAME":0.4 "sleep 15" C-m
tmux send-keys -t "$SESSION_NAME":0.4 "echo '🧬 Starting SABV+LMTR experiments...' | tee -a $LOG_DIR/run.log" C-m
tmux send-keys -t "$SESSION_NAME":0.4 "for N in $EXIT_COUNTS; do echo \"[SABV+LMTR] Running N=\\\$N\" | tee -a $LOG_DIR/run.log; /usr/bin/time -v cargo run --release -p pessimistic-proof-test-suite --bin ppgen_sabv_lmtr -- --n-exits \\\$N --proof-dir $LOG_DIR/sabv_lmtr/proofs --validator-nodes 5 > $LOG_DIR/sabv_lmtr/proof_\\\${N}.log 2>&1 || echo \"[ERROR] N=\\\$N failed\" | tee -a $LOG_DIR/run.log; done" C-m
tmux send-keys -t "$SESSION_NAME":0.4 "echo '✅ SABV+LMTR DONE' | tee -a $LOG_DIR/run.log" C-m

echo ""
echo "✅ Tmux session '$SESSION_NAME' created successfully!"
echo ""
echo "📋 Layout:"
echo "  - Pane 0: Resource monitoring (dstat)"
echo "  - Pane 1: AggSandbox multi-L2"
echo "  - Pane 2: SP1 local server"
echo "  - Pane 3: Baseline experiments"
echo "  - Pane 4: SABV+LMTR experiments"
echo ""
echo "🔗 To attach: tmux attach -t $SESSION_NAME"
echo "🔗 To detach: Ctrl+B then D"
echo "📊 Logs: $LOG_DIR"
echo ""
echo "⏳ Experiments will run automatically. Check logs for progress."

