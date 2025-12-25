#!/usr/bin/env python3
"""
Tính thống kê MAPLE chỉ với các runs tốt - runs có thời gian NHỎ HƠN trung bình của tất cả 10 runs
"""
import re
import glob
import statistics
from pathlib import Path

def parse_time_to_minutes(time_str):
    """Parse time string h:mm:ss to minutes"""
    parts = time_str.split(':')
    if len(parts) == 3:
        hours, minutes, seconds = map(int, parts)
        return hours * 60 + minutes + seconds / 60.0
    elif len(parts) == 2:
        minutes, seconds = map(int, parts)
        return minutes + seconds / 60.0
    return 0

def parse_time_to_seconds(time_str):
    """Parse time string h:mm:ss to seconds"""
    parts = time_str.split(':')
    if len(parts) == 3:
        hours, minutes, seconds = map(int, parts)
        return hours * 3600 + minutes * 60 + seconds
    elif len(parts) == 2:
        minutes, seconds = map(int, parts)
        return minutes * 60 + seconds
    return 0

def format_minutes(minutes):
    """Format minutes to readable string"""
    if minutes < 60:
        return f"{minutes:.1f} phút"
    else:
        hours = int(minutes // 60)
        mins = minutes % 60
        return f"{hours}h {mins:.1f}m"

def parse_log_file(log_file):
    """Parse a single log file and extract metrics"""
    metrics = {}
    try:
        with open(log_file, 'r') as f:
            content = f.read()
        
        # Parse Elapsed (wall clock) time
        elapsed_match = re.search(r'Elapsed \(wall clock\) time.*?:\s*(\d+:\d+:\d+|\d+:\d+)', content)
        if elapsed_match:
            metrics['wall_time_minutes'] = parse_time_to_minutes(elapsed_match.group(1))
            metrics['wall_time_seconds'] = parse_time_to_seconds(elapsed_match.group(1))
        else:
            return None  # Not completed
        
        # Parse CPU percentage
        cpu_match = re.search(r'Percent of CPU this job got:\s*([\d.]+)', content)
        if cpu_match:
            metrics['cpu_percent'] = float(cpu_match.group(1))
        
        # Parse Maximum resident set size (RAM in KB, convert to GB)
        ram_match = re.search(r'Maximum resident set size.*?:\s*(\d+)', content)
        if ram_match:
            ram_kb = int(ram_match.group(1))
            metrics['ram_gb'] = ram_kb / (1024 * 1024)
        
        # Parse User time (seconds)
        user_time_match = re.search(r'User time \(seconds\):\s*([\d.]+)', content)
        if user_time_match:
            metrics['user_time_seconds'] = float(user_time_match.group(1))
            metrics['user_time_hours'] = metrics['user_time_seconds'] / 3600
        
    except Exception as e:
        return None
    
    return metrics if metrics.get('wall_time_minutes') else None

def main():
    log_dir = Path("logs/MAPLE")
    n_values = [1, 10, 20, 50, 100, 200, 500, 700]
    
    print("# 📊 MAPLE PESSIMISTIC PROOF - THỐNG KÊ RUNS TỐT (NHỎ HƠN TRUNG BÌNH)\n")
    print("**Ngày tạo:** 2025-12-24")
    print("**Thuật toán:** MAPLE (SABMAPLE + LMTR4)")
    print("**Hệ thống proving:** SP1 (CPU-based)")
    print("**Định nghĩa run tốt:** Runs có thời gian NHỎ HƠN trung bình của tất cả 10 runs\n")
    print("---\n")
    
    # Summary table
    summary_rows = []
    details = []
    
    for n in n_values:
        pattern = str(log_dir / f"proof_ppgen_sabv_lmtr5_MAPLE_{n}_*.no_input.log")
        log_files = sorted(glob.glob(pattern))
        
        # Parse all runs first
        all_runs = []
        for log_file in log_files:
            metrics = parse_log_file(log_file)
            if metrics:
                metrics['filename'] = Path(log_file).stem
                all_runs.append(metrics)
        
        if len(all_runs) < 10:
            continue
        
        # Calculate average of all runs
        all_wall_times = [r['wall_time_minutes'] for r in all_runs]
        avg_all = statistics.mean(all_wall_times)
        
        # Filter runs that are BETTER than average (smaller wall time)
        good_runs = [r for r in all_runs if r['wall_time_minutes'] < avg_all]
        excluded_runs = [r for r in all_runs if r['wall_time_minutes'] >= avg_all]
        
        if not good_runs:
            continue
        
        # Calculate statistics for good runs
        wall_times = [r['wall_time_minutes'] for r in good_runs]
        cpu_usages = [r.get('cpu_percent', 0) for r in good_runs if r.get('cpu_percent')]
        ram_usages = [r.get('ram_gb', 0) for r in good_runs if r.get('ram_gb')]
        user_times_hours = [r.get('user_time_hours', 0) for r in good_runs if r.get('user_time_hours')]
        
        # Statistics
        avg_wall = statistics.mean(wall_times)
        min_wall = min(wall_times)
        max_wall = max(wall_times)
        median_wall = statistics.median(wall_times)
        std_wall = statistics.stdev(wall_times) if len(wall_times) > 1 else 0
        
        avg_cpu = statistics.mean(cpu_usages) if cpu_usages else 0
        min_cpu = min(cpu_usages) if cpu_usages else 0
        max_cpu = max(cpu_usages) if cpu_usages else 0
        median_cpu = statistics.median(cpu_usages) if cpu_usages else 0
        std_cpu = statistics.stdev(cpu_usages) if len(cpu_usages) > 1 else 0
        
        avg_ram = statistics.mean(ram_usages) if ram_usages else 0
        min_ram = min(ram_usages) if ram_usages else 0
        max_ram = max(ram_usages) if ram_usages else 0
        median_ram = statistics.median(ram_usages) if ram_usages else 0
        std_ram = statistics.stdev(ram_usages) if len(ram_usages) > 1 else 0
        
        avg_user = statistics.mean(user_times_hours) if user_times_hours else 0
        min_user = min(user_times_hours) if user_times_hours else 0
        max_user = max(user_times_hours) if user_times_hours else 0
        median_user = statistics.median(user_times_hours) if user_times_hours else 0
        std_user = statistics.stdev(user_times_hours) if len(user_times_hours) > 1 else 0
        
        summary_rows.append({
            'n': n,
            'count': len(good_runs),
            'excluded': len(excluded_runs),
            'avg_all': avg_all,
            'wall_avg': avg_wall,
            'wall_min': min_wall,
            'wall_max': max_wall,
            'cpu': avg_cpu,
            'ram': avg_ram,
            'user': avg_user,
        })
        
        details.append({
            'n': n,
            'count': len(good_runs),
            'excluded': [r['filename'] for r in excluded_runs],
            'avg_all': avg_all,
            'wall': {'avg': avg_wall, 'min': min_wall, 'max': max_wall, 'median': median_wall, 'std': std_wall},
            'cpu': {'avg': avg_cpu, 'min': min_cpu, 'max': max_cpu, 'median': median_cpu, 'std': std_cpu},
            'ram': {'avg': avg_ram, 'min': min_ram, 'max': max_ram, 'median': median_ram, 'std': std_ram},
            'user': {'avg': avg_user, 'min': min_user, 'max': max_user, 'median': median_user, 'std': std_user},
        })
    
    # Print summary table
    print("## 📈 Bảng Thống Kê Tổng Hợp (Runs Nhỏ Hơn Trung Bình)\n")
    print("| N | Số Runs Tốt | Loại Bỏ | TB Tất Cả (phút) | TB Runs Tốt (phút) | TB Runs Tốt | Min (phút) | Max (phút) | CPU TB (%) | RAM TB (GB) | User Time TB (h) |")
    print("|---|-------------|---------|------------------|-------------------|-------------|------------|------------|------------|-------------|------------------|")
    
    for row in summary_rows:
        excluded_str = f"{row['excluded']}"
        improvement = row['avg_all'] - row['wall_avg']
        improvement_pct = (improvement / row['avg_all'] * 100) if row['avg_all'] > 0 else 0
        print(f"| {row['n']} | {row['count']} | {excluded_str} | {row['avg_all']:.1f} | {row['wall_avg']:.1f} | {format_minutes(row['wall_avg'])} | {row['wall_min']:.1f} | {row['wall_max']:.1f} | {row['cpu']:.1f} | {row['ram']:.2f} | {row['user']:.2f} |")
    
    print("\n---\n")
    
    # Detailed statistics
    print("## 📊 Chi Tiết Theo Từng N\n")
    
    for det in details:
        print(f"### N = {det['n']}")
        print(f"**Số runs tốt (nhỏ hơn TB):** {det['count']}")
        print(f"**Trung bình tất cả runs:** {format_minutes(det['avg_all'])} ({det['avg_all']:.1f} phút)")
        print(f"**Trung bình runs tốt:** {format_minutes(det['wall']['avg'])} ({det['wall']['avg']:.1f} phút)")
        improvement = det['avg_all'] - det['wall']['avg']
        improvement_pct = (improvement / det['avg_all'] * 100) if det['avg_all'] > 0 else 0
        print(f"**Cải thiện:** {format_minutes(improvement)} ({improvement:.1f} phút, {improvement_pct:.1f}% nhanh hơn)")
        if det['excluded']:
            excluded_names = [name.replace('proof_ppgen_sabv_lmtr5_MAPLE_', '').replace('.no_input', '') for name in det['excluded']]
            print(f"**Đã loại bỏ (≥TB):** {', '.join(excluded_names)}")
        print()
        
        print("| Metric | Trung Bình | Min | Max | Median | Std Dev |")
        print("|--------|-----------|-----|-----|--------|---------|")
        print(f"| Thời Gian (phút) | {det['wall']['avg']:.1f} | {det['wall']['min']:.1f} | {det['wall']['max']:.1f} | {det['wall']['median']:.1f} | {det['wall']['std']:.1f} |")
        print(f"| Thời Gian (đọc được) | {format_minutes(det['wall']['avg'])} | {format_minutes(det['wall']['min'])} | {format_minutes(det['wall']['max'])} | {format_minutes(det['wall']['median'])} | {format_minutes(det['wall']['std'])} |")
        print(f"| CPU (%) | {det['cpu']['avg']:.1f} | {det['cpu']['min']:.1f} | {det['cpu']['max']:.1f} | {det['cpu']['median']:.1f} | {det['cpu']['std']:.1f} |")
        print(f"| RAM (GB) | {det['ram']['avg']:.2f} | {det['ram']['min']:.2f} | {det['ram']['max']:.2f} | {det['ram']['median']:.2f} | {det['ram']['std']:.2f} |")
        print(f"| Thời Gian CPU (h) | {det['user']['avg']:.2f} | {det['user']['min']:.2f} | {det['user']['max']:.2f} | {det['user']['median']:.2f} | {det['user']['std']:.2f} |")
        print()
    
    # Total summary
    total_good = sum(d['count'] for d in details)
    total_excluded = sum(len(d['excluded']) for d in details)
    
    print("---\n")
    print("## 📋 Tóm Tắt\n")
    print(f"- **Tổng số runs tốt (nhỏ hơn TB):** {total_good}")
    print(f"- **Tổng số runs đã loại bỏ (≥TB):** {total_excluded}")
    print(f"- **Tỷ lệ runs tốt:** {total_good*100/(total_good+total_excluded):.1f}%")
    print()
    print("**Định nghĩa:**")
    print("- **Run tốt:** Wall time < Trung bình của tất cả 10 runs")
    print("- **Run loại bỏ:** Wall time ≥ Trung bình của tất cả 10 runs")

if __name__ == "__main__":
    main()

