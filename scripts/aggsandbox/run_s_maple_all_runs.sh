#!/usr/bin/env bash
set -euo pipefail

# Script chạy S-MAPLE với tất cả các N, mỗi N chạy 5 lần
# Usage: ./run_s_maple_all_runs.sh [NUM_RUNS]
# Default: NUM_RUNS=5

# Get script directory and base directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
AGGLAYER_DIR="${AGGLAYER_DIR:-$BASE_DIR/agglayer}"
AGGSANDBOX_DIR="${AGGSANDBOX_DIR:-$BASE_DIR/aggsandbox}"
LOG_DIR="$BASE_DIR/logs/aggsandbox_exp"
EXIT_COUNTS="${EXIT_COUNTS:-1 10 50 100}"
NUM_RUNS="${1:-5}"

echo "═══════════════════════════════════════════════════════════"
echo "🧬 AGGSANDBOX EXPERIMENTS: S-MAPLE - ALL N VALUES - $NUM_RUNS RUNS EACH"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "📁 AggLayer: $AGGLAYER_DIR"
echo "📁 AggSandbox: $AGGSANDBOX_DIR"
echo "🗂 Logs: $LOG_DIR"
echo "📊 Exit counts: $EXIT_COUNTS"
echo "🔄 Number of runs per N: $NUM_RUNS"
echo ""

# Check prerequisites
command -v cargo >/dev/null 2>&1 || { echo "❌ cargo not found"; exit 1; }
command -v aggsandbox >/dev/null 2>&1 || { echo "❌ aggsandbox not found. Install: cd aggsandbox && make install"; exit 1; }

mkdir -p "$LOG_DIR/s_maple/proofs"
mkdir -p "$LOG_DIR"

# Resolve sample path (use artifact file if exists)
SAMPLE="$BASE_DIR/agglayer_aggsandbox/artifacts/bridge_test_data_multi_l2.json"
if [ ! -f "$SAMPLE" ]; then
  if [ -f "$BASE_DIR/agglayer_aggsandbox/artifacts/bridge_test_data_fixed.json" ]; then
    SAMPLE="$BASE_DIR/agglayer_aggsandbox/artifacts/bridge_test_data_fixed.json"
  else
    echo "⚠️  Warning: Sample file not found at $SAMPLE"
    echo "   Will use default sample data from code"
    SAMPLE=""
  fi
fi

# Script paths
RUN_TEST_SCRIPT="$SCRIPT_DIR/run_test.sh"

if [ -n "$SAMPLE" ]; then
  echo "📄 Using sample file: $SAMPLE"
else
  echo "📄 Using default sample data from code"
fi

# Setup AggSandbox environment
echo ""
echo "🔧 Checking AggSandbox..."
cd "$AGGSANDBOX_DIR"
if [ ! -f .env ]; then
  echo "   Creating .env from .env.example..."
  cp .env.example .env 2>/dev/null || echo "   .env.example not found, using default"
fi

# Check AggSandbox status
echo ""
echo "🔎 Checking AggSandbox status..."
if aggsandbox status 2>/dev/null | grep -q "running\|Running"; then
  echo "   ✅ AggSandbox is already running"
else
  echo "   🚀 Starting AggSandbox (multi-L2 mode)..."
  source .env 2>/dev/null || true
  aggsandbox start --multi-l2 --detach
  echo "   ⏳ Waiting 15 seconds for services to start..."
  sleep 15
  
  # Seed some bridge transactions
  echo "   🌉 Seeding bridge transactions..."
  aggsandbox bridge asset --network-id 0 --destination-network-id 1 --amount 1000000000000000000 --token-address 0x0000000000000000000000000000000000000000 2>/dev/null || true
  sleep 2
  aggsandbox bridge asset --network-id 0 --destination-network-id 2 --amount 2000000000000000000 --token-address 0x0000000000000000000000000000000000000000 2>/dev/null || true
  echo "   ✅ Bridge seeding complete"
fi

cd "$BASE_DIR"

# Initialize summary file (append if exists)
SUMMARY_FILE="$LOG_DIR/summary.txt"
if [ ! -f "$SUMMARY_FILE" ]; then
  echo "# AggSandbox Experiments Summary - $(date)" > "$SUMMARY_FILE"
  echo "# Format: TYPE,N=...,Exit=...,Time=...,User=...,Sys=...,CPU=...%,RAM=...GB,Fraud=...,L1Verify=...,L1VerifyTime=...,L1VerifyGas=...,Log=..." >> "$SUMMARY_FILE"
  echo "" >> "$SUMMARY_FILE"
else
  echo "" >> "$SUMMARY_FILE"
  echo "# Starting S-MAPLE experiments with $NUM_RUNS runs per N - $(date)" >> "$SUMMARY_FILE"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "🧬 STARTING S-MAPLE EXPERIMENTS - $NUM_RUNS RUNS PER N"
echo "═══════════════════════════════════════════════════════════"
echo "" | tee -a "$LOG_DIR/run.log"
echo "[$(date +%Y-%m-%d_%H:%M:%S)] Starting S-MAPLE (SABV5+LMTR4) experiments" | tee -a "$LOG_DIR/run.log"
echo "Exit counts: $EXIT_COUNTS" | tee -a "$LOG_DIR/run.log"
echo "Number of runs per N: $NUM_RUNS" | tee -a "$LOG_DIR/run.log"

TOTAL_START=$(date +%s)

# Run S-MAPLE experiments - loop through each N, then loop through runs
for N in $EXIT_COUNTS; do
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "[$(date +%Y-%m-%d_%H:%M:%S)] 🧬 S-MAPLE (SABV5+LMTR4) N=$N - Starting $NUM_RUNS runs"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  
  N_START=$(date +%s)
  
  # Loop through runs for this N
  for RUN in $(seq 1 $NUM_RUNS); do
    echo ""
    echo "  ───────────────────────────────────────────────────────────"
    echo "  [$(date +%Y-%m-%d_%H:%M:%S)] Run $RUN/$NUM_RUNS for N=$N"
    echo "  ───────────────────────────────────────────────────────────"
    echo ""
    
    RUN_START=$(date +%s)
    
    # Create separate proof directory for each run
    PROOF_DIR_RUN="$LOG_DIR/s_maple/proofs/n${N}_run${RUN}"
    mkdir -p "$PROOF_DIR_RUN"
    
    if [ -n "$SAMPLE" ]; then
      "$RUN_TEST_SCRIPT" s_maple "$N" "$SAMPLE" "$LOG_DIR" "$PROOF_DIR_RUN"
    else
      "$RUN_TEST_SCRIPT" s_maple "$N" "" "$LOG_DIR" "$PROOF_DIR_RUN"
    fi
    
    RUN_END=$(date +%s)
    RUN_ELAPSED=$((RUN_END - RUN_START))
    RUN_ELAPSED_MIN=$((RUN_ELAPSED / 60))
    RUN_ELAPSED_SEC=$((RUN_ELAPSED % 60))
    
    echo ""
    echo "  [$(date +%Y-%m-%d_%H:%M:%S)] ✅ Run $RUN/$NUM_RUNS for N=$N completed in ${RUN_ELAPSED_MIN}m ${RUN_ELAPSED_SEC}s"
    echo ""
    
    # Small delay between runs (optional, to avoid overwhelming the system)
    if [ $RUN -lt $NUM_RUNS ]; then
      echo "  ⏳ Waiting 5 seconds before next run..."
      sleep 5
    fi
  done
  
  N_END=$(date +%s)
  N_ELAPSED=$((N_END - N_START))
  N_ELAPSED_HOUR=$((N_ELAPSED / 3600))
  N_ELAPSED_MIN=$(((N_ELAPSED % 3600) / 60))
  
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "[$(date +%Y-%m-%d_%H:%M:%S)] ✅ S-MAPLE N=$N - All $NUM_RUNS runs completed in ${N_ELAPSED_HOUR}h ${N_ELAPSED_MIN}m"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
done

TOTAL_END=$(date +%s)
TOTAL_ELAPSED=$((TOTAL_END - TOTAL_START))
TOTAL_ELAPSED_HOUR=$((TOTAL_ELAPSED / 3600))
TOTAL_ELAPSED_MIN=$(((TOTAL_ELAPSED % 3600) / 60))

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "✅ ALL S-MAPLE EXPERIMENTS COMPLETED"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "[$(date +%Y-%m-%d_%H:%M:%S)] All S-MAPLE experiments completed!" | tee -a "$LOG_DIR/run.log"
echo "Total time: ${TOTAL_ELAPSED_HOUR}h ${TOTAL_ELAPSED_MIN}m" | tee -a "$LOG_DIR/run.log"
echo ""
echo "📊 Summary saved to: $SUMMARY_FILE"
echo ""
echo "📋 View summary:"
echo "   cat $SUMMARY_FILE"
echo ""
echo "📈 Quick stats:"
grep "^s_maple,N=" "$SUMMARY_FILE" 2>/dev/null | tail -20 || echo "   (No results yet)"
echo ""

