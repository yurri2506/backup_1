#!/bin/bash

# V3 SABV/LMTR with SP1 Proving - REAL Algorithm Implementation (NOT Simulator)
# Based on Algorithm 1 and Algorithm 2 from the paper
# Features: Real Shamir secret sharing, Real cryptographic verification, Real Merkle trees

echo "🚀 Starting V3 SABV/LMTR with REAL SP1 Proving - NOT A SIMULATOR"
echo "📅 Started at: $(date)"
echo "🎯 V3 implements Algorithm 1 (SABV) and Algorithm 2 (LMTR) from the paper"
echo "🔐 REAL FEATURES:"
echo "   ✅ Real Shamir Secret Sharing (k,m)-threshold scheme"
echo "   ✅ Real Cryptographic Verification (4-layer multi-check)"
echo "   ✅ Real Merkle Tree Construction (CC-MBMT)"
echo "   ✅ Real Data Sharding and Distribution"

# Exit counts to test (N values)
EXIT_COUNTS=(1 5 10)
VALIDATOR_NODES=5

# Create logs directory
mkdir -p logs/sabv3_lmtr3

# Create tmux session
tmux new-session -d -s sabv3_lmtr3_ppgen

# Pane 1: V3 SABV/LMTR with SP1 Proving
tmux send-keys -t sabv3_lmtr3_ppgen "echo '🔍 V3 SABV/LMTR with REAL SP1 Proving - NOT A SIMULATOR'" C-m
tmux send-keys -t sabv3_lmtr3_ppgen "echo '📊 Testing with N = ${EXIT_COUNTS[*]} and ${VALIDATOR_NODES} validators'" C-m
tmux send-keys -t sabv3_lmtr3_ppgen "cd /home/ubuntu/thanhhuyen/agglayer" C-m

# Run V3 with SP1 proving for each N value
for n in "${EXIT_COUNTS[@]}"; do
    echo "🔄 Running REAL V3 with N=$n"
    tmux send-keys -t sabv3_lmtr3_ppgen "echo '📦 Processing N=$n with REAL algorithms (not simulator)...'" C-m
    tmux send-keys -t sabv3_lmtr3_ppgen "cargo run --release --package pessimistic-proof-test-suite --bin ppgen_sabv_lmtr3 -- --n-exits $n --validator-nodes $VALIDATOR_NODES 2>&1 | tee logs/sabv3_lmtr3/proof_ppgen_sabv_lmtr3_${n}.log" C-m
    tmux send-keys -t sabv3_lmtr3_ppgen "echo '✅ Completed REAL V3 for N=$n'" C-m
done

tmux send-keys -t sabv3_lmtr3_ppgen "echo '🎉 V3 SABV/LMTR REAL SP1 Proving completed at $(date)'" C-m
tmux send-keys -t sabv3_lmtr3_ppgen "echo '✅ V3 uses REAL algorithms - NOT a simulator'" C-m
tmux send-keys -t sabv3_lmtr3_ppgen "echo '📊 Real Shamir Secret Sharing + Real Cryptographic Verification + Real SP1'" C-m

echo "✅ V3 REAL Algorithm tmux session created: sabv3_lmtr3_ppgen"
echo "🔐 V3 REAL features:"
echo "   - Real (k,m)-threshold Shamir secret sharing"
echo "   - Real 4-layer cryptographic verification"
echo "   - Real CC-MBMT Merkle tree construction"
echo "   - Real deterministic shard distribution"
echo "📅 V3 REAL session started at: $(date)"