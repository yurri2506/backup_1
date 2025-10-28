#!/bin/bash

# Paper Results Analysis Script V2.1
# Đơn giản hóa để tránh lỗi syntax

LOG_DIR="/home/ubuntu/thanhhuyen/logs/fraud_detection_comprehensive_v2_1"

echo "📊 RESULTS ANALYSIS FOR PAPER V2.1: Analyzing fraud detection results for paper..."
echo "Thời gian: $(date)"
echo ""

while true; do
    echo "=== RESULTS ANALYSIS FOR PAPER V2.1: $(date) ==="
    
    echo "Baseline Malicious Results:"
    if [ -f "$LOG_DIR/baseline_malicious_run.log" ]; then
        echo "Baseline malicious tests completed: $(grep -c completed $LOG_DIR/baseline_malicious_run.log 2>/dev/null || echo 0)/4"
        echo "Latest baseline malicious progress:"
        tail -3 "$LOG_DIR/baseline_malicious_run.log"
        echo ""
    fi
    
    echo "V2 Malicious Results:"
    if [ -f "$LOG_DIR/v2_malicious_run.log" ]; then
        echo "V2 malicious tests completed: $(grep -c completed $LOG_DIR/v2_malicious_run.log 2>/dev/null || echo 0)/4"
        echo "Latest V2 malicious progress:"
        tail -3 "$LOG_DIR/v2_malicious_run.log"
        echo ""
    fi
    
    echo "Fraud Detection Algorithm Results:"
    if [ -f "$LOG_DIR/fraud_detection_algorithm_results.log" ]; then
        grep -E "(FRAUD DETECTION TEST RESULTS|Baseline Metrics|V2 Metrics|Comparison|Detection time|Accuracy|False positive|False negative|Malicious batches detected|Total malicious batches)" "$LOG_DIR/fraud_detection_algorithm_results.log"
        echo ""
    fi
    
    echo "Paper Metrics Summary V2.1:"
    if [ -f "$LOG_DIR/baseline_malicious_1.log" ] && [ -f "$LOG_DIR/v2_malicious_1.log" ]; then
        echo "Baseline vs V2 Fraud Detection Comparison:"
        echo "- Baseline: $(grep -c SP1 proving $LOG_DIR/baseline_malicious_1.log 2>/dev/null || echo 0) SP1 proving attempts"
        echo "- V2: $(grep -c fraud detected $LOG_DIR/v2_malicious_1.log 2>/dev/null || echo 0) fraud detections"
        echo ""
    fi
    
    sleep 10
done > "$LOG_DIR/paper_results_analysis_v2_1.log" 2>&1

