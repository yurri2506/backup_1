#!/usr/bin/env bash
set -euo pipefail

# Thư mục log V5
LOG_DIR="/home/ubuntu/backup_1/logs/baseline_v5"
# Thư mục code agglayer
BIN_DIR="/home/ubuntu/backup_1/agglayer"
PKG="pessimistic-proof-test-suite"
BIN="ppgen_sabv_lmtr5"

# Số lần mục tiêu mỗi N (giống baseline: 10 runs)
TARGET_RUNS=10

# Các N baseline đã có số liệu
BASELINE_EXIT_COUNTS=(1 10 20 50 100 200 500 700)

mkdir -p "$LOG_DIR"
mkdir -p "$LOG_DIR/proofs"

command -v dstat >/dev/null 2>&1 || { echo "dstat not found. Install: sudo apt-get install -y dstat"; exit 1; }
command -v stress-ng >/dev/null 2>&1 || { echo "stress-ng not found. Install: sudo apt-get install -y stress-ng"; exit 1; }

cd "$BIN_DIR"

echo "[V5_FILL] ===== START $(date -u +'%Y-%m-%dT%H:%M:%SZ') =====" | tee -a "$LOG_DIR/fill_10runs.log"

# Start monitoring & stress ở background
dstat --time --cpu --mem --disk --proc --load --top-cpu --top-mem 1 > "$LOG_DIR/dstat_fill_10runs.log" 2>&1 &
DSTAT_PID=$!

echo "Starting stress-ng (16 CPU, 12x8G VM for max RAM pressure)" | tee -a "$LOG_DIR/fill_10runs.log"
stress-ng --cpu 16 --cpu-method all --vm 12 --vm-bytes 8G --vm-keep --timeout 999999s > "$LOG_DIR/stress_fill_10runs.log" 2>&1 &
STRESS_PID=$!

/bin/bash /home/ubuntu/backup_1/sp1_local_server.sh > "$LOG_DIR/sp1_server_fill_10runs.log" 2>&1 &
SP1_PID=$!

cleanup() {
  echo "[V5_FILL] Cleaning up background processes..." | tee -a "$LOG_DIR/fill_10runs.log"
  kill "$DSTAT_PID" "$STRESS_PID" "$SP1_PID" 2>/dev/null || true
}
trap cleanup EXIT

export SP1_PROVER="${SP1_PROVER:-cpu}"
export RAYON_NUM_THREADS=32
export OMP_NUM_THREADS=32
export SP1_CORE_OPTS_TRACE_GEN_WORKERS=8
ulimit -v unlimited || true

for N in "${BASELINE_EXIT_COUNTS[@]}"; do
  # Đếm tất cả log V5 hiện có cho N (round* + extra*)
  EXISTING=$(ls "$LOG_DIR"/proof_${BIN}_v5_${N}_*.no_input.log 2>/dev/null | wc -l || true)
  REMAIN=$((TARGET_RUNS - EXISTING))

  if [ "$REMAIN" -le 0 ]; then
    echo "[V5_FILL] N=${N} đã đủ >= $TARGET_RUNS runs (existing=${EXISTING}), skip" | tee -a "$LOG_DIR/fill_10runs.log"
    continue
  fi

  echo "[V5_FILL] N=${N} hiện có ${EXISTING} logs, cần chạy thêm ${REMAIN} để đủ $TARGET_RUNS" | tee -a "$LOG_DIR/fill_10runs.log"

  # Tạo index extra để không đụng file cũ
  START_INDEX=$((EXISTING + 1))
  END_INDEX=$TARGET_RUNS

  for ((idx=START_INDEX; idx<=END_INDEX; idx++)); do
    echo "[V5_FILL] N=${N} - EXTRA RUN ${idx}/${TARGET_RUNS}" | tee -a "$LOG_DIR/fill_10runs.log"
    RUN_TS=$(date -u +"%Y%m%dT%H%M%S")
    RUN_LABEL="extra${idx}_n${N}_${RUN_TS}"
    LOG_FILE="$LOG_DIR/proof_${BIN}_v5_${N}_extra${idx}.no_input.log"

    /usr/bin/time -v cargo run --release -p "$PKG" --bin "$BIN" -- \
      --n-exits "${N}" \
      --validator-nodes 5 \
      --proof-dir "$LOG_DIR/proofs" \
      --run-label "$RUN_LABEL" > "$LOG_FILE" 2>&1

    EXIT_CODE=$?
    if [ "$EXIT_CODE" -ne 0 ]; then
      echo "[V5_FILL] ⚠️  N=${N} EXTRA RUN ${idx} failed (exit $EXIT_CODE), retrying với --allow-fraud-testing..." | tee -a "$LOG_DIR/fill_10runs.log"
      RUN_LABEL_RETRY="extra${idx}_n${N}_${RUN_TS}_fraud_allowed"
      /usr/bin/time -v cargo run --release -p "$PKG" --bin "$BIN" -- \
        --n-exits "${N}" \
        --validator-nodes 5 \
        --proof-dir "$LOG_DIR/proofs" \
        --run-label "$RUN_LABEL_RETRY" \
        --allow-fraud-testing > "${LOG_FILE}.retry" 2>&1

      RETRY_EXIT=$?
      if [ "$RETRY_EXIT" -eq 0 ]; then
        echo "[V5_FILL] ✅ N=${N} EXTRA RUN ${idx} retry với fraud-allowed thành công" | tee -a "$LOG_DIR/fill_10runs.log"
      else
        echo "[V5_FILL] ❌ N=${N} EXTRA RUN ${idx} retry cũng failed (exit $RETRY_EXIT)" | tee -a "$LOG_DIR/fill_10runs.log"
      fi
    fi
  done
done

echo "[V5_FILL] ===== COMPLETED $(date -u +'%Y-%m-%dT%H:%M:%SZ') =====" | tee -a "$LOG_DIR/fill_10runs.log"

