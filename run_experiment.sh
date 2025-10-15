#!/bin/bash

echo "🚀 === SABV/LMTR vs BASELINE PERFORMANCE EXPERIMENT ==="
echo "Target: 64GB RAM + 600% CPU"
echo "Start time: $(date)"
echo ""

# Function to stress CPU (600%)
stress_cpu() {
    echo "🔥 Starting CPU stress (600%)..."
    nohup stress-ng --cpu 6 --timeout 0 > /tmp/cpu_stress.log 2>&1 &
    CPU_PID=$!
    echo "CPU stress PID: $CPU_PID"
}

# Function to stress RAM (64GB)
stress_ram() {
    echo "💾 Starting RAM stress (64GB)..."
    cat > /tmp/memory_stress.py << 'PYEOF'
import psutil
import time
import os

TARGET_MEMORY = 64 * 1024 * 1024 * 1024  # 64GB
CHUNK_SIZE = 100 * 1024 * 1024  # 100MB chunks

print(f"Target memory usage: {TARGET_MEMORY / (1024**3):.1f} GB")

allocated_memory = []
current_usage = 0

try:
    while current_usage < TARGET_MEMORY:
        try:
            chunk = bytearray(CHUNK_SIZE)
            allocated_memory.append(chunk)
            current_usage += CHUNK_SIZE
            
            memory = psutil.virtual_memory()
            current_gb = memory.used / (1024**3)
            target_gb = TARGET_MEMORY / (1024**3)
            
            print(f"Allocated: {current_gb:.1f} GB / {target_gb:.1f} GB ({memory.percent:.1f}%)")
            
            if memory.percent > 95 or current_gb >= target_gb * 0.95:
                print(f"Reached target at {current_gb:.1f} GB")
                break
                
        except MemoryError:
            print(f"Memory allocation failed at {current_usage / (1024**3):.1f} GB")
            break
            
        time.sleep(0.1)
    
    print("Memory stress running...")
    while True:
        time.sleep(10)
        
except KeyboardInterrupt:
    print("\nStopping memory stress...")
    allocated_memory.clear()

except Exception as e:
    print(f"Error: {e}")
    allocated_memory.clear()
PYEOF

    nohup python3 /tmp/memory_stress.py > /tmp/ram_stress.log 2>&1 &
    RAM_PID=$!
    echo "RAM stress PID: $RAM_PID"
}

# Function to stop stress
stop_stress() {
    echo "🛑 Stopping resource stress..."
    pkill -f stress-ng 2>/dev/null || true
    pkill -f "python.*memory_stress" 2>/dev/null || true
    sleep 2
}

# Function to run test
run_test() {
    local test_type=$1
    local exits=$2
    local session_name="test_${test_type}_${exits}exits"
    
    echo ""
    echo "🧪 === RUNNING $test_type TEST - $exits EXITS ==="
    echo "Session: $session_name"
    echo "Start: $(date)"
    
    # Kill existing session
    tmux kill-session -t $session_name 2>/dev/null || true
    
    # Create new session and run test
    if [ "$test_type" = "BASELINE" ]; then
        tmux new-session -d -s $session_name -c /home/ubuntu/thanhhuyen/agglayer "
            echo '🚀 BASELINE TEST - $exits exits' &&
            echo 'Start time: \$(date)' &&
            cargo run --release --bin ppgen -- --n-exits $exits --proof-dir experiment_results/baseline_${exits}exits &&
            echo '✅ BASELINE test completed' &&
            echo 'End time: \$(date)' &&
            sleep 5
        "
    else
        tmux new-session -d -s $session_name -c /home/ubuntu/thanhhuyen/agglayer "
            echo '🚀 SABV/LMTR TEST - $exits exits' &&
            echo 'Start time: \$(date)' &&
            cargo run --release --bin ppgen_sabv_lmtr -- --n-exits $exits --validator-nodes 5 --proof-dir experiment_results/sabv_lmtr_${exits}exits &&
            echo '✅ SABV/LMTR test completed' &&
            echo 'End time: \$(date)' &&
            sleep 5
        "
    fi
    
    echo "Test started in tmux session: $session_name"
}

# Function to wait for test completion
wait_for_test() {
    local session_name=$1
    local max_wait=1800  # 30 minutes max
    
    echo "⏳ Waiting for test completion..."
    local elapsed=0
    
    while [ $elapsed -lt $max_wait ]; do
        if ! tmux has-session -t $session_name 2>/dev/null; then
            echo "✅ Test completed!"
            return 0
        fi
        
        sleep 10
        elapsed=$((elapsed + 10))
        echo "  Elapsed: ${elapsed}s / ${max_wait}s"
    done
    
    echo "⚠️ Test timeout after ${max_wait}s"
    tmux kill-session -t $session_name 2>/dev/null || true
    return 1
}

# Function to collect results
collect_results() {
    local test_type=$1
    local exits=$2
    local session_name="test_${test_type}_${exits}exits"
    
    echo "📊 Collecting results for $test_type - $exits exits..."
    
    # Get tmux logs
    if tmux has-session -t $session_name 2>/dev/null; then
        tmux capture-pane -t $session_name -p > /tmp/${session_name}_log.txt 2>/dev/null
    fi
    
    # Check proof files
    local proof_dir="/home/ubuntu/thanhhuyen/agglayer/experiment_results"
    if [ -d "$proof_dir" ]; then
        echo "Proof directory contents:"
        ls -la "$proof_dir/"
    fi
}

# Main experiment function
run_experiment() {
    local exits_list=(1 5 10 20 50)
    
    echo "🎯 Starting sequential experiment with exits: ${exits_list[*]}"
    echo ""
    
    # Start resource stress
    stress_cpu
    stress_ram
    
    # Wait for stress to stabilize
    echo "⏳ Waiting for resource stress to stabilize..."
    sleep 30
    
    # Show current resource usage
    echo ""
    echo "=== CURRENT RESOURCE USAGE ==="
    echo "CPU Usage:"
    top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//'
    echo ""
    echo "Memory Usage:"
    free -h
    echo ""
    
    # Create results directory
    mkdir -p /home/ubuntu/thanhhuyen/agglayer/experiment_results
    
    # Run tests sequentially
    for exits in "${exits_list[@]}"; do
        echo ""
        echo "🔥 === TESTING $exits EXITS ==="
        
        # Run BASELINE test
        echo "Step 1: Running BASELINE test for $exits exits"
        run_test "BASELINE" $exits
        wait_for_test "test_BASELINE_${exits}exits"
        collect_results "BASELINE" $exits
        
        # Run SABV/LMTR test
        echo "Step 2: Running SABV/LMTR test for $exits exits"
        run_test "SABV_LMTR" $exits
        wait_for_test "test_SABV_LMTR_${exits}exits"
        collect_results "SABV_LMTR" $exits
        
        echo "✅ Completed testing $exits exits"
    done
    
    # Stop resource stress
    stop_stress
    
    echo ""
    echo "🎉 === EXPERIMENT COMPLETED ==="
    echo "End time: $(date)"
    echo ""
    echo "📊 === FINAL RESULTS SUMMARY ==="
    
    # Show all results
    if [ -d "/home/ubuntu/thanhhuyen/agglayer/experiment_results" ]; then
        echo "Proof files generated:"
        find /home/ubuntu/thanhhuyen/agglayer/experiment_results -name "*.json" -o -name "*.txt" | sort
        echo ""
        echo "Directory sizes:"
        du -sh /home/ubuntu/thanhhuyen/agglayer/experiment_results/*
    fi
    
    echo ""
    echo "📝 Logs saved in:"
    echo "- /tmp/cpu_stress.log"
    echo "- /tmp/ram_stress.log"
    echo "- /tmp/test_*_log.txt"
    echo ""
    echo "✅ Experiment completed successfully!"
}

# Check if we're in the right directory
if [ ! -d "/home/ubuntu/thanhhuyen/agglayer" ]; then
    echo "❌ Error: agglayer directory not found!"
    echo "Please run this script from /home/ubuntu/thanhhuyen/"
    exit 1
fi

# Check if cargo is available
if ! command -v cargo &> /dev/null; then
    echo "❌ Error: cargo not found!"
    echo "Please install Rust first"
    exit 1
fi

# Start the experiment
run_experiment
