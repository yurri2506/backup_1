#!/usr/bin/env bash
################################################################################
# FRAUD TEST SCRIPT - Unified Script for Fraud Detection Experiments
# 
# Script này gộp chức năng của:
# - demo_fraud_detection.sh: Demo nhanh fraud detection
# - run_fraud_tests_multi_n.sh: Batch tests với nhiều N values
#
# Usage:
#   ./run_fraud_tests.sh demo [N]              # Demo fraud detection (N mặc định=10)
#   ./run_fraud_tests.sh batch [N1] [N2] ...   # Batch tests với nhiều N (mặc định: 1 10 100 500 700)
#   ./run_fraud_tests.sh help                  # Hiển thị hướng dẫn
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
BIN_DIR="$BASE_DIR/agglayer"
LOG_DIR="$BASE_DIR/logs/fraud_test"
PROOF_DIR="$BASE_DIR/proofs/fraud_test"
RESULTS_DIR="$BASE_DIR/fraud_test_results"

# Default configuration
VALIDATORS=5
NUM_RUNS=3
DEFAULT_N_VALUES=(1 10 100 500 700)

################################################################################
# Function: show_help
################################################################################
show_help() {
    cat << EOF
════════════════════════════════════════════════════════════════════
🔍 FRAUD TEST SCRIPT - Hướng Dẫn Sử Dụng
════════════════════════════════════════════════════════════════════

Usage:
  $0 <mode> [options]

Modes:
  demo [N]                    Demo fraud detection nhanh
                                - N: Số lượng blocks (mặc định: 10)
                                - Tạo wrong_global_root ngẫu nhiên
                                - Chạy 1 lần, hiển thị kết quả chi tiết

  batch [N1] [N2] ...         Batch tests với nhiều N values
                                - N values: Danh sách N (mặc định: 1 10 100 500 700)
                                - Mỗi N chạy 3 runs cho baseline và 3 runs cho V5
                                - Tạo summary file

  help                        Hiển thị hướng dẫn này

Examples:
  $0 demo                     # Demo với N=10
  $0 demo 100                 # Demo với N=100
  $0 batch                    # Batch test với N mặc định
  $0 batch 1 10 50            # Batch test với N=1, 10, 50

Output:
  - Logs: $LOG_DIR/
  - Proofs: $PROOF_DIR/
  - Results: $RESULTS_DIR/

EOF
}

################################################################################
# Function: run_demo
# Demo fraud detection với 1 test nhanh
################################################################################
run_demo() {
    local N=${1:-10}
    local DEMO_LOG_DIR="$LOG_DIR/demo"
    local DEMO_PROOF_DIR="$PROOF_DIR/demo"
    
    mkdir -p "$DEMO_LOG_DIR" "$DEMO_PROOF_DIR"
    
    # Generate wrong global_root (random 32 bytes)
    local WRONG_ROOT=$(openssl rand -hex 32)
    
    echo "════════════════════════════════════════════════════════════════════"
    echo "🔍 DEMO: V5 FRAUD DETECTION TEST"
    echo "════════════════════════════════════════════════════════════════════"
    echo ""
    echo "📋 Configuration:"
    echo "   • N (blocks): $N"
    echo "   • Validators: $VALIDATORS"
    echo "   • Wrong global_root: 0x$WRONG_ROOT"
    echo "   • Log file: $DEMO_LOG_DIR/demo_fraud.log"
    echo ""
    echo "🎯 Kỳ vọng:"
    echo "   • V5 sẽ phát hiện fraud trong Check 3 (blockchain integrity)"
    echo "   • Exit early với code 1 (không chạy SP1 proving)"
    echo "   • Thời gian: ~1-10 giây"
    echo ""
    
    export RUST_LOG=sp1_sdk=info,sp1=info,pessimistic_proof=info
    export SP1_PROVER=cpu
    export RAYON_NUM_THREADS=8
    
    cd "$BIN_DIR"
    
    local LOG_FILE="$DEMO_LOG_DIR/demo_fraud.log"
    
    echo "🔄 Chạy V5 với wrong_global_root..."
    echo ""
    
    local START=$(date +%s)
    set +e
    cargo run --release \
        -p pessimistic-proof-test-suite \
        --bin ppgen_sabv_lmtr5 \
        -- \
        --n-exits "$N" \
        --validator-nodes "$VALIDATORS" \
        --proof-dir "$DEMO_PROOF_DIR" \
        --wrong-global-root "0x$WRONG_ROOT" \
        2>&1 | tee "$LOG_FILE"
    local EXIT_CODE=$?
    set -e
    local END=$(date +%s)
    local ELAPSED=$((END - START))
    
    echo ""
    echo "════════════════════════════════════════════════════════════════════"
    echo "📊 KẾT QUẢ"
    echo "════════════════════════════════════════════════════════════════════"
    echo ""
    echo "⏱️  Thời gian: ${ELAPSED} giây"
    echo "🚪 Exit code: $EXIT_CODE"
    echo ""
    
    # Check fraud detection
    if grep -q "FRAUD DETECTED" "$LOG_FILE"; then
        echo "✅ FRAUD ĐÃ ĐƯỢC PHÁT HIỆN!"
        echo ""
        echo "📝 Chi tiết từ log:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        grep -A 5 "Check 3" "$LOG_FILE" | head -10
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        if [ $EXIT_CODE -eq 1 ]; then
            echo "✅ V5 đã exit early (code 1) - không chạy SP1 proving"
            echo "✅ Đúng như kỳ vọng - fraud detection hoạt động!"
        else
            echo "⚠️  Exit code không phải 1, nhưng fraud đã được phát hiện"
        fi
    else
        echo "❌ KHÔNG PHÁT HIỆN FRAUD"
        echo "⚠️  Điều này không đúng kỳ vọng"
        echo ""
        echo "📝 Kiểm tra log file: $LOG_FILE"
    fi
    
    echo ""
    echo "════════════════════════════════════════════════════════════════════"
    echo ""
    echo "📁 Log file: $LOG_FILE"
    echo "📁 Proof dir: $DEMO_PROOF_DIR"
    echo ""
}

################################################################################
# Function: run_baseline_test
# Chạy baseline test cho 1 N value và 1 run
################################################################################
run_baseline_test() {
    local N=$1
    local RUN=$2
    local LOG_FILE="$LOG_DIR/baseline_n${N}_run${RUN}_$(date +%Y%m%d_%H%M%S).log"
    local PROOF_SUBDIR="$PROOF_DIR/baseline_n${N}_run${RUN}"
    
    mkdir -p "$PROOF_SUBDIR"
    
    echo "   🔄 Baseline N=$N, Run $RUN..."
    
    local START=$(date +%s)
    set +e
    /usr/bin/time -v cargo run --release \
        -p pessimistic-proof-test-suite \
        --bin ppgen \
        -- \
        --n-exits "$N" \
        --n-imported-exits "$N" \
        --proof-dir "$PROOF_SUBDIR" \
        2>&1 | tee "$LOG_FILE"
    local EXIT_CODE=$?
    set -e
    local END=$(date +%s)
    local ELAPSED=$((END - START))
    
    # Extract time from log
    local TIME_STR="N/A"
    if grep -q "Elapsed (wall clock)" "$LOG_FILE"; then
        TIME_STR=$(grep "Elapsed (wall clock)" "$LOG_FILE" | tail -1 | sed -n 's/.*: \([0-9:]*\).*/\1/p')
    else
        TIME_STR="${ELAPSED}s"
    fi
    
    echo "      ⏱️  Time: $TIME_STR, Exit: $EXIT_CODE"
    
    echo "baseline,N=$N,Run=$RUN,Time=$TIME_STR,Exit=$EXIT_CODE,Log=$LOG_FILE" >> "$SUMMARY_FILE"
}

################################################################################
# Function: run_v5_test
# Chạy V5 test cho 1 N value và 1 run
################################################################################
run_v5_test() {
    local N=$1
    local RUN=$2
    local WRONG_ROOT=$3
    local LOG_FILE="$LOG_DIR/v5_n${N}_run${RUN}_$(date +%Y%m%d_%H%M%S).log"
    local PROOF_SUBDIR="$PROOF_DIR/v5_n${N}_run${RUN}"
    
    mkdir -p "$PROOF_SUBDIR"
    
    echo "   🚀 V5 N=$N, Run $RUN..."
    
    local START=$(date +%s)
    set +e
    /usr/bin/time -v cargo run --release \
        -p pessimistic-proof-test-suite \
        --bin ppgen_sabv_lmtr5 \
        -- \
        --n-exits "$N" \
        --validator-nodes "$VALIDATORS" \
        --proof-dir "$PROOF_SUBDIR" \
        --wrong-global-root "0x$WRONG_ROOT" \
        2>&1 | tee "$LOG_FILE"
    local EXIT_CODE=$?
    set -e
    local END=$(date +%s)
    local ELAPSED=$((END - START))
    
    # Extract time from log
    local TIME_STR="N/A"
    if grep -q "Elapsed (wall clock)" "$LOG_FILE"; then
        TIME_STR=$(grep "Elapsed (wall clock)" "$LOG_FILE" | tail -1 | sed -n 's/.*: \([0-9:]*\).*/\1/p')
    else
        TIME_STR="${ELAPSED}s"
    fi
    
    # Check if fraud was detected (parse "FRAUD DETECTED" message)
    local FRAUD_DETECTED="NO"
    if grep -q "FRAUD DETECTED" "$LOG_FILE"; then
        FRAUD_DETECTED="YES"
    fi
    
    echo "      ⏱️  Time: $TIME_STR, Exit: $EXIT_CODE, Fraud: $FRAUD_DETECTED"
    
    echo "v5,N=$N,Run=$RUN,Time=$TIME_STR,Exit=$EXIT_CODE,Fraud=$FRAUD_DETECTED,Log=$LOG_FILE" >> "$SUMMARY_FILE"
}

################################################################################
# Function: run_batch
# Chạy batch tests với nhiều N values
################################################################################
run_batch() {
    # Get N values from arguments or use defaults
    local N_VALUES=("${@}")
    if [ ${#N_VALUES[@]} -eq 0 ]; then
        N_VALUES=("${DEFAULT_N_VALUES[@]}")
    fi
    
    mkdir -p "$LOG_DIR" "$PROOF_DIR" "$RESULTS_DIR"
    
    # Generate wrong global_root (same for all tests to ensure consistency)
    local WRONG_ROOT=$(openssl rand -hex 32)
    
    echo "════════════════════════════════════════════════════════════════════"
    echo "🔍 FRAUD TEST - Multiple N values, $NUM_RUNS runs each"
    echo "════════════════════════════════════════════════════════════════════"
    echo ""
    echo "📋 Configuration:"
    echo "   • N values: ${N_VALUES[*]}"
    echo "   • Runs per N: $NUM_RUNS (baseline) + $NUM_RUNS (V5)"
    echo "   • Validators: $VALIDATORS"
    echo "   • Wrong global_root: 0x$WRONG_ROOT"
    echo "   • Log dir: $LOG_DIR"
    echo "   • Results dir: $RESULTS_DIR"
    echo ""
    
    export RUST_LOG=sp1_sdk=info,sp1=info,pessimistic_proof=info
    export SP1_PROVER=cpu
    export RAYON_NUM_THREADS=8
    
    cd "$BIN_DIR"
    
    # Results summary file
    SUMMARY_FILE="$RESULTS_DIR/summary_$(date +%Y%m%d_%H%M%S).txt"
    cat > "$SUMMARY_FILE" << EOF
════════════════════════════════════════════════════════════════════
FRAUD TEST RESULTS SUMMARY
════════════════════════════════════════════════════════════════════

Test Configuration:
  • N values: ${N_VALUES[*]}
  • Runs per N: $NUM_RUNS (baseline) + $NUM_RUNS (V5) = $(($NUM_RUNS * 2)) total
  • Validators: $VALIDATORS
  • Wrong global_root: 0x$WRONG_ROOT
  • Test date: $(date)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BASELINE RESULTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
    
    # Run tests for each N value
    for N in "${N_VALUES[@]}"; do
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📊 Testing with N=$N"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        
        echo "" >> "$SUMMARY_FILE"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >> "$SUMMARY_FILE"
        echo "N=$N" >> "$SUMMARY_FILE"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >> "$SUMMARY_FILE"
        
        # Run baseline tests
        echo "🔄 BASELINE Tests (N=$N):"
        for RUN in $(seq 1 $NUM_RUNS); do
            run_baseline_test "$N" "$RUN"
        done
        
        echo ""
        
        # Run V5 tests
        echo "🚀 V5 Tests (N=$N):"
        for RUN in $(seq 1 $NUM_RUNS); do
            run_v5_test "$N" "$RUN" "$WRONG_ROOT"
        done
        
        echo ""
        echo "✅ Completed all tests for N=$N"
        echo ""
    done
    
    # Add summary section
    cat >> "$SUMMARY_FILE" << EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Test completed at: $(date)

Expected Results:
  • Baseline: Should complete full SP1 proving (no early fraud detection)
  • V5: Should detect fraud early at SABV5 level (exit code 1, short time)

Log files location: $LOG_DIR
Proof files location: $PROOF_DIR

EOF
    
    echo ""
    echo "════════════════════════════════════════════════════════════════════"
    echo "✅ All tests completed!"
    echo "════════════════════════════════════════════════════════════════════"
    echo ""
    echo "📄 Summary saved to: $SUMMARY_FILE"
    echo ""
    cat "$SUMMARY_FILE"
}

################################################################################
# Main execution
################################################################################

MODE=${1:-help}

case "$MODE" in
    demo)
        shift
        run_demo "$@"
        ;;
    batch)
        shift
        run_batch "$@"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "❌ Unknown mode: $MODE"
        echo ""
        show_help
        exit 1
        ;;
esac


