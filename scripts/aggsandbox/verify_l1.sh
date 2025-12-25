#!/usr/bin/env bash
# Verify proof trên L1 contract và đo thời gian verify (full version)
# Usage: verify_proof_l1_full.sh <proof_fixture_json> <summary_file> <log_file>

set -euo pipefail

PROOF_FIXTURE="$1"
SUMMARY_FILE="$2"
LOG_FILE="$3"

if [ ! -f "$PROOF_FIXTURE" ]; then
    echo "⚠️  Proof fixture not found: $PROOF_FIXTURE" | tee -a "$SUMMARY_FILE" | tee -a "$LOG_FILE"
    exit 0
fi

# Get base directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Get contract address from aggsandbox
AGGSANDBOX_ENV="${AGGSANDBOX_ENV:-$BASE_DIR/aggsandbox/.env}"
L1_RPC="${L1_RPC:-http://localhost:8545}"

if [ ! -f "$AGGSANDBOX_ENV" ]; then
    echo "⚠️  AggSandbox .env not found, skipping L1 verification" | tee -a "$SUMMARY_FILE" | tee -a "$LOG_FILE"
    exit 0
fi

source "$AGGSANDBOX_ENV" 2>/dev/null || true

ROLLUP_MANAGER="${POLYGON_ROLLUP_MANAGER_L1:-}"
if [ -z "$ROLLUP_MANAGER" ]; then
    echo "⚠️  POLYGON_ROLLUP_MANAGER_L1 not found, skipping L1 verification" | tee -a "$SUMMARY_FILE" | tee -a "$LOG_FILE"
    exit 0
fi

# Check if cast and jq are available
if ! command -v cast >/dev/null 2>&1; then
    echo "⚠️  cast not found, skipping L1 verification (install foundry)" | tee -a "$SUMMARY_FILE" | tee -a "$LOG_FILE"
    exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "⚠️  jq not found, skipping L1 verification" | tee -a "$SUMMARY_FILE" | tee -a "$LOG_FILE"
    exit 0
fi

echo "[$(date +%Y-%m-%d_%H:%M:%S)] Starting L1 verification..." | tee -a "$LOG_FILE" | tee -a "$SUMMARY_FILE"
echo "   Contract: $ROLLUP_MANAGER" | tee -a "$LOG_FILE" | tee -a "$SUMMARY_FILE"
echo "   RPC: $L1_RPC" | tee -a "$LOG_FILE" | tee -a "$SUMMARY_FILE"

# Extract certificate data from proof fixture
# Try both formats: direct certificate or PessimisticProofFixture format
CERT_JSON=""
if jq -e '.certificate' "$PROOF_FIXTURE" >/dev/null 2>&1; then
    CERT_JSON=$(jq '.certificate' "$PROOF_FIXTURE")
elif jq -e '.network_id' "$PROOF_FIXTURE" >/dev/null 2>&1; then
    CERT_JSON=$(cat "$PROOF_FIXTURE")
else
    echo "⚠️  Cannot parse certificate from proof fixture" | tee -a "$SUMMARY_FILE" | tee -a "$LOG_FILE"
    exit 0
fi

NETWORK_ID=$(echo "$CERT_JSON" | jq -r '.network_id // 1')
NEW_LOCAL_EXIT_ROOT=$(echo "$CERT_JSON" | jq -r '.new_local_exit_root // empty')
L1_INFO_TREE_LEAF_COUNT=$(echo "$CERT_JSON" | jq -r '.l1_info_tree_leaf_count // empty')

# Extract proof from fixture
if jq -e '.proof' "$PROOF_FIXTURE" >/dev/null 2>&1; then
    PROOF_HEX=$(jq -r '.proof // empty' "$PROOF_FIXTURE" 2>/dev/null | sed 's/^0x//')
else
    echo "⚠️  Proof not found in fixture, skipping L1 verification" | tee -a "$SUMMARY_FILE" | tee -a "$LOG_FILE"
    exit 0
fi

if [ -z "$NEW_LOCAL_EXIT_ROOT" ] || [ -z "$PROOF_HEX" ]; then
    echo "⚠️  Missing required data, skipping L1 verification" | tee -a "$SUMMARY_FILE" | tee -a "$LOG_FILE"
    exit 0
fi

# Get rollupID from chainID mapping
# For AggSandbox: L2-1 has chainID 1101, L2-2 has chainID 137
CHAIN_ID=""
case "$NETWORK_ID" in
    1) CHAIN_ID="1101" ;;  # L2-1
    2) CHAIN_ID="137" ;;   # L2-2
    *) CHAIN_ID="" ;;
esac

if [ -z "$CHAIN_ID" ]; then
    echo "⚠️  Unknown network_id $NETWORK_ID, cannot determine chainID" | tee -a "$SUMMARY_FILE" | tee -a "$LOG_FILE"
    exit 0
fi

# Get rollupID from contract using chainID
ROLLUP_ID=$(cast call "$ROLLUP_MANAGER" "chainIDToRollupID(uint64)(uint32)" "$CHAIN_ID" --rpc-url "$L1_RPC" 2>/dev/null || echo "0")
ROLLUP_ID=$(echo "$ROLLUP_ID" | xargs)  # trim whitespace

if [ "$ROLLUP_ID" = "0" ] || [ -z "$ROLLUP_ID" ]; then
    echo "⚠️  RollupID not found for chainID $CHAIN_ID, pessimistic rollup may not be configured" | tee -a "$SUMMARY_FILE" | tee -a "$LOG_FILE"
    echo "   Note: L1 verification requires pessimistic rollup setup" | tee -a "$SUMMARY_FILE" | tee -a "$LOG_FILE"
    exit 0
fi

echo "   RollupID: $ROLLUP_ID (chainID: $CHAIN_ID)" | tee -a "$LOG_FILE" | tee -a "$SUMMARY_FILE"

# Get newPessimisticRoot (need to extract from certificate or calculate)
# For now, we'll skip if not available
NEW_PESSIMISTIC_ROOT="0x0000000000000000000000000000000000000000000000000000000000000000"

# Default l1InfoTreeLeafCount if not provided
if [ -z "$L1_INFO_TREE_LEAF_COUNT" ] || [ "$L1_INFO_TREE_LEAF_COUNT" = "null" ]; then
    L1_INFO_TREE_LEAF_COUNT="0"
fi

# Private key for trusted aggregator (from AggSandbox default account)
PRIVATE_KEY="${PRIVATE_KEY:-0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80}"

echo "[$(date +%Y-%m-%d_%H:%M:%S)] Attempting L1 verification..." | tee -a "$LOG_FILE" | tee -a "$SUMMARY_FILE"
echo "   Parameters:" | tee -a "$LOG_FILE" | tee -a "$SUMMARY_FILE"
echo "     - rollupID: $ROLLUP_ID" | tee -a "$LOG_FILE" | tee -a "$SUMMARY_FILE"
echo "     - l1InfoTreeLeafCount: $L1_INFO_TREE_LEAF_COUNT" | tee -a "$LOG_FILE" | tee -a "$SUMMARY_FILE"
echo "     - newLocalExitRoot: $NEW_LOCAL_EXIT_ROOT" | tee -a "$LOG_FILE" | tee -a "$SUMMARY_FILE"

# Measure verification time
VERIFY_START=$(date +%s.%N)
VERIFY_GAS="N/A"

# Call verifyPessimisticTrustedAggregator via cast
# Note: This will fail if pessimistic rollup is not properly configured
set +e
TX_HASH=$(cast send "$ROLLUP_MANAGER" \
    "verifyPessimisticTrustedAggregator(uint32,uint32,bytes32,bytes32,bytes,bytes)" \
    "$ROLLUP_ID" \
    "$L1_INFO_TREE_LEAF_COUNT" \
    "$NEW_LOCAL_EXIT_ROOT" \
    "$NEW_PESSIMISTIC_ROOT" \
    "0x$PROOF_HEX" \
    "0x" \
    --rpc-url "$L1_RPC" \
    --private-key "$PRIVATE_KEY" \
    --gas-limit 10000000 \
    2>&1 | tee -a "$LOG_FILE" | grep -oE "0x[a-fA-F0-9]{64}" | head -1)

VERIFY_EXIT_CODE=$?
VERIFY_END=$(date +%s.%N)
set -e

VERIFY_TIME=$(echo "$VERIFY_END - $VERIFY_START" | bc 2>/dev/null || echo "N/A")

if [ $VERIFY_EXIT_CODE -eq 0 ] && [ -n "$TX_HASH" ]; then
    echo "[$(date +%Y-%m-%d_%H:%M:%S)] ✅ L1 verification transaction sent: $TX_HASH" | tee -a "$LOG_FILE" | tee -a "$SUMMARY_FILE"
    
    # Wait for transaction receipt and get gas used (with timeout)
    sleep 2
    RECEIPT=$(timeout 10 cast receipt "$TX_HASH" --rpc-url "$L1_RPC" 2>/dev/null || echo "")
    if [ -n "$RECEIPT" ]; then
        VERIFY_GAS=$(echo "$RECEIPT" | grep -i "gasUsed" | head -1 | awk '{print $2}' || echo "N/A")
        STATUS=$(echo "$RECEIPT" | grep -i "status" | head -1 | awk '{print $2}' || echo "")
        echo "   Gas used: $VERIFY_GAS" | tee -a "$LOG_FILE" | tee -a "$SUMMARY_FILE"
        if [ "$STATUS" = "0" ] || [ "$STATUS" = "0x0" ]; then
            echo "   ⚠️  Transaction status: FAILED" | tee -a "$LOG_FILE" | tee -a "$SUMMARY_FILE"
            VERIFY_TIME="FAILED"
        fi
    else
        echo "   ⚠️  Could not get receipt (timeout or RPC issue)" | tee -a "$LOG_FILE" | tee -a "$SUMMARY_FILE"
    fi
    
    echo "[$(date +%Y-%m-%d_%H:%M:%S)] ✅ L1 verification completed in ${VERIFY_TIME}s" | tee -a "$LOG_FILE" | tee -a "$SUMMARY_FILE"
else
    echo "[$(date +%Y-%m-%d_%H:%M:%S)] ⚠️  L1 verification failed or not configured" | tee -a "$LOG_FILE" | tee -a "$SUMMARY_FILE"
    VERIFY_TIME="FAILED"
    VERIFY_GAS="N/A"
fi

# Save to summary
{
    echo "L1_VERIFY,Time=${VERIFY_TIME}s,Gas=${VERIFY_GAS},RollupID=${ROLLUP_ID},NetworkID=${NETWORK_ID},TxHash=${TX_HASH:-N/A}"
} >> "$SUMMARY_FILE"

exit 0


