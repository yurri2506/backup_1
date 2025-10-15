#!/bin/bash

# SP1 PERFORMANCE EXPERIMENT WITH SABV/LMTR
set -e

echo "=== SP1 PERFORMANCE EXPERIMENT ==="
echo "Started at: $(date)"
echo "Target: CPU 600%, RAM 32GB"
echo ""

# Configuration
EXIT_COUNTS=(1 5 10)
LOG_FILE="sp1_experiment_results.log"
TEST_DIR="sp1_test_results"

# Function to create CPU stress (600% = 6 cores)
create_cpu_stress() {
    echo "🔥 Creating CPU stress for 600% usage..."
    for i in {1..6}; do
        (
            while true; do
                bc -l <<< "scale=1000; 4*a(1)" > /dev/null 2>&1
            done
        ) &
        echo $! >> /tmp/cpu_stress_pids
    done
}

# Function to create RAM stress (32GB)
create_ram_stress() {
    echo "🧠 Creating RAM stress for 32GB usage..."
    
    python3 << PYTHON_EOF &
import sys
import time

target_mb = 32000  # 32GB
chunk_size = 100 * 1024 * 1024  # 100MB chunks
allocated = []

try:
    while True:
        chunk = bytearray(chunk_size)
        allocated.append(chunk)
        current_mb = len(allocated) * 100
        
        if current_mb >= target_mb:
            break
    
    print(f"RAM stress active: {current_mb}MB allocated")
    
    while True:
        time.sleep(1)
        
except KeyboardInterrupt:
    print("RAM stress stopped")
    sys.exit(0)
PYTHON_EOF
    
    echo $! > /tmp/ram_stress_pid
}

# Function to run baseline test
run_baseline_test() {
    local exits=$1
    echo "🚀 Running BASELINE test for $exits exits..."
    echo "=== BASELINE TEST - $exits EXITS ===" | tee -a $LOG_FILE
    echo "Start time: $(date)" | tee -a $LOG_FILE
    
    local start_time=$(date +%s)
    
    cargo run --release -p pessimistic-proof-test-suite --bin ppgen -- \
        --n-exits $exits \
        --proof-dir $TEST_DIR/baseline_${exits}exits 2>&1 | tee -a $LOG_FILE
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo "End time: $(date)" | tee -a $LOG_FILE
    echo "Duration: ${duration}s ($(($duration / 60))m $(($duration % 60))s)" | tee -a $LOG_FILE
    echo "✅ BASELINE $exits exits completed" | tee -a $LOG_FILE
    echo "" | tee -a $LOG_FILE
}

# Function to run SABV/LMTR test
run_sabv_lmtr_test() {
    local exits=$1
    echo "🚀 Running SABV/LMTR test for $exits exits..."
    echo "=== SABV/LMTR TEST - $exits EXITS ===" | tee -a $LOG_FILE
    echo "Start time: $(date)" | tee -a $LOG_FILE
    
    local start_time=$(date +%s)
    
    cargo run --release -p pessimistic-proof-test-suite --bin ppgen_sabv_lmtr -- \
        --n-exits $exits \
        --validator-nodes 5 \
        --proof-dir $TEST_DIR/sabv_lmtr_${exits}exits 2>&1 | tee -a $LOG_FILE
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo "End time: $(date)" | tee -a $LOG_FILE
    echo "Duration: ${duration}s ($(($duration / 60))m $(($duration % 60))s)" | tee -a $LOG_FILE
    echo "✅ SABV/LMTR $exits exits completed" | tee -a $LOG_FILE
    echo "" | tee -a $LOG_FILE
}

# Cleanup function
cleanup() {
    echo "🧹 Cleaning up..."
    if [ -f /tmp/cpu_stress_pids ]; then
        while read pid; do
            if [ ! -z "$pid" ]; then
                kill $pid 2>/dev/null
            fi
        done < /tmp/cpu_stress_pids
        rm -f /tmp/cpu_stress_pids
    fi
    
    if [ -f /tmp/ram_stress_pid ]; then
        pid=$(cat /tmp/ram_stress_pid)
        if [ ! -z "$pid" ]; then
            kill $pid 2>/dev/null
        fi
        rm -f /tmp/ram_stress_pid
    fi
}

trap cleanup SIGINT SIGTERM

echo "1. 🎯 Starting resource stress..."
create_cpu_stress
sleep 2
create_ram_stress
sleep 5

echo "2. ✅ Resource stress started"
echo "Current resources:"
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
ram_usage=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
echo "CPU: ${cpu_usage}%, RAM: ${ram_usage}%"
echo ""

# Run tests sequentially for each exit count
for exits in "${EXIT_COUNTS[@]}"; do
    echo "🔥 === TESTING $exits EXITS ==="
    echo ""
    
    echo "Step 1: Running BASELINE test for $exits exits"
    run_baseline_test $exits
    
    echo "Step 2: Running SABV/LMTR test for $exits exits"
    run_sabv_lmtr_test $exits
    
    echo "🎉 Completed tests for $exits exits"
    echo "================================"
    echo ""
done

echo "3. 🏁 All SP1 experiments completed!"
echo ""
echo "=== FINAL RESULTS ==="
echo "Log file: $LOG_FILE"
echo "Test results: $TEST_DIR/"

cleanup
echo "Experiment completed at: $(date)"
