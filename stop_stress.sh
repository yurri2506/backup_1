#!/bin/bash

echo "🛑 === STOPPING RESOURCE STRESS ==="
echo "Stop time: $(date)"
echo ""

# Stop CPU stress
if [ -f /tmp/cpu_stress.pid ]; then
    CPU_PID=$(cat /tmp/cpu_stress.pid)
    echo "Stopping CPU stress (PID: $CPU_PID)..."
    kill $CPU_PID 2>/dev/null || true
    rm -f /tmp/cpu_stress.pid
fi

# Stop RAM stress
if [ -f /tmp/ram_stress.pid ]; then
    RAM_PID=$(cat /tmp/ram_stress.pid)
    echo "Stopping RAM stress (PID: $RAM_PID)..."
    kill $RAM_PID 2>/dev/null || true
    rm -f /tmp/ram_stress.pid
fi

# Kill any remaining stress processes
echo "Killing any remaining stress processes..."
pkill -f stress-ng 2>/dev/null || true
pkill -f "python.*memory_stress" 2>/dev/null || true

echo ""
echo "✅ Resource stress stopped!"
echo ""
echo "=== CURRENT RESOURCE USAGE ==="
echo "CPU Usage:"
top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//'
echo ""
echo "Memory Usage:"
free -h
