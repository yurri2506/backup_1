#!/bin/bash

################################################################################
# L-MAPLE BENCHMARK SCRIPT - Combined SABV4 + LMTR4 + SP1 Proving
# 
# This script combines both single-test monitoring and sequential batch execution
# 
# Usage:
#   ./sabv_lmtr_v4.sh [mode] [N...]
# 
# Modes:
#   single    - Run single N with tmux monitoring (default N=1)
#   sequential - Run multiple N values sequentially (default N=2,5,10,20,50,100,200,500,700)
#   all       - Run both single and sequential
#
# Examples:
#   ./sabv_lmtr_v4.sh single 1
#   ./sabv_lmtr_v4.sh sequential 2 5 10
#   ./sabv_lmtr_v4.sh all
################################################################################

set -e

# Configuration
BIN_DIR="/home/ubuntu/thanhhuyen/agglayer"
LOG_DIR_SINGLE="/home/ubuntu/thanhhuyen/logs/sabl_maple_lmtr4"
LOG_DIR_SEQ="/home/ubuntu/thanhhuyen/logs/l_maple_seq"
PROOF_DIR="/home/ubuntu/thanhhuyen/proofs/l_maple"

# Default N values for sequential mode
DEFAULT_N_SEQ=(2 5 10 20 50 100 200 500 700)

# Parse arguments
MODE=${1:-"all"}

################################################################################
# Function: run_single_test
# Run single N test with tmux monitoring
################################################################################
run_single_test() {
    local N=${2:-1}
    local SESSION_NAME="sabl_maple_lmtr4_ppgen"
    
    echo "🚀 Starting L-MAPLE SINGLE Test - N=$N with tmux monitoring"
    echo "📁 Log directory: $LOG_DIR_SINGLE"
    mkdir -p "$LOG_DIR_SINGLE" "$PROOF_DIR"
    
    # Kill existing session if exists
    tmux has-session -t "$SESSION_NAME" 2>/dev/null && tmux kill-session -t "$SESSION_NAME" || true
    
    # Create tmux session
    tmux new-session -d -s "$SESSION_NAME" -c "$BIN_DIR"
    
    # Split into 4 panes
    tmux split-window -h -t "$SESSION_NAME":0
    tmux split-window -v -t "$SESSION_NAME":0.0
    tmux split-window -v -t "$SESSION_NAME":0.1
    
    # Pane 0.0: L-MAPLE REAL Algorithm Execution
    tmux send-keys -t "$SESSION_NAME":0.0 "echo '🎯 L-MAPLE REAL Algorithm Test Starting...'" C-m
    tmux send-keys -t "$SESSION_NAME":0.0 "date" C-m
    tmux send-keys -t "$SESSION_NAME":0.0 "echo 'Running L-MAPLE REAL algorithms with SP1 proving...'" C-m
    tmux send-keys -t "$SESSION_NAME":0.0 "/usr/bin/time -v RUST_LOG=sp1_sdk=debug,sp1=debug SP1_PROVER=cpu SP1_CARGO_PROVE_PATH=/home/ubuntu/.sp1/bin/cargo-prove cargo run --release -p pessimistic-proof-test-suite --bin ppgen_sabv_lmtr4 -- --n-exits $N --validator-nodes 5 --proof-dir $PROOF_DIR 2>&1 | tee $LOG_DIR_SINGLE/l_maple_n${N}_\$(date +%Y%m%d_%H%M%S).log" C-m
    
    # Pane 0.1: System monitoring
    tmux send-keys -t "$SESSION_NAME":0.1 "echo '📊 System Monitoring for L-MAPLE REAL Algorithm'" C-m
    tmux send-keys -t "$SESSION_NAME":0.1 "while true; do echo \"\$(date): CPU=\$(top -bn1 | grep 'Cpu(s)' | awk '{print \$2}' | cut -d'%' -f1)%, RAM=\$(free | grep Mem | awk '{printf \"%.1f%%\", \$3/\$2 * 100.0}'), Load=\$(uptime | awk '{print \$(NF-2)}' | cut -d',' -f1)\"; sleep 30; done" C-m
    
    # Pane 0.2: Log monitoring
    tmux send-keys -t "$SESSION_NAME":0.2 "echo '📝 L-MAPLE REAL Algorithm Log Monitor'" C-m
    tmux send-keys -t "$SESSION_NAME":0.2 "tail -f $LOG_DIR_SINGLE/l_maple_n${N}_*.log 2>/dev/null || echo 'Waiting for log file...'" C-m
    
    # Pane 0.3: Process monitoring
    tmux send-keys -t "$SESSION_NAME":0.3 "echo '🔍 Process Monitor for L-MAPLE REAL Algorithm'" C-m
    tmux send-keys -t "$SESSION_NAME":0.3 "while true; do echo \"\$(date): L-MAPLE processes:\"; ps aux | grep -E '(ppgen_sabv_lmtr4|cargo)' | grep -v grep; echo '---'; sleep 60; done" C-m
    
    echo "✅ L-MAPLE SINGLE Test tmux session created: $SESSION_NAME"
    echo "🔗 Attach with: tmux attach -t $SESSION_NAME"
    echo "📊 Monitor logs in: $LOG_DIR_SINGLE"
    echo "🎯 L-MAPLE uses REAL algorithms - NOT a simulator!"
    echo "🔐 REAL Shamir Secret Sharing + REAL ECDSA + REAL Tree Optimization + REAL SP1"
}

################################################################################
# Function: run_sequential_benchmark
# Run sequential batch benchmarks
################################################################################
run_sequential_benchmark() {
    # Get N values from arguments or use defaults
    if [ $# -gt 0 ]; then
        shift  # Remove 'sequential' mode
        N_VALUES=("$@")
    else
        N_VALUES=("${DEFAULT_N_SEQ[@]}")
    fi
    
    echo "🚀 Starting L-MAPLE SEQUENTIAL Benchmark"
    echo "N values: ${N_VALUES[@]}"
    echo "Proof dir: $PROOF_DIR"
    echo "Log dir: $LOG_DIR_SEQ"
    echo ""
    
    cd "$BIN_DIR/crates/pessimistic-proof-test-suite"
    
    for N in "${N_VALUES[@]}"; do
        echo "=========================================="
        echo "🔢 Starting N=$N"
        echo "=========================================="
        echo ""
        
        mkdir -p "$LOG_DIR_SEQ"
        LOG_FILE="$LOG_DIR_SEQ/l_maple_n${N}.log"
        START_TIME=$(date +%s)
        
        # Run with CPU/RAM monitoring in background
        (
            while kill -0 $$ 2>/dev/null; do
                ps aux | grep ppgen_sabv_lmtr4 | grep -v grep | awk '{print $3,$4}' >> "$LOG_DIR_SEQ/l_maple_n${N}_system.csv" 2>/dev/null || true
                sleep 5
            done
        ) &
        MONITOR_PID=$!
        
        # Run the benchmark
        cargo run --release --bin ppgen_sabv_lmtr4 -- \
            --n-exits "$N" \
            --validator-nodes 3 \
            --proof-dir "$PROOF_DIR" \
            2>&1 | tee "$LOG_FILE"
        
        END_TIME=$(date +%s)
        DURATION=$((END_TIME - START_TIME))
        
        # Kill monitor
        kill $MONITOR_PID 2>/dev/null || true
        
        echo ""
        echo "✅ N=$N completed in ${DURATION}s"
        echo ""
    done
    
    echo "=========================================="
    echo "🎉 All SEQUENTIAL benchmarks completed!"
    echo "=========================================="
}

################################################################################
# Function: run_all
# Run both single and sequential
################################################################################
run_all() {
    echo "╔════════════════════════════════════════════════════════════════════════╗"
    echo "║     L-MAPLE COMBINED BENCHMARK: Single Test + Sequential Batch              ║"
    echo "╚════════════════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Step 1: Run single test (detached in tmux)
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "STEP 1: Starting SINGLE test with tmux monitoring..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    run_single_test "single" 1
    
    echo ""
    echo "📝 Note: Single test running in tmux session 'sabl_maple_lmtr4_ppgen'"
    echo "   Attach anytime: tmux attach -t sabl_maple_lmtr4_ppgen"
    echo ""
    
    # Ask if user wants to wait or continue
    read -p "⏸️  Wait for N=1 single test to complete? (y/n) [n]: " WAIT_SINGLE
    
    if [[ "$WAIT_SINGLE" == "y" ]] || [[ "$WAIT_SINGLE" == "Y" ]]; then
        echo "Waiting for N=1 to complete..."
        while tmux has-session -t "sabl_maple_lmtr4_ppgen" 2>/dev/null; do
            sleep 10
        done
        echo "✅ N=1 single test completed!"
    else
        echo "⏭️  Skipping wait, will run sequential benchmarks in background"
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "STEP 2: Starting SEQUENTIAL batch benchmarks..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    run_sequential_benchmark
    
    echo ""
    echo "╔════════════════════════════════════════════════════════════════════════╗"
    echo "║     ✅ ALL L-MAPLE BENCHMARKS COMPLETED!                                     ║"
    echo "╚════════════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "📊 Results:"
    echo "   Single test: $LOG_DIR_SINGLE/"
    echo "   Sequential:  $LOG_DIR_SEQ/"
    echo "   Proofs:      $PROOF_DIR/"
}

################################################################################
# Main execution
################################################################################

case "$MODE" in
    single)
        if [ $# -gt 1 ]; then
            run_single_test "single" "$2"
        else
            run_single_test "single" 1
        fi
        ;;
    sequential)
        run_sequential_benchmark "$@"
        ;;
    all)
        run_all
        ;;
    help|--help|-h)
        echo "Usage: $0 [mode] [options]"
        echo ""
        echo "Modes:"
        echo "  single       Run single N test with tmux monitoring"
        echo "  sequential   Run sequential batch benchmarks"
        echo "  all          Run both single and sequential (interactive)"
        echo ""
        echo "Examples:"
        echo "  $0 single              # Run N=1 with tmux"
        echo "  $0 single 5            # Run N=5 with tmux"
        echo "  $0 sequential          # Run default N values"
        echo "  $0 sequential 2 5 10   # Run specific N values"
        echo "  $0 all                 # Run everything"
        ;;
    *)
        echo "❌ Unknown mode: $MODE"
        echo "Run '$0 help' for usage information"
        exit 1
        ;;
esac



