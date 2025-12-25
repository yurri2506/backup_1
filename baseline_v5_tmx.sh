#!/usr/bin/env bash
set -euo pipefail

SESSION_NAME="baseline_ppgen_v5"
LOG_DIR="/home/ubuntu/backup_1/logs/baseline_v5"
BIN_DIR="/home/ubuntu/backup_1/agglayer"
PKG="pessimistic-proof-test-suite"
BIN="ppgen_sabv_lmtr5"
ROUNDS="${ROUNDS:-5}"
EXIT_COUNTS=(10 100 200 500 700)

mkdir -p "$LOG_DIR"

command -v tmux >/dev/null 2>&1 || { echo "tmux not found"; exit 1; }
command -v dstat >/dev/null 2>&1 || { echo "dstat not found. Install: sudo apt-get install -y dstat"; exit 1; }
command -v stress-ng >/dev/null 2>&1 || { echo "stress-ng not found. Install: sudo apt-get install -y stress-ng"; exit 1; }

tmux has-session -t "$SESSION_NAME" 2>/dev/null && tmux kill-session -t "$SESSION_NAME" || true

tmux new-session -d -s "$SESSION_NAME" -c "$BIN_DIR"

# Pane 1: Resource monitoring
tmux send-keys -t "$SESSION_NAME" "mkdir -p $LOG_DIR && dstat --time --cpu --mem --disk --proc --load --top-cpu --top-mem 1 > $LOG_DIR/dstat.log 2>&1" C-m

# Pane 2: stress-ng to keep workload consistent - maximize CPU/RAM pressure
tmux split-window -h -t "$SESSION_NAME"
tmux send-keys -t "$SESSION_NAME" "echo 'Starting stress-ng (16 CPU, 12x8G VM for max RAM pressure)' && stress-ng --cpu 16 --cpu-method all --vm 12 --vm-bytes 8G --vm-keep --timeout 9999s > $LOG_DIR/stress.log 2>&1" C-m

# Pane 3: SP1 local server
tmux split-window -v -t "$SESSION_NAME"
tmux send-keys -t "$SESSION_NAME" "/bin/bash /home/ubuntu/backup_1/sp1_local_server.sh > $LOG_DIR/sp1_server.log 2>&1" C-m

# Pane 4: v5 baseline rounds - chạy lần lượt: ROUND 1 (N=10→700) → ROUND 2 → ... → ROUND 5
tmux split-window -v -t "$SESSION_NAME"
tmux send-keys -t "$SESSION_NAME" "cd $BIN_DIR" C-m
tmux send-keys -t "$SESSION_NAME" "export SP1_PROVER=\"${SP1_PROVER:-cpu}\"" C-m
# Maximize parallelism: use all 16 cores for Rayon/OMP (SP1 will use these threads)
tmux send-keys -t "$SESSION_NAME" "export RAYON_NUM_THREADS=32" C-m
tmux send-keys -t "$SESSION_NAME" "export OMP_NUM_THREADS=32" C-m
# Additional optimizations for maximum CPU/RAM usage
tmux send-keys -t "$SESSION_NAME" "export SP1_CORE_OPTS_TRACE_GEN_WORKERS=8" C-m
tmux send-keys -t "$SESSION_NAME" "ulimit -v unlimited" C-m
tmux send-keys -t "$SESSION_NAME" "mkdir -p $LOG_DIR/proofs" C-m
tmux send-keys -t "$SESSION_NAME" "echo \"[BASELINE_V5] ===== STARTED \$(date -u +'%Y-%m-%dT%H:%M:%SZ') =====\" | tee -a $LOG_DIR/run.log" C-m
tmux send-keys -t "$SESSION_NAME" "ROUNDS=$ROUNDS; EXIT_COUNTS=(10 100 200 500 700); for ROUND in \$(seq 1 \$ROUNDS); do echo \"[BASELINE_V5] ----- ROUND \$ROUND/\$ROUNDS -----\" | tee -a $LOG_DIR/run.log; for N in \"\${EXIT_COUNTS[@]}\"; do echo \"[BASELINE_V5] N=\$N - ROUND \$ROUND/\$ROUNDS\" | tee -a $LOG_DIR/run.log; RUN_TS=\$(date -u +\"%Y%m%dT%H%M%S\"); RUN_LABEL=\"round\${ROUND}_n\${N}_\${RUN_TS}\"; LOG_FILE=\"$LOG_DIR/proof_${BIN}_v5_\${N}_round\${ROUND}.no_input.log\"; /usr/bin/time -v cargo run --release -p $PKG --bin $BIN -- --n-exits \$N --validator-nodes 5 --proof-dir $LOG_DIR/proofs --run-label \$RUN_LABEL > \"\$LOG_FILE\" 2>&1; EXIT_CODE=\$?; if [ \$EXIT_CODE -ne 0 ]; then echo \"[BASELINE_V5] ⚠️  N=\$N failed (exit \$EXIT_CODE), retrying with --allow-fraud-testing...\" | tee -a $LOG_DIR/run.log; RUN_LABEL_RETRY=\"round\${ROUND}_n\${N}_\${RUN_TS}_fraud_allowed\"; /usr/bin/time -v cargo run --release -p $PKG --bin $BIN -- --n-exits \$N --validator-nodes 5 --proof-dir $LOG_DIR/proofs --run-label \$RUN_LABEL_RETRY --allow-fraud-testing > \"\$LOG_FILE.retry\" 2>&1; RETRY_EXIT=\$?; if [ \$RETRY_EXIT -eq 0 ]; then echo \"[BASELINE_V5] ✅ N=\$N retry with fraud-allowed succeeded\" | tee -a $LOG_DIR/run.log; else echo \"[BASELINE_V5] ❌ N=\$N retry also failed (exit \$RETRY_EXIT)\" | tee -a $LOG_DIR/run.log; fi; fi; echo \"[BASELINE_V5] N=\$N - COMPLETED ROUND \$ROUND/\$ROUNDS\" | tee -a $LOG_DIR/run.log; done; done; echo \"[BASELINE_V5] ===== COMPLETED \$(date -u +'%Y-%m-%dT%H:%M:%SZ') =====\" | tee -a $LOG_DIR/run.log" C-m

echo "tmux session '$SESSION_NAME' started. Attach with: tmux attach -t $SESSION_NAME"

