#!/usr/bin/env bash
# Helper script để chạy từng test và đo số liệu
# Usage: run_aggsandbox_test.sh <baseline|v5> <N> <sample_path> <log_dir> <proof_dir>

set -euo pipefail

TYPE="$1"
N="$2"
SAMPLE_PATH="${3:-}"
LOG_DIR="$4"
PROOF_DIR="$5"

# Get base directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$BASE_DIR/agglayer"

export SP1_PROVER=cpu
export RAYON_NUM_THREADS=8
export RUST_LOG=info

LOG_FILE="$LOG_DIR/${TYPE}_n${N}_$(date +%Y%m%d_%H%M%S).log"
mkdir -p "$PROOF_DIR"

echo "[$(date +%Y-%m-%d_%H:%M:%S)] Starting $TYPE N=$N" | tee -a "$LOG_DIR/run.log"

START_TIME=$(date +%s)

if [ "$TYPE" = "baseline" ]; then
    if [ -n "$SAMPLE_PATH" ] && [ -f "$SAMPLE_PATH" ]; then
        /usr/bin/time -v cargo run --release \
            -p pessimistic-proof-test-suite \
            --bin ppgen \
            -- \
            --n-exits "$N" \
            --n-imported-exits "$N" \
            --proof-dir "$PROOF_DIR" \
            --sample-path "$SAMPLE_PATH" \
            > "$LOG_FILE" 2>&1
    else
        /usr/bin/time -v cargo run --release \
            -p pessimistic-proof-test-suite \
            --bin ppgen \
            -- \
            --n-exits "$N" \
            --n-imported-exits "$N" \
            --proof-dir "$PROOF_DIR" \
            > "$LOG_FILE" 2>&1
    fi
    EXIT_CODE=$?
elif [ "$TYPE" = "v5" ]; then
    if [ -n "$SAMPLE_PATH" ] && [ -f "$SAMPLE_PATH" ]; then
        /usr/bin/time -v cargo run --release \
            -p pessimistic-proof-test-suite \
            --bin ppgen_sabv_lmtr5 \
            -- \
            --n-exits "$N" \
            --proof-dir "$PROOF_DIR" \
            --validator-nodes 5 \
            --input "$SAMPLE_PATH" \
            > "$LOG_FILE" 2>&1
    else
        /usr/bin/time -v cargo run --release \
            -p pessimistic-proof-test-suite \
            --bin ppgen_sabv_lmtr5 \
            -- \
            --n-exits "$N" \
            --proof-dir "$PROOF_DIR" \
            --validator-nodes 5 \
            > "$LOG_FILE" 2>&1
    fi
    EXIT_CODE=$?
else
    echo "Invalid type: $TYPE (must be 'baseline' or 'v5')"
    exit 1
fi

END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))

# Extract metrics from time command output
ELAPSED_TIME="N/A"
if grep -q "Elapsed (wall clock)" "$LOG_FILE"; then
    ELAPSED_TIME=$(grep "Elapsed (wall clock)" "$LOG_FILE" | tail -1 | sed -n 's/.*: \([0-9:]*\).*/\1/p')
fi

MAX_RAM_KB="0"
if grep -q "Maximum resident set size" "$LOG_FILE"; then
    MAX_RAM_KB=$(grep "Maximum resident set size" "$LOG_FILE" | tail -1 | awk '{print $6}' | sed 's/k$//')
fi
MAX_RAM_GB=$(echo "scale=2; $MAX_RAM_KB / 1024 / 1024" | bc 2>/dev/null || echo "0")

CPU_PERCENT="0"
if grep -q "Percent of CPU" "$LOG_FILE"; then
    CPU_PERCENT=$(grep "Percent of CPU" "$LOG_FILE" | tail -1 | awk '{print $4}' | sed 's/%$//')
fi

USER_TIME="N/A"
if grep -q "User time" "$LOG_FILE"; then
    USER_TIME=$(grep "User time" "$LOG_FILE" | tail -1 | awk '{print $4}')
fi

SYS_TIME="N/A"
if grep -q "System time" "$LOG_FILE"; then
    SYS_TIME=$(grep "System time" "$LOG_FILE" | tail -1 | awk '{print $4}')
fi

# Check fraud detection for V5
FRAUD_DETECTED="NO"
if [ "$TYPE" = "v5" ]; then
    if grep -q "FRAUD DETECTED\|SABV5: Fraud detected\|integrity verification FAILED" "$LOG_FILE"; then
        FRAUD_DETECTED="YES"
    fi
fi

# Try to find proof fixture for L1 verification
PROOF_FIXTURE=""
if [ -d "$PROOF_DIR" ]; then
    # Priority order: 
    # 1. exits file (baseline) - contains full PessimisticProofFixture with proof
    # 2. v5_proof file (V5) - contains full PessimisticProofFixture with proof
    # 3. Other proof files
    if [ "$TYPE" = "baseline" ]; then
        # Baseline: look for exits file first (has proof field)
        PROOF_FIXTURE=$(find "$PROOF_DIR" -maxdepth 1 -type f -name "*-exits-*.json" | head -1)
    else
        # V5: look for v5_proof file
        PROOF_FIXTURE=$(find "$PROOF_DIR" -maxdepth 1 -type f -name "v5_proof*.json" | head -1)
    fi
    # Fallback: try to find any JSON file that has a proof field
    if [ -z "$PROOF_FIXTURE" ] || [ ! -f "$PROOF_FIXTURE" ]; then
        for f in "$PROOF_DIR"/*.json; do
            [ -f "$f" ] && jq -e '.proof' "$f" >/dev/null 2>&1 && PROOF_FIXTURE="$f" && break
        done
    fi
fi

# L1 Verification (if proof fixture found)
L1_VERIFY_TIME="N/A"
L1_VERIFY_GAS="N/A"
L1_VERIFY_STATUS="SKIPPED"
SUMMARY_FILE="$LOG_DIR/summary.txt"
# Get script directory for verify_l1.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFY_L1_SCRIPT="$SCRIPT_DIR/verify_l1.sh"

if [ -n "$PROOF_FIXTURE" ] && [ -f "$PROOF_FIXTURE" ]; then
    VERIFY_START=$(date +%s)
    # Run L1 verification with timeout (max 60 seconds)
    timeout 60 "$VERIFY_L1_SCRIPT" "$PROOF_FIXTURE" "$SUMMARY_FILE" "$LOG_FILE" 2>&1 | tee -a "$LOG_FILE" || true
    VERIFY_END=$(date +%s)
    
    # Extract results from summary file (with retry in case file is being written)
    VERIFY_LINE=""
    for i in {1..5}; do
        VERIFY_LINE=$(grep "L1_VERIFY" "$SUMMARY_FILE" 2>/dev/null | tail -1 || echo "")
        [ -n "$VERIFY_LINE" ] && break
        sleep 1
    done
    if [ -n "$VERIFY_LINE" ]; then
        L1_VERIFY_TIME=$(echo "$VERIFY_LINE" | sed -n 's/.*Time=\([^,]*\).*/\1/p' || echo "N/A")
        L1_VERIFY_GAS=$(echo "$VERIFY_LINE" | sed -n 's/.*Gas=\([^,]*\).*/\1/p' || echo "N/A")
        if echo "$L1_VERIFY_TIME" | grep -q "FAILED"; then
            L1_VERIFY_STATUS="FAILED"
        elif [ "$L1_VERIFY_TIME" != "N/A" ]; then
            L1_VERIFY_STATUS="SUCCESS"
        else
            L1_VERIFY_STATUS="SKIPPED"
        fi
    fi
fi

# Log summary
{
    echo ""
    echo "[$(date +%Y-%m-%d_%H:%M:%S)] ========================================"
    echo "[$TYPE] N=$N Results:"
    echo "  Exit code: $EXIT_CODE"
    echo "  Elapsed time: $ELAPSED_TIME (${ELAPSED}s)"
    echo "  User time: $USER_TIME"
    echo "  System time: $SYS_TIME"
    echo "  CPU usage: ${CPU_PERCENT}%"
    echo "  Max RAM: ${MAX_RAM_GB} GB (${MAX_RAM_KB} KB)"
    if [ "$TYPE" = "v5" ]; then
        echo "  Fraud detected: $FRAUD_DETECTED"
    fi
    if [ "$L1_VERIFY_STATUS" != "SKIPPED" ]; then
        echo "  L1 verify status: $L1_VERIFY_STATUS"
        echo "  L1 verify time: ${L1_VERIFY_TIME}"
        echo "  L1 verify gas: ${L1_VERIFY_GAS}"
    fi
    echo "  Log file: $LOG_FILE"
    echo "========================================"
} | tee -a "$LOG_DIR/run.log"

# Also save to summary file
SUMMARY_FILE="$LOG_DIR/summary.txt"
{
    echo "$TYPE,N=$N,Exit=$EXIT_CODE,Time=$ELAPSED_TIME,User=$USER_TIME,Sys=$SYS_TIME,CPU=${CPU_PERCENT}%,RAM=${MAX_RAM_GB}GB,Fraud=$FRAUD_DETECTED,L1Verify=$L1_VERIFY_STATUS,L1VerifyTime=${L1_VERIFY_TIME},L1VerifyGas=${L1_VERIFY_GAS},Log=$LOG_FILE"
} >> "$SUMMARY_FILE"

if [ $EXIT_CODE -eq 0 ]; then
    echo "[$(date +%Y-%m-%d_%H:%M:%S)] ✅ $TYPE N=$N COMPLETED" | tee -a "$LOG_DIR/run.log"
else
    echo "[$(date +%Y-%m-%d_%H:%M:%S)] ❌ $TYPE N=$N FAILED (exit code: $EXIT_CODE)" | tee -a "$LOG_DIR/run.log"
fi

exit $EXIT_CODE

