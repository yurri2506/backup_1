#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="/home/ubuntu/backup_1/logs/baseline_v5"
PROOF_DIR="$LOG_DIR/proofs"
BIN_DIR="/home/ubuntu/backup_1/agglayer"
PKG="pessimistic-proof-test-suite"
BIN="ppgen_sabv_lmtr5"
TARGET_ROUNDS="${TARGET_ROUNDS:-5}"
EXIT_COUNTS="${EXIT_COUNTS:-10 50 100 200 500 700}"

mkdir -p "$LOG_DIR" "$PROOF_DIR"

cd "$BIN_DIR"

export SP1_PROVER="${SP1_PROVER:-cpu}"
export RAYON_NUM_THREADS="${RAYON_NUM_THREADS:-32}"
export OMP_NUM_THREADS="${OMP_NUM_THREADS:-32}"
export SP1_CORE_OPTS_TRACE_GEN_WORKERS="${SP1_CORE_OPTS_TRACE_GEN_WORKERS:-8}"
ulimit -v unlimited

echo "[V5_TOPUP] ===== START $(date -u +'%Y-%m-%dT%H:%M:%SZ') =====" | tee -a "$LOG_DIR/run.log"

for N in $EXIT_COUNTS; do
    shopt -s nullglob
    existing_logs=("$LOG_DIR/proof_${BIN}_v5_${N}_round"*.no_input.log)
    shopt -u nullglob

    existing_count=${#existing_logs[@]}
    max_round=0
    for file in "${existing_logs[@]}"; do
        base=$(basename "$file")
        round_part=${base#*_round}
        round_num=${round_part%%.*}
        if [[ "$round_num" =~ ^[0-9]+$ ]]; then
            if (( round_num > max_round )); then
                max_round=$round_num
            fi
        fi
    done

    if (( existing_count >= TARGET_ROUNDS )); then
        echo "[V5_TOPUP] N=$N đã đủ $existing_count/$TARGET_ROUNDS rounds, bỏ qua" | tee -a "$LOG_DIR/run.log"
        continue
    fi

    needed=$(( TARGET_ROUNDS - existing_count ))
    echo "[V5_TOPUP] N=$N cần chạy thêm $needed rounds (hiện có $existing_count)" | tee -a "$LOG_DIR/run.log"

    for i in $(seq 1 $needed); do
        round=$((max_round + i))
        RUN_TS=$(date -u +"%Y%m%dT%H%M%S")
        RUN_LABEL="round${round}_n${N}_${RUN_TS}"
        LOG_FILE="$LOG_DIR/proof_${BIN}_v5_${N}_round${round}.no_input.log"

        echo "[V5_TOPUP] ▶️  N=$N round#$round bắt đầu" | tee -a "$LOG_DIR/run.log"
        /usr/bin/time -v cargo run --release -p "$PKG" --bin "$BIN" -- \
            --n-exits "$N" \
            --validator-nodes 5 \
            --proof-dir "$PROOF_DIR" \
            --run-label "$RUN_LABEL" \
            >"$LOG_FILE" 2>&1
        EXIT_CODE=$?

        if [ $EXIT_CODE -ne 0 ]; then
            echo "[V5_TOPUP] ⚠️  N=$N round#$round fail (exit $EXIT_CODE), retry với --allow-fraud-testing" | tee -a "$LOG_DIR/run.log"
            RUN_LABEL_RETRY="${RUN_LABEL}_fraud_allowed"
            /usr/bin/time -v cargo run --release -p "$PKG" --bin "$BIN" -- \
                --n-exits "$N" \
                --validator-nodes 5 \
                --proof-dir "$PROOF_DIR" \
                --run-label "$RUN_LABEL_RETRY" \
                --allow-fraud-testing \
                >"${LOG_FILE}.retry" 2>&1
            RETRY_EXIT=$?
            if [ $RETRY_EXIT -eq 0 ]; then
                echo "[V5_TOPUP] ✅ N=$N round#$round retry thành công" | tee -a "$LOG_DIR/run.log"
            else
                echo "[V5_TOPUP] ❌ N=$N round#$round retry fail (exit $RETRY_EXIT)" | tee -a "$LOG_DIR/run.log"
            fi
        else
            echo "[V5_TOPUP] ✅ N=$N round#$round hoàn tất" | tee -a "$LOG_DIR/run.log"
        fi
    done
done

echo "[V5_TOPUP] ===== DONE $(date -u +'%Y-%m-%dT%H:%M:%SZ') =====" | tee -a "$LOG_DIR/run.log"

