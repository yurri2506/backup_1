#!/usr/bin/env bash

################################################################################
# TEST N=100 với cấu hình mới (giống baseline nhưng RAYON_NUM_THREADS=16)
# 
# Cấu hình:
#   • RAYON_NUM_THREADS: 16 (tăng từ 8)
#   • SHARD_BATCH_SIZE: 1 (giống baseline)
#   • TRACE_GEN_WORKERS: 1 (giống baseline)
# 
# Usage:
#   ./test_n100.sh
################################################################################

set -e

# Configuration
BIN_DIR="/home/ubuntu/thanhhuyen/agglayer"
LOG_DIR="/home/ubuntu/thanhhuyen/logs/v5"
PROOF_DIR="/home/ubuntu/thanhhuyen/proofs/v5"
N=100
VALIDATORS=5

echo "═══════════════════════════════════════════════════════════════"
echo "🧪 TEST N=100 với cấu hình mới"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "📋 Configuration:"
echo "  • N: $N"
echo "  • Validator nodes: $VALIDATORS"
echo "  • RAYON_NUM_THREADS: 16 (tăng từ 8)"
echo "  • SHARD_BATCH_SIZE: 1 (giống baseline)"
echo "  • TRACE_GEN_WORKERS: 1 (giống baseline)"
echo "  • Expected memory: ~20-30GB (giống baseline)"
echo "  • Expected CPU: ~1400-1600% (tối đa CPU)"
echo ""

mkdir -p "$LOG_DIR" "$PROOF_DIR"
cd "$BIN_DIR"

LOG_FILE="$LOG_DIR/test_n100_$(date +%Y%m%d_%H%M%S).log"
PROOF_SUBDIR="$PROOF_DIR/test_n100"

mkdir -p "$PROOF_SUBDIR"
START_TIME=$(date +%s)

# Set SP1 config - CHỈ TĂNG RAYON_NUM_THREADS (giống baseline nhưng tối đa CPU)
export RAYON_NUM_THREADS=16
export RUST_LOG=sp1_sdk=info,sp1=info
export SP1_PROVER=cpu
export SP1_CARGO_PROVE_PATH=/home/ubuntu/.sp1/bin/cargo-prove
export SHARD_SIZE=2097152

# GIỮ NGUYÊN như baseline (SHARD_BATCH_SIZE=1, TRACE_GEN_WORKERS=1)
export SHARD_BATCH_SIZE=1
export TRACE_GEN_WORKERS=1

echo "   ⚙️  Config: SHARD_BATCH_SIZE=1, TRACE_GEN_WORKERS=1 (GIỮ NGUYÊN như baseline)"
echo "   ⚙️  RAYON_NUM_THREADS=16 (TĂNG từ 8 lên 16 - TỐI ĐA CPU)"
echo "   ⚙️  Expected CPU usage: ~1400-1600% (tối đa CPU với 16 threads)"
echo "   ⚙️  Expected memory: ~20-30GB (giữ nguyên như baseline)"
echo "   ⚙️  ✅ CHỈ THAY ĐỔI 1 THÔNG SỐ: RAYON_NUM_THREADS (8 → 16)"
echo ""
echo "   📁 Log: $LOG_FILE"
echo "   📁 Proof dir: $PROOF_SUBDIR"
echo ""
echo "🚀 Starting test at $(date '+%Y-%m-%d %H:%M:%S')..."
echo ""

# Run benchmark
/usr/bin/time -v cargo run --release -p pessimistic-proof-test-suite --bin ppgen_sabv_lmtr5 -- \
    --n-exits "$N" \
    --validator-nodes "$VALIDATORS" \
    --proof-dir "$PROOF_SUBDIR" \
    2>&1 | tee "$LOG_FILE"

EXIT_CODE=${PIPESTATUS[0]}
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "📊 TEST N=100 RESULTS"
echo "═══════════════════════════════════════════════════════════════"
echo "   Duration: ${DURATION}s ($(($DURATION / 60))m $(($DURATION % 60))s)"
echo "   Exit code: $EXIT_CODE"
echo ""

# Extract resource usage from time command
if grep -q "Maximum resident set size\|Percent of CPU\|Command terminated" "$LOG_FILE" 2>/dev/null; then
    echo "   📊 Resource Usage:"
    if grep -q "Command terminated by signal 9" "$LOG_FILE"; then
        echo "      ❌ Process bị KILL (signal 9) - có thể do OOM"
    else
        echo "      ✅ Process hoàn thành bình thường"
    fi
    MAX_RAM=$(grep "Maximum resident set size" "$LOG_FILE" | tail -1 | awk '{print $6}' | sed 's/k$//' 2>/dev/null || echo "0")
    if [ "$MAX_RAM" != "0" ] && [ "$MAX_RAM" != "" ]; then
        MAX_RAM_GB=$(echo "scale=2; $MAX_RAM / 1024 / 1024" | bc 2>/dev/null || echo "0")
        echo "      💾 Maximum RAM: ${MAX_RAM_GB} GB (${MAX_RAM} KB)"
    fi
    CPU_PERCENT=$(grep "Percent of CPU" "$LOG_FILE" | tail -1 | awk '{print $4}' | sed 's/%$//' 2>/dev/null || echo "0")
    if [ "$CPU_PERCENT" != "0" ] && [ "$CPU_PERCENT" != "" ]; then
        echo "      ⚡ CPU Usage: ${CPU_PERCENT}%"
    fi
fi

# Check result
if [ -f "$PROOF_SUBDIR/v5_proof_n${N}.json" ] || [ -f "$PROOF_SUBDIR/proof.bin" ]; then
    echo "   ✅ Proof file: TỒN TẠI"
    if [ -f "$PROOF_SUBDIR/v5_proof_n${N}.json" ]; then
        PROOF_SIZE=$(ls -lh "$PROOF_SUBDIR/v5_proof_n${N}.json" 2>/dev/null | awk '{print $5}' || echo "N/A")
        echo "      File: v5_proof_n${N}.json ($PROOF_SIZE)"
    fi
    if [ -f "$PROOF_SUBDIR/proof.bin" ]; then
        PROOF_SIZE=$(ls -lh "$PROOF_SUBDIR/proof.bin" 2>/dev/null | awk '{print $5}' || echo "N/A")
        echo "      File: proof.bin ($PROOF_SIZE)"
    fi
else
    echo "   ❌ Proof file: KHÔNG CÓ"
    if grep -q "signal 9\|killed\|OOM" "$LOG_FILE" 2>/dev/null; then
        echo "      ⚠️  Process có thể bị kill bởi OOM"
    fi
fi

echo ""
echo "   📁 Log: $LOG_FILE"
echo "   📁 Proof: $PROOF_SUBDIR"
echo ""

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ TEST N=100 HOÀN THÀNH THÀNH CÔNG"
else
    echo "❌ TEST N=100 THẤT BẠI (Exit code: $EXIT_CODE)"
fi

echo ""


