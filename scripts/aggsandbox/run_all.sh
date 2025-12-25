#!/usr/bin/env bash
set -euo pipefail

# Script chạy toàn bộ test Baseline và V5 với AggSandbox
# Chạy tuần tự: baseline cho tất cả N, sau đó V5 cho tất cả N

# Get script directory and base directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
AGGLAYER_DIR="${AGGLAYER_DIR:-$BASE_DIR/agglayer}"
AGGSANDBOX_DIR="${AGGSANDBOX_DIR:-$BASE_DIR/aggsandbox}"
LOG_DIR="$BASE_DIR/logs/aggsandbox_exp"
EXIT_COUNTS="${EXIT_COUNTS:-1 10 50 100}"

echo "═══════════════════════════════════════════════════════════"
echo "🧪 AGGSANDBOX EXPERIMENTS: BASELINE + V5"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "📁 AggLayer: $AGGLAYER_DIR"
echo "📁 AggSandbox: $AGGSANDBOX_DIR"
echo "🗂 Logs: $LOG_DIR"
echo "📊 Exit counts: $EXIT_COUNTS"
echo ""

# Check prerequisites
command -v cargo >/dev/null 2>&1 || { echo "❌ cargo not found"; exit 1; }
command -v aggsandbox >/dev/null 2>&1 || { echo "❌ aggsandbox not found. Install: cd aggsandbox && make install"; exit 1; }

mkdir -p "$LOG_DIR/baseline/proofs" "$LOG_DIR/v5/proofs"
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
VERIFY_L1_SCRIPT="$SCRIPT_DIR/verify_l1.sh"

if [ -n "$SAMPLE" ]; then
  echo "📄 Using sample file: $SAMPLE"
else
  echo "📄 Using default sample data from code"
fi

# Setup AggSandbox environment
echo ""
echo "🔧 Setting up AggSandbox..."
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

# Initialize summary file (append if exists, create if not)
SUMMARY_FILE="$LOG_DIR/summary.txt"
if [ ! -f "$SUMMARY_FILE" ]; then
  echo "# AggSandbox Experiments Summary - $(date)" > "$SUMMARY_FILE"
  echo "# Format: TYPE,N=...,Exit=...,Time=...,User=...,Sys=...,CPU=...%,RAM=...GB,Fraud=...,L1Verify=...,L1VerifyTime=...,L1VerifyGas=...,Log=..." >> "$SUMMARY_FILE"
  echo "" >> "$SUMMARY_FILE"
else
  echo "" >> "$SUMMARY_FILE"
  echo "# Continuing experiments - $(date)" >> "$SUMMARY_FILE"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "🔬 STARTING BASELINE EXPERIMENTS"
echo "═══════════════════════════════════════════════════════════"
echo "" | tee -a "$LOG_DIR/run.log"
echo "[$(date +%Y-%m-%d_%H:%M:%S)] Starting BASELINE experiments" | tee -a "$LOG_DIR/run.log"
echo "Exit counts: $EXIT_COUNTS" | tee -a "$LOG_DIR/run.log"

# Run Baseline experiments
for N in $EXIT_COUNTS; do
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "[$(date +%Y-%m-%d_%H:%M:%S)] 🔬 BASELINE N=$N"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  
  if [ -n "$SAMPLE" ]; then
    "$RUN_TEST_SCRIPT" baseline "$N" "$SAMPLE" "$LOG_DIR" "$LOG_DIR/baseline/proofs"
  else
    "$RUN_TEST_SCRIPT" baseline "$N" "" "$LOG_DIR" "$LOG_DIR/baseline/proofs"
  fi
  
  echo ""
  echo "[$(date +%Y-%m-%d_%H:%M:%S)] ✅ BASELINE N=$N completed"
  echo ""
done

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "🧬 STARTING V5 EXPERIMENTS"
echo "═══════════════════════════════════════════════════════════"
echo "" | tee -a "$LOG_DIR/run.log"
echo "[$(date +%Y-%m-%d_%H:%M:%S)] Starting V5 (SABV5+LMTR4) experiments" | tee -a "$LOG_DIR/run.log"
echo "Exit counts: $EXIT_COUNTS" | tee -a "$LOG_DIR/run.log"

# Run V5 experiments
for N in $EXIT_COUNTS; do
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "[$(date +%Y-%m-%d_%H:%M:%S)] 🧬 V5 (SABV5+LMTR4) N=$N"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  
  if [ -n "$SAMPLE" ]; then
    "$RUN_TEST_SCRIPT" v5 "$N" "$SAMPLE" "$LOG_DIR" "$LOG_DIR/v5/proofs"
  else
    "$RUN_TEST_SCRIPT" v5 "$N" "" "$LOG_DIR" "$LOG_DIR/v5/proofs"
  fi
  
  echo ""
  echo "[$(date +%Y-%m-%d_%H:%M:%S)] ✅ V5 N=$N completed"
  echo ""
done

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "✅ ALL EXPERIMENTS COMPLETED"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "[$(date +%Y-%m-%d_%H:%M:%S)] All experiments completed!" | tee -a "$LOG_DIR/run.log"
echo ""
echo "📊 Summary saved to: $SUMMARY_FILE"
echo ""
echo "📋 View summary:"
echo "   cat $SUMMARY_FILE"
echo ""
echo "📋 Generate report:"
echo "   $SCRIPT_DIR/generate_report.sh"
echo ""
echo "═══════════════════════════════════════════════════════════"
