#!/bin/bash

echo "🔥 === RESOURCE STRESS SCRIPT ==="
echo "Target: 64GB RAM + 600% CPU"
echo "Start time: $(date)"
echo ""

# Kill existing stress processes
echo "1. Killing existing stress processes..."
pkill -f stress-ng 2>/dev/null || true
pkill -f "python.*memory_stress" 2>/dev/null || true
sleep 2

# CPU Stress - 600% (6 cores)
echo "2. Starting CPU stress (600%)..."
nohup stress-ng --cpu 6 --timeout 0 --metrics-brief > /tmp/cpu_stress.log 2>&1 &
CPU_PID=$!
echo "CPU stress PID: $CPU_PID"

# RAM Stress - 64GB
echo "3. Starting RAM stress (64GB)..."
cat > /tmp/memory_stress.py << 'PYEOF'
import psutil
import time
import os

# Target: 64GB = 64 * 1024 * 1024 * 1024 bytes
TARGET_MEMORY = 64 * 1024 * 1024 * 1024  # 64GB in bytes
CHUNK_SIZE = 100 * 1024 * 1024  # 100MB chunks

print(f"Target memory usage: {TARGET_MEMORY / (1024**3):.1f} GB")
print(f"Chunk size: {CHUNK_SIZE / (1024**2):.1f} MB")

# Get current memory info
memory = psutil.virtual_memory()
print(f"Current memory: {memory.used / (1024**3):.1f} GB / {memory.total / (1024**3):.1f} GB")

# Allocate memory in chunks
allocated_memory = []
current_usage = 0

try:
    while current_usage < TARGET_MEMORY:
        try:
            # Allocate chunk
            chunk = bytearray(CHUNK_SIZE)
            allocated_memory.append(chunk)
            current_usage += CHUNK_SIZE
            
            # Check current memory usage
            memory = psutil.virtual_memory()
            current_gb = memory.used / (1024**3)
            target_gb = TARGET_MEMORY / (1024**3)
            
            print(f"Allocated: {current_gb:.1f} GB / {target_gb:.1f} GB ({memory.percent:.1f}%)")
            
            # Stop if we're close to target or system is under pressure
            if memory.percent > 95 or current_gb >= target_gb * 0.95:
                print(f"Reached target or system limit at {current_gb:.1f} GB")
                break
                
        except MemoryError:
            print(f"Memory allocation failed at {current_usage / (1024**3):.1f} GB")
            break
            
        time.sleep(0.1)  # Small delay to prevent overwhelming system
    
    print(f"Final memory usage: {psutil.virtual_memory().used / (1024**3):.1f} GB")
    print("Memory stress running... Press Ctrl+C to stop")
    
    # Keep memory allocated
    while True:
        time.sleep(10)
        memory = psutil.virtual_memory()
        print(f"Memory status: {memory.used / (1024**3):.1f} GB ({memory.percent:.1f}%)")
        
except KeyboardInterrupt:
    print("\nStopping memory stress...")
    allocated_memory.clear()
    print("Memory stress stopped")

except Exception as e:
    print(f"Error: {e}")
    allocated_memory.clear()

PYEOF

nohup python3 /tmp/memory_stress.py > /tmp/ram_stress.log 2>&1 &
RAM_PID=$!
echo "RAM stress PID: $RAM_PID"

# Save PIDs for cleanup
echo "$CPU_PID" > /tmp/cpu_stress.pid
echo "$RAM_PID" > /tmp/ram_stress.pid

echo ""
echo "4. Resource stress started!"
echo "CPU PID: $CPU_PID (600%)"
echo "RAM PID: $RAM_PID (64GB target)"
echo ""
echo "5. Monitoring resource usage..."
sleep 5

# Show current resource usage
echo "=== CURRENT RESOURCE USAGE ==="
echo "CPU Usage:"
top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//'
echo ""
echo "Memory Usage:"
free -h
echo ""
echo "=== STRESS PROCESSES ==="
ps aux | grep -E "(stress-ng|python.*memory)" | grep -v grep
echo ""
echo "✅ Resource stress is running!"
echo "Logs: /tmp/cpu_stress.log, /tmp/ram_stress.log"
echo "PIDs: /tmp/cpu_stress.pid, /tmp/ram_stress.pid"
