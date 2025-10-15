#!/bin/bash

echo "🔥 Starting CPU stress (600%) without stress-ng..."

# Function to stress CPU
stress_cpu() {
    local core_id=$1
    echo "Starting CPU stress on core $core_id..."
    
    # Infinite loop to consume CPU
    while true; do
        # CPU intensive operations
        for i in {1..1000000}; do
            # Mathematical operations to consume CPU
            result=$(echo "scale=10; $i * 3.14159 / 2.71828" | bc -l 2>/dev/null || echo $i)
        done
        
        # Brief pause to prevent system freeze
        sleep 0.001
    done
}

# Start 6 CPU stress processes (600% total)
echo "Starting 6 CPU stress processes..."
for i in {1..6}; do
    stress_cpu $i &
    echo "CPU stress process $i started (PID: $!)"
done

echo "✅ CPU stress started! 6 processes running."
echo "Use 'pkill -f cpu_stress_alternative' to stop."
