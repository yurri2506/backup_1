#!/usr/bin/env bash
set -euo pipefail

# Non-intrusive experiment runner using data from AggSandbox
# Creates its own tmux session and writes logs under ./logs/exp

SESSION_NAME="exp_sbx_agglayer"
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGGLAYER_DIR="${AGGLAYER_DIR:-$BASE_DIR/../agglayer}"
AGGSANDBOX_DIR="${AGGSANDBOX_DIR:-$BASE_DIR/../aggsandbox}"
LOG_DIR="$BASE_DIR/logs/exp"
EXIT_COUNTS="${EXIT_COUNTS:-1 10 20 50 100 1000}"
SAMPLE_PATH_OVERRIDE="${SAMPLE_PATH_OVERRIDE:-}"

echo "🧪 Experiments with AggSandbox data"
echo "📁 AggLayer: $AGGLAYER_DIR"
echo "📁 AggSandbox: $AGGSANDBOX_DIR"
echo "🗂 Logs: $LOG_DIR"

command -v tmux >/dev/null 2>&1 || { echo "❌ tmux not found"; exit 1; }
command -v cargo >/dev/null 2>&1 || { echo "❌ cargo not found"; exit 1; }
mkdir -p "$LOG_DIR/baseline/proofs" "$LOG_DIR/sabv_lmtr/proofs"

# Do not touch existing sessions
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
  echo "ℹ️  tmux session '$SESSION_NAME' already exists. Attach: tmux attach -t $SESSION_NAME"
  exit 0
fi

# Resolve sample path
SAMPLE="$BASE_DIR/logs/multi_l2/bridge_inputs.json"
if [ -n "$SAMPLE_PATH_OVERRIDE" ]; then SAMPLE="$SAMPLE_PATH_OVERRIDE"; fi
if [ ! -f "$SAMPLE" ]; then
  # fallback to artifacts
  if [ -f "$BASE_DIR/artifacts/bridge_test_data_multi_l2.json" ]; then
    SAMPLE="$BASE_DIR/artifacts/bridge_test_data_multi_l2.json"
  elif [ -f "$BASE_DIR/artifacts/bridge_test_data_fixed.json" ]; then
    SAMPLE="$BASE_DIR/artifacts/bridge_test_data_fixed.json"
  else
    echo "❌ No sample input found. Set SAMPLE_PATH_OVERRIDE to a valid JSON file."
    exit 1
  fi
fi

tmux new-session -d -s "$SESSION_NAME" -c "$BASE_DIR"
tmux set-option -t "$SESSION_NAME" remain-on-exit on

# Pane 2: Resource monitoring (dstat)
tmux split-window -v -t "$SESSION_NAME":0
tmux send-keys -t "$SESSION_NAME":0.1 "mkdir -p $LOG_DIR" C-m
tmux send-keys -t "$SESSION_NAME":0.1 "dstat --time --cpu --mem --disk --proc --load --top-cpu --top-mem 1 > $LOG_DIR/dstat.log 2>&1" C-m

# Pane 0: Baseline
tmux send-keys -t "$SESSION_NAME":0.0 "cd $AGGLAYER_DIR" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "export SP1_PROVER=cpu" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "echo '🔬 Baseline (with sample): $SAMPLE' | tee -a $LOG_DIR/run.log" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "for N in $EXIT_COUNTS; do echo \"[BASELINE] N=\\\$N\" | tee -a $LOG_DIR/run.log; /usr/bin/time -v cargo run --release -p pessimistic-proof-test-suite --bin ppgen -- --n-exits \\\$N --n-imported-exits \\\$N --proof-dir $LOG_DIR/baseline/proofs --sample-path \"$SAMPLE\" > $LOG_DIR/baseline/proof_\\\${N}.log 2>&1 || echo \"[ERROR] baseline N=\\\$N\" | tee -a $LOG_DIR/run.log; done" C-m

# Pane 1: SABV+LMTR (reuse top row, split horizontally)
tmux split-window -h -t "$SESSION_NAME":0.0
tmux send-keys -t "$SESSION_NAME":0.2 "cd $AGGLAYER_DIR" C-m
tmux send-keys -t "$SESSION_NAME":0.2 "export SP1_PROVER=cpu" C-m
tmux send-keys -t "$SESSION_NAME":0.2 "echo '🧬 SABV+LMTR (with sample): $SAMPLE' | tee -a $LOG_DIR/run.log" C-m
tmux send-keys -t "$SESSION_NAME":0.2 "for N in $EXIT_COUNTS; do echo \"[SABV+LMTR] N=\\\$N\" | tee -a $LOG_DIR/run.log; /usr/bin/time -v cargo run --release -p pessimistic-proof-test-suite --bin ppgen_sabv_lmtr -- --n-exits \\\$N --proof-dir $LOG_DIR/sabv_lmtr/proofs --validator-nodes 5 --sample-path \"$SAMPLE\" > $LOG_DIR/sabv_lmtr/proof_\\\${N}.log 2>&1 || echo \"[ERROR] sabv N=\\\$N\" | tee -a $LOG_DIR/run.log; done" C-m

echo "✅ Experiment tmux session '$SESSION_NAME' created"
echo "🔗 Attach: tmux attach -t $SESSION_NAME"
echo "🗂 Logs: $LOG_DIR"


