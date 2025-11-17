#!/usr/bin/env bash

################################################################################
# WAIT AND RUN BENCHMARK SCRIPT
# 
# Đợi test_n100 hoàn thành, sau đó chạy run_v5_benchmark.sh
# 
# Usage:
#   ./wait_and_run_benchmark.sh
################################################################################

set -e

echo "═══════════════════════════════════════════════════════════════"
echo "⏳ ĐỢI TEST N=100 HOÀN THÀNH"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "📊 Kiểm tra test_n100..."

# Kiểm tra xem test_n100 có đang chạy không
while ps aux | grep "ppgen_sabv_lmtr5.*test_n100" | grep -v grep > /dev/null; do
    # Process đang chạy
    PID=$(ps aux | grep "ppgen_sabv_lmtr5.*test_n100" | grep -v grep | awk '{print $2}' | head -1)
    CPU=$(ps aux | grep "ppgen_sabv_lmtr5.*test_n100" | grep -v grep | awk '{print $3}' | head -1)
    MEM=$(ps aux | grep "ppgen_sabv_lmtr5.*test_n100" | grep -v grep | awk '{print $4}' | head -1)
    ETIME=$(ps aux | grep "ppgen_sabv_lmtr5.*test_n100" | grep -v grep | awk '{print $10}' | head -1)
    
    echo "  ⏳ Process đang chạy:"
    echo "    • PID: $PID"
    echo "    • CPU: ${CPU}%"
    echo "    • MEM: ${MEM}%"
    echo "    • ETIME: $ETIME"
    echo "    • Thời gian: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    
    # Đợi 5 phút rồi kiểm tra lại
    echo "  ⏳ Đợi 5 phút rồi kiểm tra lại..."
    sleep 300
done

# Process đã xong
echo "✅ TEST N=100 ĐÃ HOÀN THÀNH"
echo ""
echo "📊 Kiểm tra kết quả..."
if [ -f logs/test_n100_tmux.log ]; then
    echo "  • Log file: logs/test_n100_tmux.log"
    if grep -q "Command terminated by signal 9" logs/test_n100_tmux.log; then
        echo "  • ⚠️  Process bị KILL (signal 9) - có thể do OOM"
    else
        echo "  • ✅ Process hoàn thành bình thường"
    fi
    if grep -q "Maximum resident set size" logs/test_n100_tmux.log; then
        MAX_RAM=$(grep "Maximum resident set size" logs/test_n100_tmux.log | tail -1 | awk '{print $6}' | sed 's/k$//' 2>/dev/null || echo "0")
        if [ "$MAX_RAM" != "0" ] && [ "$MAX_RAM" != "" ]; then
            MAX_RAM_GB=$(echo "scale=2; $MAX_RAM / 1024 / 1024" | bc 2>/dev/null || echo "0")
            echo "  • 💾 Maximum RAM: ${MAX_RAM_GB} GB"
        fi
    fi
    if grep -q "Percent of CPU" logs/test_n100_tmux.log; then
        CPU_PERCENT=$(grep "Percent of CPU" logs/test_n100_tmux.log | tail -1 | awk '{print $4}' | sed 's/%$//' 2>/dev/null || echo "0")
        if [ "$CPU_PERCENT" != "0" ] && [ "$CPU_PERCENT" != "" ]; then
            echo "  • ⚡ CPU Usage: ${CPU_PERCENT}%"
        fi
    fi
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "🚀 CHẠY BENCHMARK MỚI: N=200, 500, 700"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "📊 Script: run_v5_benchmark.sh"
echo "  • N values: 200, 500, 700"
echo "  • Số lần lặp: 3"
echo "  • Thứ tự chạy: 200 → 500 → 700, lặp lại 3 lần"
echo ""
echo "💡 Chạy trong tmux:"
echo "  tmux new-session -s v5_benchmark 'bash run_v5_benchmark.sh'"
echo ""
echo "🚀 Bắt đầu chạy benchmark mới..."
echo ""

# Chạy benchmark mới
bash run_v5_benchmark.sh


