#!/usr/bin/env bash

################################################################################
# S-MAPLE BENCHMARK SCRIPT - Run N=1, 10, 100, 200, 500, 700 (lặp lại 5 lần)
# 
# Chạy tuần tự: N=1 → N=10 → N=100 → N=200 → N=500 → N=700, lặp lại 5 lần
# Cấu hình: RAYON_NUM_THREADS=16, SHARD_BATCH_SIZE=1, TRACE_GEN_WORKERS=1
# (Tối đa CPU - 16 threads)
# 
# Usage:
#   ./run_s_maple_benchmark.sh
#   hoặc trong tmux: tmux new-session -s s_maple_benchmark 'bash run_s_maple_benchmark.sh'
################################################################################

# Don't exit on error - continue with next run even if one fails
set +e

# Configuration
BIN_DIR="/home/ubuntu/thanhhuyen/agglayer"
LOG_DIR="/home/ubuntu/thanhhuyen/logs/s_maple"
PROOF_DIR="/home/ubuntu/thanhhuyen/proofs/s_maple"

# N values to test (chạy tuần tự: 1 → 10 → 100 → 200 → 500 → 700, lặp lại 5 lần)
N_VALUES=(1 10 100 200 500 700)
TARGET_RUNS=5
VALIDATORS=5
TMUX_SESSION="s_maple_benchmark"

echo "═══════════════════════════════════════════════════════════════"
echo "🚀 S-MAPLE BENCHMARK: N=1, 10, 100, 200, 500, 700 (lặp lại 5 lần)"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "📋 Configuration:"
echo "  • N values: ${N_VALUES[@]} (chạy tuần tự)"
echo "  • Số lần lặp: $TARGET_RUNS (1→10→100→200→500→700, lặp lại $TARGET_RUNS lần)"
echo "  • Tổng cộng: $((${#N_VALUES[@]} * TARGET_RUNS)) runs (6 N × 5 runs = 30 runs)"
echo "  • Validator nodes: $VALIDATORS"
echo "  • Proof dir: $PROOF_DIR"
echo "  • Log dir: $LOG_DIR"
echo "  • TMUX session: $TMUX_SESSION"
echo ""
echo "⚙️  SP1 Configuration:"
echo "  • RAYON_NUM_THREADS: 16 (N<=10) hoặc 8 (N>=100) - điều chỉnh theo N để tránh OOM"
echo "  • SHARD_BATCH_SIZE: 1 (giống baseline, safe)"
echo "  • TRACE_GEN_WORKERS: 1 (giống baseline, safe)"
echo "  • Expected memory: ~16-24GB (N<=10) hoặc ~20-25GB (N>=100) - tránh OOM"
echo "  • Expected CPU: ~1200-1400% (N<=10, 16 threads) hoặc ~1200% (N>=100, 8 threads)"
echo ""

mkdir -p "$LOG_DIR" "$PROOF_DIR"
cd "$BIN_DIR"

# Function to monitor CPU/RAM
monitor_process() {
    local n=$1
    local run_num=$2
    local log_file=$3
    local proof_dir=$4
    
    # Đợi một chút để process bắt đầu
    sleep 3
    
    while true; do
        sleep 5
        
        # Tìm process PID - tìm bằng proof-dir path (chính xác nhất)
        local pid=$(ps aux | grep "ppgen_sabv_lmtr5" | grep "$proof_dir" | grep -v grep | awk '{print $2}' | head -1)
        
        if [ -z "$pid" ]; then
            # Fallback 1: tìm bằng n${n}_run${run_num} trong command
            pid=$(ps aux | grep "ppgen_sabv_lmtr5" | grep "n${n}_run${run_num}" | grep -v grep | awk '{print $2}' | head -1)
        fi
        
        if [ -z "$pid" ]; then
            # Fallback 2: tìm bằng --n-exits $n và proof dir s_maple
            pid=$(ps aux | grep "ppgen_sabv_lmtr5" | grep "--n-exits $n" | grep "/proofs/s_maple" | grep -v grep | awk '{print $2}' | head -1)
        fi
        
        if [ -n "$pid" ]; then
            # Lấy thông tin CPU/RAM - chỉ lấy process chính (không phải time command)
            local cpu_ram=$(ps -p "$pid" -o %cpu,rss,etime,cmd --no-headers 2>/dev/null)
            if [ -n "$cpu_ram" ] && echo "$cpu_ram" | grep -q "ppgen_sabv_lmtr5"; then
                local cpu=$(echo "$cpu_ram" | awk '{print $1}')
                local ram_kb=$(echo "$cpu_ram" | awk '{print $2}')
                local elapsed=$(echo "$cpu_ram" | awk '{print $3}')
                
                # Chỉ lấy process có CPU > 0 hoặc RAM > 0 (process thực sự đang chạy)
                if [ "$(echo "$cpu" | awk '{print int($1)}')" -gt 0 ] || [ "$ram_kb" -gt 1000000 ]; then
                    local ram_gb=$(echo "scale=2; $ram_kb / 1024 / 1024" | bc 2>/dev/null || echo "0")
                    
                    # In ra log file
                    echo "  📊 [$(date '+%H:%M:%S')] CPU: ${cpu}% | RAM: ${ram_gb} GB | Elapsed: ${elapsed}" >> "$log_file"
                fi
            fi
        else
            # Process không tìm thấy, kiểm tra xem đã xong chưa
            sleep 3
            # Kiểm tra xem có process nào đang chạy không
            if ! ps aux | grep "ppgen_sabv_lmtr5" | grep "/proofs/s_maple" | grep -v grep > /dev/null; then
                # Không còn process nào, có thể đã xong
                break
            fi
        fi
    done
}

# Script sẽ chạy trực tiếp (không cần tmux session check)
# Để chạy trong tmux, dùng: tmux new-session -s s_maple_benchmark 'bash run_s_maple_benchmark.sh'
echo "🚀 Starting benchmark..."
echo "💡 Script này chạy trực tiếp (không tự động tạo tmux)"
echo "💡 TMUX session sẽ được GIỮ LẠI nếu chạy trong tmux"
echo ""

# Run: 1→10→100→200→500→700, lặp lại 5 lần
for run in $(seq 1 $TARGET_RUNS); do
    echo "════════════════════════════════════════════════════════════════════════════"
    echo "🔄 LẦN LẶP $run/$TARGET_RUNS: N=1 → N=10 → N=100 → N=200 → N=500 → N=700"
    echo "════════════════════════════════════════════════════════════════════════════"
    echo ""
    
    # Run each N value in sequence (1 → 10 → 100 → 200 → 500 → 700)
    for N in "${N_VALUES[@]}"; do
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📊 Lần lặp $run/$TARGET_RUNS - Running N=$N at $(date '+%Y-%m-%d %H:%M:%S')"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        
        LOG_FILE="$LOG_DIR/s_maple_n${N}_run${run}_$(date +%Y%m%d_%H%M%S).log"
        PROOF_SUBDIR="$PROOF_DIR/n${N}_run${run}"
        
        mkdir -p "$PROOF_SUBDIR"
        START_TIME=$(date +%s)
        
        # Set SP1 config - ĐIỀU CHỈNH THEO N ĐỂ TRÁNH OOM
        export RUST_LOG=sp1_sdk=info,sp1=info
        export SP1_PROVER=cpu
        export SP1_CARGO_PROVE_PATH=/home/ubuntu/.sp1/bin/cargo-prove
        export SHARD_SIZE=2097152

        # CẤU HÌNH THEO N ĐỂ TRÁNH OOM KILL
        # - N<=10: RAYON_NUM_THREADS=16 (OK, memory thấp)
        # - N>=100: RAYON_NUM_THREADS=8 (optimal, giảm RAM usage)
        # - SHARD_BATCH_SIZE=1, TRACE_GEN_WORKERS=1: Giữ nguyên (safe, giống baseline)
        if [ "$N" -ge 100 ]; then
            # N>=100: Dùng 8 threads (optimal, tránh OOM)
            export RAYON_NUM_THREADS=8
            echo "   ⚙️  Config: RAYON_NUM_THREADS=8 (OPTIMAL cho N>=100, tránh OOM)"
            echo "   ⚙️  Expected CPU usage: ~1200% (~12 cores)"
            echo "   ⚙️  Expected memory: ~20-25GB (tránh OOM)"
        else
            # N<=10: Dùng 16 threads (OK, memory thấp)
            export RAYON_NUM_THREADS=16
            echo "   ⚙️  Config: RAYON_NUM_THREADS=16 (OK cho N<=10)"
            echo "   ⚙️  Expected CPU usage: ~1200-1400% (tối đa CPU với 16 threads)"
            echo "   ⚙️  Expected memory: ~16-24GB"
        fi
        
        # Giữ nguyên: SHARD_BATCH_SIZE=1, TRACE_GEN_WORKERS=1 (safe, giống baseline)
        export SHARD_BATCH_SIZE=1
        export TRACE_GEN_WORKERS=1
        echo "   ⚙️  SHARD_BATCH_SIZE=1, TRACE_GEN_WORKERS=1 (giữ nguyên, safe)"
        echo "   ⚙️  ✅ CẤU HÌNH: Điều chỉnh theo N để tránh OOM"
        echo ""
        
        echo "   📁 Log: $LOG_FILE"
        echo "   📁 Proof dir: $PROOF_SUBDIR"
        echo ""
        
        # Start monitoring in background
        monitor_process "$N" "$run" "$LOG_FILE" "$PROOF_SUBDIR" &
        MONITOR_PID=$!
        
        # Run benchmark và capture output
        /usr/bin/time -v cargo run --release -p pessimistic-proof-test-suite --bin ppgen_sabv_lmtr5 -- \
            --n-exits "$N" \
            --validator-nodes "$VALIDATORS" \
            --proof-dir "$PROOF_SUBDIR" \
            2>&1 | tee -a "$LOG_FILE"
        
        EXIT_CODE=${PIPESTATUS[0]}
        
        # Stop monitoring
        kill $MONITOR_PID 2>/dev/null || true
        wait $MONITOR_PID 2>/dev/null || true
        
        END_TIME=$(date +%s)
        DURATION=$((END_TIME - START_TIME))
        
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📊 N=$N, Run $run/$TARGET_RUNS Results"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "   Duration: ${DURATION}s ($(($DURATION / 60))m $(($DURATION % 60))s)"
        echo "   Exit code: $EXIT_CODE"
        echo ""
        
        # Extract resource usage from time command
        if grep -q "Maximum resident set size\|Percent of CPU\|Command terminated" "$LOG_FILE" 2>/dev/null; then
            echo "   📊 Resource Usage:"
            if grep -q "Command terminated by signal 9" "$LOG_FILE"; then
                echo "      ❌ Process bị KILL (signal 9) - có thể do OOM"
                echo "      💡 Xem log chi tiết: tail -50 $LOG_FILE"
            else
                echo "      ✅ Process hoàn thành bình thường"
            fi
            MAX_RAM=$(grep "Maximum resident set size" "$LOG_FILE" | tail -1 | awk '{print $6}' | sed 's/k$//' 2>/dev/null || echo "0")
            if [ "$MAX_RAM" != "0" ] && [ "$MAX_RAM" != "" ]; then
                MAX_RAM_GB=$(echo "scale=2; $MAX_RAM / 1024 / 1024" | bc 2>/dev/null || echo "0")
                echo "      💾 Maximum RAM: ${MAX_RAM_GB} GB (${MAX_RAM} KB)"
            fi
            CPU_PERCENT=$(grep "Percent of CPU" "$LOG_FILE" | tail -1 | awk '{print $4}' | sed 's/%$//' 2>/dev/null || echo "0")
            if [ "$CPU_PERCENT" != "0" ] && [ "$CPU_PERCENT" != "" ]; then
                echo "      ⚡ CPU Usage: ${CPU_PERCENT}%"
            fi
            USER_TIME=$(grep "User time" "$LOG_FILE" | tail -1 | awk '{print $4}' 2>/dev/null || echo "N/A")
            SYS_TIME=$(grep "System time" "$LOG_FILE" | tail -1 | awk '{print $4}' 2>/dev/null || echo "N/A")
            if [ "$USER_TIME" != "N/A" ] && [ "$USER_TIME" != "" ]; then
                echo "      ⏱️  User time: ${USER_TIME}"
                echo "      ⏱️  System time: ${SYS_TIME}"
            fi
        fi
        
        # Extract CPU/RAM from monitoring logs
        if grep -q "📊.*CPU:" "$LOG_FILE" 2>/dev/null; then
            echo ""
            echo "   📊 CPU/RAM Monitoring (real-time):"
            CPU_AVG=$(grep "📊.*CPU:" "$LOG_FILE" | sed -n 's/.*CPU: \([0-9.]*\)%.*/\1/p' | awk '{sum+=$1; count++} END {if(count>0) printf "%.1f", sum/count; else print "0"}')
            CPU_MAX=$(grep "📊.*CPU:" "$LOG_FILE" | sed -n 's/.*CPU: \([0-9.]*\)%.*/\1/p' | awk '{if($1>max || max=="") max=$1} END {printf "%.1f", max+0}')
            CPU_MIN=$(grep "📊.*CPU:" "$LOG_FILE" | sed -n 's/.*CPU: \([0-9.]*\)%.*/\1/p' | awk 'BEGIN{min=999999} {if($1<min) min=$1} END {if(min==999999) print "0"; else printf "%.1f", min}')
            RAM_AVG=$(grep "📊.*RAM:" "$LOG_FILE" | sed -n 's/.*RAM: \([0-9.]*\) GB.*/\1/p' | awk '{sum+=$1; count++} END {if(count>0) printf "%.2f", sum/count; else print "0"}')
            RAM_MAX=$(grep "📊.*RAM:" "$LOG_FILE" | sed -n 's/.*RAM: \([0-9.]*\) GB.*/\1/p' | awk '{if($1>max || max=="") max=$1} END {printf "%.2f", max+0}')
            RAM_MIN=$(grep "📊.*RAM:" "$LOG_FILE" | sed -n 's/.*RAM: \([0-9.]*\) GB.*/\1/p' | awk 'BEGIN{min=999999} {if($1<min) min=$1} END {if(min==999999) print "0"; else printf "%.2f", min}')
            MONITOR_COUNT=$(grep -c "📊.*CPU:" "$LOG_FILE" 2>/dev/null || echo "0")
            
            if [ "$MONITOR_COUNT" -gt 0 ] && [ "$CPU_AVG" != "0" ]; then
                echo "      ⚡ CPU Average: ${CPU_AVG}%"
                echo "      ⚡ CPU Peak: ${CPU_MAX}%"
                echo "      ⚡ CPU Min: ${CPU_MIN}%"
                echo "      💾 RAM Average: ${RAM_AVG} GB"
                echo "      💾 RAM Peak: ${RAM_MAX} GB"
                echo "      💾 RAM Min: ${RAM_MIN} GB"
                echo "      📈 Monitoring samples: ${MONITOR_COUNT}"
            fi
        fi
        
        # Check result
        if [ $EXIT_CODE -eq 0 ]; then
            echo "   ✅ N=$N, Run $run: SUCCESS"
            
            # Check verification
            if grep -q "SABV5: Verification PASSED" "$LOG_FILE"; then
                echo "   ✅ Verification: PASSED"
            fi
            
            # Check proof file
            if [ -f "$PROOF_SUBDIR/s_maple_proof_n${N}.json" ] || [ -f "$PROOF_SUBDIR/proof.bin" ]; then
                if [ -f "$PROOF_SUBDIR/s_maple_proof_n${N}.json" ]; then
                    PROOF_SIZE=$(ls -lh "$PROOF_SUBDIR/s_maple_proof_n${N}.json" 2>/dev/null | awk '{print $5}' || echo "N/A")
                    echo "   ✅ Proof file: s_maple_proof_n${N}.json ($PROOF_SIZE)"
                fi
                if [ -f "$PROOF_SUBDIR/proof.bin" ]; then
                    PROOF_SIZE=$(ls -lh "$PROOF_SUBDIR/proof.bin" 2>/dev/null | awk '{print $5}' || echo "N/A")
                    echo "   ✅ Proof file: proof.bin ($PROOF_SIZE)"
                fi
            else
                echo "   ⚠️  Proof file: KHÔNG CÓ"
            fi
        else
            echo "   ❌ N=$N, Run $run: FAILED (exit code: $EXIT_CODE)"
            echo "   ⚠️  Check log: $LOG_FILE"
            
            # Check if killed
            if grep -q "signal 9\|killed\|OOM" "$LOG_FILE" 2>/dev/null; then
                echo "   ⚠️  Process có thể bị kill bởi OOM"
            fi
        fi
        
        echo ""
        echo "   📁 Log: $LOG_FILE"
        echo "   📁 Proof: $PROOF_SUBDIR"
        echo ""
        
        # Small delay before next N
        sleep 2
    done
    
    echo "✅ Completed iteration $run/$TARGET_RUNS (N=1 → N=10 → N=100 → N=200 → N=500 → N=700)"
    echo ""
done

echo "════════════════════════════════════════════════════════════════════════════"
echo "🎉 ALL BENCHMARKS COMPLETED"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""
echo "📊 Summary:"
echo "   Log dir: $LOG_DIR"
echo "   Proof dir: $PROOF_DIR"
echo "   TMUX session: $TMUX_SESSION (GIỮ LẠI để xem log)"
echo ""
echo "💡 Xem log:"
echo "   tmux attach -t $TMUX_SESSION"
echo "   hoặc: ls -lht $LOG_DIR/s_maple_n*_run*.log"
echo ""
echo "To check results:"
echo "   grep -E 'SUCCESS|FAILED|PASSED|signal 9' $LOG_DIR/s_maple_n*_run*.log"
echo ""
echo "✅ TMUX session '$TMUX_SESSION' được GIỮ LẠI - Attach: tmux attach -t $TMUX_SESSION"
echo "💡 Log files: ls -lht $LOG_DIR/s_maple_n*_run*.log"

