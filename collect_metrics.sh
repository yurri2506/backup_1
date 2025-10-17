#!/usr/bin/env bash
# Script thu thập metrics chi tiết từ logs của 2 máy
# Không tự động chạy, dùng sau khi thực nghiệm hoàn tất

set -euo pipefail

BASELINE_LOG_DIR="/home/ubuntu/thanhhuyen/logs/baseline"
SABV_LOG_DIR="/home/ubuntu/thanhhuyen/logs/sabv_lmtr"
OUTPUT_FILE="/home/ubuntu/thanhhuyen/metrics_summary.md"

echo "📊 === THU THẬP METRICS CHI TIẾT ===" > "$OUTPUT_FILE"
echo "Thời gian: $(date)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Function để parse /usr/bin/time -v output
parse_time_v() {
    local log_file=$1
    local test_name=$2
    
    if [ ! -f "$log_file" ]; then
        echo "  ⚠️ File không tồn tại: $log_file"
        return
    fi
    
    echo "### $test_name" >> "$OUTPUT_FILE"
    
    # Lấy elapsed time
    elapsed=$(grep "Elapsed (wall clock)" "$log_file" | awk '{print $NF}')
    echo "- **Thời gian**: $elapsed" >> "$OUTPUT_FILE"
    
    # Lấy CPU %
    cpu_percent=$(grep "Percent of CPU" "$log_file" | awk '{print $NF}')
    echo "- **CPU %**: $cpu_percent" >> "$OUTPUT_FILE"
    
    # Lấy Max RSS (RAM peak)
    max_rss=$(grep "Maximum resident set size" "$log_file" | awk '{print $NF}')
    max_rss_mb=$((max_rss / 1024))
    echo "- **Peak RAM**: ${max_rss_mb} MB" >> "$OUTPUT_FILE"
    
    # Lấy page faults
    major_faults=$(grep "Major (requiring I/O) page faults" "$log_file" | awk '{print $NF}')
    minor_faults=$(grep "Minor (reclaiming a frame) page faults" "$log_file" | awk '{print $NF}')
    echo "- **Page faults**: Major=$major_faults, Minor=$minor_faults" >> "$OUTPUT_FILE"
    
    # Lấy context switches
    vol_switches=$(grep "Voluntary context switches" "$log_file" | awk '{print $NF}')
    invol_switches=$(grep "Involuntary context switches" "$log_file" | awk '{print $NF}')
    echo "- **Context switches**: Voluntary=$vol_switches, Involuntary=$invol_switches" >> "$OUTPUT_FILE"
    
    # Lấy I/O
    fs_inputs=$(grep "File system inputs" "$log_file" | awk '{print $NF}')
    fs_outputs=$(grep "File system outputs" "$log_file" | awk '{print $NF}')
    echo "- **File I/O**: Inputs=$fs_inputs, Outputs=$fs_outputs" >> "$OUTPUT_FILE"
    
    # Lấy exit status
    exit_status=$(grep "Exit status" "$log_file" | awk '{print $NF}')
    echo "- **Exit status**: $exit_status" >> "$OUTPUT_FILE"
    
    echo "" >> "$OUTPUT_FILE"
}

# Function để tính throughput
calc_throughput() {
    local elapsed_str=$1
    local n_exits=$2
    
    # Convert h:mm:ss to seconds
    if [[ $elapsed_str =~ ([0-9]+):([0-9]+):([0-9]+) ]]; then
        hours=${BASH_REMATCH[1]}
        minutes=${BASH_REMATCH[2]}
        seconds=${BASH_REMATCH[3]}
        total_seconds=$((hours * 3600 + minutes * 60 + seconds))
    elif [[ $elapsed_str =~ ([0-9]+):([0-9.]+) ]]; then
        minutes=${BASH_REMATCH[1]}
        seconds=${BASH_REMATCH[2]%.*}
        total_seconds=$((minutes * 60 + seconds))
    else
        total_seconds=1
    fi
    
    if [ $total_seconds -gt 0 ]; then
        throughput=$(echo "scale=2; $n_exits / $total_seconds" | bc)
        echo "$throughput exits/s"
    else
        echo "N/A"
    fi
}

echo "## 📈 BẢNG SO SÁNH HIỆU SUẤT" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "| Exits | Test | Elapsed | CPU % | Peak RAM (MB) | Throughput | Status |" >> "$OUTPUT_FILE"
echo "|-------|------|---------|-------|---------------|------------|--------|" >> "$OUTPUT_FILE"

# Collect metrics for each N
for N in 1 5 10 20 50; do
    # Baseline no input
    if [ -f "$BASELINE_LOG_DIR/proof_ppgen_${N}.no_input.log" ]; then
        elapsed=$(grep "Elapsed (wall clock)" "$BASELINE_LOG_DIR/proof_ppgen_${N}.no_input.log" | awk '{print $NF}')
        cpu=$(grep "Percent of CPU" "$BASELINE_LOG_DIR/proof_ppgen_${N}.no_input.log" | awk '{print $NF}')
        rss=$(grep "Maximum resident set size" "$BASELINE_LOG_DIR/proof_ppgen_${N}.no_input.log" | awk '{print $NF}')
        rss_mb=$((rss / 1024))
        exit_status=$(grep "Exit status" "$BASELINE_LOG_DIR/proof_ppgen_${N}.no_input.log" | awk '{print $NF}')
        throughput=$(calc_throughput "$elapsed" "$N")
        
        status="✅"
        [ "$exit_status" != "0" ] && status="❌"
        
        echo "| $N | Baseline (no input) | $elapsed | $cpu | $rss_mb | $throughput | $status |" >> "$OUTPUT_FILE"
    fi
    
    # SABV/LMTR no input
    if [ -f "$SABV_LOG_DIR/proof_ppgen_sabv_lmtr_${N}.no_input.log" ]; then
        elapsed=$(grep "Elapsed (wall clock)" "$SABV_LOG_DIR/proof_ppgen_sabv_lmtr_${N}.no_input.log" | awk '{print $NF}')
        cpu=$(grep "Percent of CPU" "$SABV_LOG_DIR/proof_ppgen_sabv_lmtr_${N}.no_input.log" | awk '{print $NF}')
        rss=$(grep "Maximum resident set size" "$SABV_LOG_DIR/proof_ppgen_sabv_lmtr_${N}.no_input.log" | awk '{print $NF}')
        rss_mb=$((rss / 1024))
        exit_status=$(grep "Exit status" "$SABV_LOG_DIR/proof_ppgen_sabv_lmtr_${N}.no_input.log" | awk '{print $NF}')
        throughput=$(calc_throughput "$elapsed" "$N")
        
        status="✅"
        [ "$exit_status" != "0" ] && status="❌"
        
        echo "| $N | SABV/LMTR (no input) | $elapsed | $cpu | $rss_mb | $throughput | $status |" >> "$OUTPUT_FILE"
    fi
done

echo "" >> "$OUTPUT_FILE"
echo "## 🔍 CHI TIẾT METRICS THEO NHÓM" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Thu thập metrics chi tiết cho từng test
for N in 1 5 10 20 50; do
    echo "### Exits = $N" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    echo "#### Baseline (no input):" >> "$OUTPUT_FILE"
    parse_time_v "$BASELINE_LOG_DIR/proof_ppgen_${N}.no_input.log" "Baseline N=$N"
    
    echo "#### SABV/LMTR (no input):" >> "$OUTPUT_FILE"
    parse_time_v "$SABV_LOG_DIR/proof_ppgen_sabv_lmtr_${N}.no_input.log" "SABV/LMTR N=$N"
    
    echo "---" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
done

# Phân tích dstat logs
echo "## 💻 PHÂN TÍCH RESOURCE USAGE (dstat)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

if [ -f "$BASELINE_LOG_DIR/dstat.log" ]; then
    echo "### Baseline Resource Usage:" >> "$OUTPUT_FILE"
    echo "\`\`\`" >> "$OUTPUT_FILE"
    echo "Avg CPU: $(awk '{sum+=$1; count++} END {if(count>0) print sum/count"%"}' $BASELINE_LOG_DIR/dstat.log | grep -v "^$" | tail -1)" >> "$OUTPUT_FILE"
    echo "Peak RAM: $(awk '{if($2>max) max=$2} END {print max}' $BASELINE_LOG_DIR/dstat.log | grep -v "^$" | tail -1)" >> "$OUTPUT_FILE"
    echo "\`\`\`" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
fi

if [ -f "$SABV_LOG_DIR/dstat.log" ]; then
    echo "### SABV/LMTR Resource Usage:" >> "$OUTPUT_FILE"
    echo "\`\`\`" >> "$OUTPUT_FILE"
    echo "Avg CPU: $(awk '{sum+=$1; count++} END {if(count>0) print sum/count"%"}' $SABV_LOG_DIR/dstat.log | grep -v "^$" | tail -1)" >> "$OUTPUT_FILE"
    echo "Peak RAM: $(awk '{if($2>max) max=$2} END {print max}' $SABV_LOG_DIR/dstat.log | grep -v "^$" | tail -1)" >> "$OUTPUT_FILE"
    echo "\`\`\`" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
fi

# Tính toán improvement
echo "## 🚀 CẢI THIỆN HIỆU SUẤT" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "| Metric | Baseline | SABV/LMTR | Improvement |" >> "$OUTPUT_FILE"
echo "|--------|----------|-----------|-------------|" >> "$OUTPUT_FILE"

# Ví dụ: tính cho N=1
if [ -f "$BASELINE_LOG_DIR/proof_ppgen_1.no_input.log" ] && [ -f "$SABV_LOG_DIR/proof_ppgen_sabv_lmtr_1.no_input.log" ]; then
    baseline_time=$(grep "Elapsed (wall clock)" "$BASELINE_LOG_DIR/proof_ppgen_1.no_input.log" | awk '{print $NF}')
    sabv_time=$(grep "Elapsed (wall clock)" "$SABV_LOG_DIR/proof_ppgen_sabv_lmtr_1.no_input.log" | awk '{print $NF}')
    
    baseline_ram=$(grep "Maximum resident set size" "$BASELINE_LOG_DIR/proof_ppgen_1.no_input.log" | awk '{print $NF}')
    sabv_ram=$(grep "Maximum resident set size" "$SABV_LOG_DIR/proof_ppgen_sabv_lmtr_1.no_input.log" | awk '{print $NF}')
    
    baseline_ram_mb=$((baseline_ram / 1024))
    sabv_ram_mb=$((sabv_ram / 1024))
    
    echo "| Time (N=1) | $baseline_time | $sabv_time | TBD |" >> "$OUTPUT_FILE"
    echo "| RAM (N=1) | ${baseline_ram_mb}MB | ${sabv_ram_mb}MB | TBD |" >> "$OUTPUT_FILE"
fi

echo "" >> "$OUTPUT_FILE"
echo "## 📋 KẾT LUẬN" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "- Tổng số tests đã chạy: $(ls -1 $BASELINE_LOG_DIR/proof_*.log $SABV_LOG_DIR/proof_*.log 2>/dev/null | wc -l)" >> "$OUTPUT_FILE"
echo "- Baseline tests: $(ls -1 $BASELINE_LOG_DIR/proof_*.log 2>/dev/null | wc -l)" >> "$OUTPUT_FILE"
echo "- SABV/LMTR tests: $(ls -1 $SABV_LOG_DIR/proof_*.log 2>/dev/null | wc -l)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "📁 **Log files**:" >> "$OUTPUT_FILE"
echo "- Baseline: $BASELINE_LOG_DIR" >> "$OUTPUT_FILE"
echo "- SABV/LMTR: $SABV_LOG_DIR" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "---" >> "$OUTPUT_FILE"
echo "*Báo cáo được tạo tự động từ logs thực nghiệm*" >> "$OUTPUT_FILE"

echo "✅ Metrics summary đã được tạo: $OUTPUT_FILE"
cat "$OUTPUT_FILE"

