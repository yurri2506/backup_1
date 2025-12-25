#!/bin/bash
set -e

SESSION_NAME="s_maple_multi_bench"
LOG_DIR="/home/ubuntu/thanhhuyen/agglayer_logs/s_maple_multi"
PROOF_DIR_BASE="/home/ubuntu/thanhhuyen/proofs/s_maple_multi"
N_VALUES=(1 10 50 100 200 500 700)
REPEATS=5
BINARY_CMD="cargo run --release -p pessimistic-proof-test-suite --bin ppgen_sabv_lmtr5"
PROJECT_DIR="/home/ubuntu/thanhhuyen/agglayer"

mkdir -p "$LOG_DIR" "$PROOF_DIR_BASE"

echo "🔵 Starting S-MAPLE multi-run benchmark (tmux session: $SESSION_NAME)"

tmux has-session -t "$SESSION_NAME" 2>/dev/null && tmux kill-session -t "$SESSION_NAME" || true

tmux new-session -d -s "$SESSION_NAME" -c "$PROJECT_DIR"

tmux split-window -h -t "$SESSION_NAME":0

tmux split-window -v -t "$SESSION_NAME":0.0

tmux send-keys -t "$SESSION_NAME":0.0 "cd $PROJECT_DIR" C-m

tmux send-keys -t "$SESSION_NAME":0.0 "LOG_LOOP=$LOG_DIR/multi_run.log" C-m

tmux send-keys -t "$SESSION_NAME":0.0 "echo '🚀 S-MAPLE multi-run benchmark starting' | tee -a $LOG_DIR/multi_run.log" C-m

tmux send-keys -t "$SESSION_NAME":0.0 "for repeat in $(seq 1 $REPEATS); do" C-m
tmux send-keys -t "$SESSION_NAME":0.0 "  for N in ${N_VALUES[@]}; do" C-m

tmux send-keys -t "$SESSION_NAME":0.0 "    echo \"[RUN] repeat=\$repeat N=\$N\" | tee -a $LOG_DIR/multi_run.log" C-m

tmux send-keys -t "$SESSION_NAME":0.0 "    RUN_LOG=$LOG_DIR/run_repeat_\${repeat}_N\${N}.log" C-m

tmux send-keys -t "$SESSION_NAME":0.0 "    RUN_PROOF=$PROOF_DIR_BASE/repeat_\${repeat}_N\${N}" C-m

tmux send-keys -t "$SESSION_NAME":0.0 "    mkdir -p \"$PROOF_DIR_BASE\"" C-m

tmux send-keys -t "$SESSION_NAME":0.0 "    RUST_LOG=sp1_sdk=info,sp1=info SP1_PROVER=cpu SP1_CARGO_PROVE_PATH=/home/ubuntu/.sp1/bin/cargo-prove /usr/bin/time -v $BINARY_CMD -- --n-exits \$N --validator-nodes 5 --proof-dir \"\${RUN_PROOF}\" --allow-fraud-testing > \"\${RUN_LOG}\" 2>&1" C-m

tmux send-keys -t "$SESSION_NAME":0.0 "    echo \"[DONE] repeat=\$repeat N=\$N\" | tee -a $LOG_DIR/multi_run.log" C-m

tmux send-keys -t "$SESSION_NAME":0.0 "  done" C-m

tmux send-keys -t "$SESSION_NAME":0.0 "done" C-m

tmux send-keys -t "$SESSION_NAME":0.0 "echo '✅ All runs completed' | tee -a $LOG_DIR/multi_run.log" C-m

tmux send-keys -t "$SESSION_NAME":0.1 "echo '📊 System monitor (dstat 5s)'" C-m
tmux send-keys -t "$SESSION_NAME":0.1 "dstat --time --cpu --mem --disk --proc --load --top-cpu --top-mem 5" C-m

tmux send-keys -t "$SESSION_NAME":0.2 "echo '📝 Log tail (multi_run.log)'" C-m
tmux send-keys -t "$SESSION_NAME":0.2 "tail -f $LOG_DIR/multi_run.log" C-m

tmux split-window -v -t "$SESSION_NAME":0

tmux send-keys -t "$SESSION_NAME":0.3 "echo '🧠 CPU Monitor (ppgen_sabv_lmtr5) mỗi 10s'" C-m

tmux send-keys -t "$SESSION_NAME":0.3 "LOG=$LOG_DIR/cpu_monitor.log; echo 'timestamp pid cpu% mem% rssMB cmd' | tee -a $LOG_DIR/cpu_monitor.log; while true; do PID=\$(pgrep -f 'target/release/ppgen_sabv_lmtr5' | head -n1); if [ -n \"$PID\" ]; then ps -p $PID -o pid=,%cpu=,%mem=,rss=,cmd= | awk -v d=\"\$(date +'%Y-%m-%d %H:%M:%S')\" '{rssMB=$4/1024; printf \"%s %s %.0f %.1f %.1f %s\n\", d, $1, $2, $3, rssMB, $5}' | tee -a $LOG_DIR/cpu_monitor.log; else echo \"\$(date +'%Y-%m-%d %H:%M:%S') - waiting for process...\" | tee -a $LOG_DIR/cpu_monitor.log; fi; sleep 10; done" C-m

echo "✅ Tmux session created: $SESSION_NAME"
echo "📋 Attach with: tmux attach -t $SESSION_NAME"
