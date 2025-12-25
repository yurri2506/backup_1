#!/usr/bin/env python3
"""
Phân tích các runs MAPLE thiếu số liệu hoặc có số liệu bất thường
"""
import re
import glob
import statistics
from pathlib import Path

def parse_time_to_seconds(time_str):
    """Parse time string h:mm:ss or m:ss to seconds"""
    parts = time_str.split(':')
    if len(parts) == 3:  # h:mm:ss
        hours, minutes, seconds = map(int, parts)
        return hours * 3600 + minutes * 60 + seconds
    elif len(parts) == 2:  # m:ss
        minutes, seconds = map(int, parts)
        return minutes * 60 + seconds
    else:
        return 0

def format_time(seconds):
    """Format seconds to h:mm:ss"""
    hours = int(seconds // 3600)
    minutes = int((seconds % 3600) // 60)
    secs = int(seconds % 60)
    return f"{hours}:{minutes:02d}:{secs:02d}"

def parse_log_file(log_file, n_value):
    """Parse a single log file and extract metrics"""
    metrics = {
        'wall_time_seconds': None,
        'cpu_percent': None,
        'ram_gb': None,
        'user_time_seconds': None,
        'has_all_metrics': True,
        'missing_fields': []
    }
    
    try:
        with open(log_file, 'r') as f:
            content = f.read()
            
        # Parse Elapsed (wall clock) time
        elapsed_match = re.search(r'Elapsed \(wall clock\) time.*?:\s*(\d+:\d+:\d+|\d+:\d+)', content)
        if elapsed_match:
            metrics['wall_time_seconds'] = parse_time_to_seconds(elapsed_match.group(1))
        else:
            metrics['has_all_metrics'] = False
            metrics['missing_fields'].append('wall_time')
        
        # Parse CPU percentage
        cpu_match = re.search(r'Percent of CPU this job got:\s*([\d.]+)', content)
        if cpu_match:
            metrics['cpu_percent'] = float(cpu_match.group(1))
        else:
            metrics['has_all_metrics'] = False
            metrics['missing_fields'].append('cpu_percent')
        
        # Parse Maximum resident set size (RAM in KB, convert to GB)
        ram_match = re.search(r'Maximum resident set size.*?:\s*(\d+)', content)
        if ram_match:
            ram_kb = int(ram_match.group(1))
            metrics['ram_gb'] = ram_kb / (1024 * 1024)  # KB to GB
        else:
            metrics['has_all_metrics'] = False
            metrics['missing_fields'].append('ram_gb')
        
        # Parse User time (seconds)
        user_time_match = re.search(r'User time \(seconds\):\s*([\d.]+)', content)
        if user_time_match:
            metrics['user_time_seconds'] = float(user_time_match.group(1))
        else:
            metrics['has_all_metrics'] = False
            metrics['missing_fields'].append('user_time')
        
    except Exception as e:
        metrics['has_all_metrics'] = False
        metrics['error'] = str(e)
    
    return metrics

def detect_outliers(values, field_name, threshold_std=2.0):
    """Detect outliers using z-score method"""
    if not values or len(values) < 2:
        return []
    
    valid_values = [(v, idx) for idx, v in enumerate(values) if v is not None]
    if len(valid_values) < 2:
        return []
    
    vals = [v[0] for v in valid_values]
    mean = statistics.mean(vals)
    stdev = statistics.stdev(vals) if len(vals) > 1 else 0
    
    if stdev == 0:
        return []
    
    outliers = []
    for val, idx in valid_values:
        z_score = abs((val - mean) / stdev)
        if z_score > threshold_std:
            outliers.append((idx, val, z_score, 'high' if val > mean else 'low'))
    
    return outliers

def main():
    log_dir = Path("logs/MAPLE")
    n_values = [1, 10, 20, 50, 100, 200, 500, 700]
    
    print("# 🔍 PHÂN TÍCH CÁC RUNS MAPLE THIẾU SỐ LIỆU VÀ BẤT THƯỜNG\n")
    print("**Ngày phân tích:** 2025-12-18\n")
    print("---\n")
    
    all_issues = []
    
    for n in n_values:
        pattern = str(log_dir / f"proof_ppgen_sabv_lmtr5_MAPLE_{n}_*.no_input.log")
        log_files = sorted(glob.glob(pattern))
        
        if not log_files:
            continue
        
        print(f"## N = {n}\n")
        print(f"**Tổng số runs:** {len(log_files)}\n")
        
        # Parse all runs
        all_runs = []
        missing_metrics_runs = []
        
        for log_file in log_files:
            run_name = Path(log_file).stem
            metrics = parse_log_file(log_file, n)
            metrics['run_name'] = run_name
            metrics['log_file'] = log_file
            all_runs.append(metrics)
            
            if not metrics['has_all_metrics']:
                missing_metrics_runs.append(metrics)
        
        # Check if runs are still running (no /usr/bin/time output)
        still_running = []
        truly_missing = []
        
        for run in missing_metrics_runs:
            try:
                with open(run['log_file'], 'r') as f:
                    content = f.read()
                    # Check if it looks like still running (has algorithm output but no time output)
                    if 'Elapsed (wall clock)' not in content and ('SABMAPLE' in content or 'LMTR4' in content or 'SP1' in content):
                        still_running.append(run)
                    else:
                        truly_missing.append(run)
            except:
                truly_missing.append(run)
        
        # Report runs still running
        if still_running:
            print("### ⏳ Runs Đang Chạy (Chưa Hoàn Thành)\n")
            print("| Run | Trạng Thái |")
            print("|-----|------------|")
            for run in still_running:
                print(f"| {run['run_name']} | ⏳ Đang chạy - chưa có metrics cuối cùng |")
            print()
        
        # Report truly missing metrics
        if truly_missing:
            print("### ❌ Runs Thiếu Số Liệu (Đã Hoàn Thành Nhưng Thiếu Metrics)\n")
            print("| Run | Thiếu Metrics | Lý Do Có Thể |")
            print("|-----|---------------|--------------|")
            for run in truly_missing:
                missing = ', '.join(run.get('missing_fields', []))
                reason = "File log không hoàn chỉnh hoặc process bị kill trước khi hoàn thành"
                if 'error' in run:
                    reason = f"Lỗi parse: {run['error']}"
                print(f"| {run['run_name']} | {missing} | {reason} |")
            print()
        else:
            print("### ✅ Tất Cả Runs Đều Có Đầy Đủ Metrics\n")
        
        # Detect outliers
        wall_times = [r['wall_time_seconds'] for r in all_runs]
        cpu_usages = [r['cpu_percent'] for r in all_runs]
        ram_usages = [r['ram_gb'] for r in all_runs]
        user_times = [r['user_time_seconds'] for r in all_runs]
        
        outliers_wall = detect_outliers(wall_times, 'wall_time', threshold_std=1.5)
        outliers_cpu = detect_outliers(cpu_usages, 'cpu_percent', threshold_std=1.5)
        outliers_ram = detect_outliers(ram_usages, 'ram_gb', threshold_std=2.0)
        outliers_user = detect_outliers(user_times, 'user_time', threshold_std=1.5)
        
        if outliers_wall or outliers_cpu or outliers_ram or outliers_user:
            print("### ⚠️ Runs Có Số Liệu Bất Thường\n")
            
            # Combine all outliers
            outlier_runs = {}
            for idx, val, z_score, direction in outliers_wall:
                run = all_runs[idx]
                if run['run_name'] not in outlier_runs:
                    outlier_runs[run['run_name']] = {'run': run, 'issues': []}
                outlier_runs[run['run_name']]['issues'].append(
                    f"Wall Time: {format_time(val)} (z-score: {z_score:.2f}, {direction})"
                )
            
            for idx, val, z_score, direction in outliers_cpu:
                run = all_runs[idx]
                if run['run_name'] not in outlier_runs:
                    outlier_runs[run['run_name']] = {'run': run, 'issues': []}
                outlier_runs[run['run_name']]['issues'].append(
                    f"CPU: {val:.1f}% (z-score: {z_score:.2f}, {direction})"
                )
            
            for idx, val, z_score, direction in outliers_ram:
                run = all_runs[idx]
                if run['run_name'] not in outlier_runs:
                    outlier_runs[run['run_name']] = {'run': run, 'issues': []}
                outlier_runs[run['run_name']]['issues'].append(
                    f"RAM: {val:.2f} GB (z-score: {z_score:.2f}, {direction})"
                )
            
            for idx, val, z_score, direction in outliers_user:
                run = all_runs[idx]
                if run['run_name'] not in outlier_runs:
                    outlier_runs[run['run_name']] = {'run': run, 'issues': []}
                user_hours = val / 3600
                outlier_runs[run['run_name']]['issues'].append(
                    f"User Time: {user_hours:.2f}h (z-score: {z_score:.2f}, {direction})"
                )
            
            # Calculate statistics for comparison
            valid_wall = [w for w in wall_times if w is not None]
            valid_cpu = [c for c in cpu_usages if c is not None]
            valid_ram = [r for r in ram_usages if r is not None]
            
            avg_wall = statistics.mean(valid_wall) if valid_wall else 0
            avg_cpu = statistics.mean(valid_cpu) if valid_cpu else 0
            avg_ram = statistics.mean(valid_ram) if valid_ram else 0
            
            print("| Run | Vấn Đề | Giá Trị | Giá Trị TB | Phân Tích |")
            print("|-----|--------|---------|------------|-----------|")
            
            for run_name, data in sorted(outlier_runs.items()):
                run = data['run']
                issues = '<br>'.join(data['issues'])
                
                # Analyze the issue
                analysis = []
                if run['wall_time_seconds'] and run['cpu_percent']:
                    wall = run['wall_time_seconds']
                    cpu = run['cpu_percent']
                    
                    # Check if high wall time with low CPU
                    if wall > avg_wall * 1.5 and cpu < avg_cpu * 0.7:
                        analysis.append("⚠️ Wall time cao + CPU thấp → Có thể do:")
                        analysis.append("- System load cao (CPU contention)")
                        analysis.append("- I/O bottleneck (disk đọc/ghi chậm)")
                        analysis.append("- Memory swapping")
                        analysis.append("- Background processes can thiệp")
                    elif wall > avg_wall * 1.5 and cpu > avg_cpu * 0.9:
                        analysis.append("ℹ️ Wall time cao + CPU bình thường → Có thể do:")
                        analysis.append("- Công việc tính toán phức tạp hơn")
                        analysis.append("- SP1 proving stage chậm hơn bình thường")
                    elif wall < avg_wall * 0.7 and cpu < avg_cpu * 0.7:
                        analysis.append("✅ Wall time thấp + CPU thấp → Có thể do:")
                        analysis.append("- N workload nhẹ hơn bình thường")
                        analysis.append("- Cache hits cao")
                        analysis.append("- System resources sẵn sàng")
                
                analysis_str = '<br>'.join(analysis) if analysis else "Cần kiểm tra thêm"
                
                wall_val = format_time(run['wall_time_seconds']) if run['wall_time_seconds'] else "N/A"
                cpu_val = f"{run['cpu_percent']:.1f}%" if run['cpu_percent'] else "N/A"
                ram_val = f"{run['ram_gb']:.2f} GB" if run['ram_gb'] else "N/A"
                values = f"Wall: {wall_val}<br>CPU: {cpu_val}<br>RAM: {ram_val}"
                avg_values = f"Wall: {format_time(avg_wall)}<br>CPU: {avg_cpu:.1f}%<br>RAM: {avg_ram:.2f} GB"
                
                print(f"| {run_name} | {issues} | {values} | {avg_values} | {analysis_str} |")
            
            print()
            
            all_issues.append({
                'n': n,
                'outliers': outlier_runs
            })
        else:
            print("### ✅ Không Có Runs Bất Thường\n")
        
        print("---\n")
    
    # Summary
    print("## 📊 Tóm Tắt\n")
    
    total_still_running = 0
    total_truly_missing = 0
    total_outliers = sum(len(data['outliers']) for data in all_issues)
    
    # Re-count for summary
    for n in n_values:
        pattern = str(log_dir / f"proof_ppgen_sabv_lmtr5_MAPLE_{n}_*.no_input.log")
        log_files = sorted(glob.glob(pattern))
        for log_file in log_files:
            metrics = parse_log_file(log_file, n)
            if not metrics['has_all_metrics']:
                try:
                    with open(log_file, 'r') as f:
                        content = f.read()
                        if 'Elapsed (wall clock)' not in content and ('SABMAPLE' in content or 'LMTR4' in content):
                            total_still_running += 1
                        else:
                            total_truly_missing += 1
                except:
                    total_truly_missing += 1
    
    print(f"- **Tổng số runs đang chạy (chưa hoàn thành):** {total_still_running}")
    print(f"- **Tổng số runs thiếu metrics (đã hoàn thành nhưng thiếu dữ liệu):** {total_truly_missing}")
    print(f"- **Tổng số runs có số liệu bất thường:** {total_outliers}")
    print()
    print("### 🔍 Giải Thích Chung Các Nguyên Nhân\n")
    print("""
1. **Wall Time Cao + CPU Usage Thấp:**
   - **Nguyên nhân chính:** System resource contention
   - CPU không được sử dụng tối đa do bị các processes khác tranh giành
   - Có thể do background jobs, system load cao, hoặc I/O wait
   - **Giải pháp:** Đảm bảo system không có processes nặng khác chạy đồng thời

2. **CPU Usage Thấp Bất Thường:**
   - Process không thể sử dụng hết CPU cores do:
     - System scheduler ưu tiên các processes khác
     - Memory bandwidth bottleneck
     - I/O wait time cao
   - **Đặc biệt ở N nhỏ (N=1, 10, 20):** Công việc không đủ để tận dụng hết parallelization

3. **Wall Time Cao Bất Thường:**
   - SP1 proving stage chiếm phần lớn thời gian và có thể biến thiên
   - System cache miss rate cao
   - Memory allocation/deallocation overhead

4. **Variation Lớn (High Std Dev):**
   - System state khác nhau giữa các runs
   - Background workload không consistent
   - Network I/O (nếu có)
   - File system cache state khác nhau
""")

if __name__ == "__main__":
    main()

