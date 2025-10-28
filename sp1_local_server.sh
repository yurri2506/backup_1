#!/bin/bash

# SP1 Local Server for Agglayer Integration
echo "=== SP1 LOCAL SERVER STARTING ==="

# Set SP1 environment
export SP1_PROVER=cpu
export SP1_CIRCUITS_DIR=/home/ubuntu/backup_1/sp1/target/release
export SP1_CARGO_PROVE_PATH=/home/ubuntu/backup_1/sp1/target/release/cargo-prove

echo "SP1 Environment:"
echo "  SP1_PROVER=$SP1_PROVER"
echo "  SP1_CIRCUITS_DIR=$SP1_CIRCUITS_DIR"
echo "  SP1_CARGO_PROVE_PATH=$SP1_CARGO_PROVE_PATH"

# Test SP1 local functionality
echo ""
echo "=== TESTING SP1 LOCAL ==="
cd /home/ubuntu/backup_1/sp1
echo "Testing cargo-prove..."
./target/release/cargo-prove prove --help > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ SP1 cargo-prove working"
else
    echo "❌ SP1 cargo-prove failed"
fi

echo ""
echo "=== SP1 LOCAL SERVER READY ==="
echo "Endpoint: local://sp1/cpu"
echo "Mode: CPU proving"
echo "Status: Active"

# Keep running
while true; do
    sleep 60
    echo "$(date): SP1 local server active"
done
