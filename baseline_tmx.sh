#!/usr/bin/env bash
set -euo pipefail

SESSION_NAME="baseline_ppgen"
LOG_DIR="/home/ubuntu/thanhhuyen/logs/baseline"
BIN_DIR="/home/ubuntu/thanhhuyen/agglayer"
PKG="pessimistic-proof-test-suite"
BIN="ppgen"
EXIT_COUNTS=(1 5 10 20 50)

mkdir -p "$LOG_DIR"

# Ensure required tools
command -v tmux >/dev/null 2>&1 || { echo "tmux not found"; exit 1; }
command -v dstat >/dev/null 2>&1 || { echo "dstat not found. Install: sudo apt-get install -y dstat"; exit 1; }
command -v stress-ng >/dev/null 2>&1 || { echo "stress-ng not found. Install: sudo apt-get install -y stress-ng"; exit 1; }

# Kill existing session if exists
tmux has-session -t "$SESSION_NAME" 2>/dev/null && tmux kill-session -t "$SESSION_NAME" || true

tmux new-session -d -s "$SESSION_NAME" -c "$BIN_DIR"

# Pane 1: Resource monitor
tmux send-keys -t "$SESSION_NAME":0 "mkdir -p $LOG_DIR && dstat --time --cpu --mem --disk --proc --load --top-cpu --top-mem 1 > $LOG_DIR/dstat.log 2>&1" C-m

# Pane 2: Apply CPU/RAM stress to guarantee availability of 6 cores and 64GB usage
tmux split-window -h -t "$SESSION_NAME":0
tmux send-keys -t "$SESSION_NAME":0.1 "echo 'Starting stress: 6 CPU workers, 64G VM' && stress-ng --cpu 6 --cpu-method all --vm 8 --vm-bytes 8G --vm-keep --timeout 9999s > $LOG_DIR/stress.log 2>&1" C-m

# Pane 3: SP1 server
tmux split-window -v -t "$SESSION_NAME":0
tmux send-keys -t "$SESSION_NAME":0.2 "/bin/bash /home/ubuntu/thanhhuyen/sp1_local_server.sh > $LOG_DIR/sp1_server.log 2>&1" C-m

# Pane 4: Proving runs
tmux split-window -v -t "$SESSION_NAME":0.2
tmux send-keys -t "$SESSION_NAME":0.3 "\
export SP1_PROVER=cpu; \
mkdir -p $LOG_DIR/proofs; \
for N in ${EXIT_COUNTS[@]}; do \
  echo \"[BASELINE] Running N=$N\" | tee -a $LOG_DIR/run.log; \
  /usr/bin/time -v cargo run --release -p $PKG --bin $BIN -- --n-exits $N --n-imported-exits $N --proof-dir $LOG_DIR/proofs > $LOG_DIR/proof_${BIN}_${N}.log 2>&1; \
done; \
echo 'DONE' | tee -a $LOG_DIR/run.log" C-m

echo "tmux session '$SESSION_NAME' started. Attach: tmux attach -t $SESSION_NAME"


