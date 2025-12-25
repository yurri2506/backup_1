#!/usr/bin/env python3
"""
Thống kê toàn bộ số liệu MAPLE từ các runs đã hoàn thành
"""
import re
import glob
import statistics
from pathlib import Path
from datetime import timedelta

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
        'proof_size_mb': None
    }
    
    try:
        with open(log_file, 'r') as f:
            content = f.read()
            
        # Parse Elapsed (wall clock) time
        elapsed_match = re.search(r'Elapsed \(wall clock\) time.*?:\s*(\d+:\d+:\d+|\d+:\d+)', content)
        if elapsed_match:
            metrics['wall_time_seconds'] = parse_time_to_seconds(elapsed_match.group(1))
        
        # Parse CPU percentage
        cpu_match = re.search(r'Percent of CPU this job got:\s*([\d.]+)', content)
        if cpu_match:
            metrics['cpu_percent'] = float(cpu_match.group(1))
        
        # Parse Maximum resident set size (RAM in KB, convert to GB)
        ram_match = re.search(r'Maximum resident set size.*?:\s*(\d+)', content)
        if ram_match:
            ram_kb = int(ram_match.group(1))
            metrics['ram_gb'] = ram_kb / (1024 * 1024)  # KB to GB
        
        # Parse User time (seconds)
        user_time_match = re.search(r'User time \(seconds\):\s*([\d.]+)', content)
        if user_time_match:
            metrics['user_time_seconds'] = float(user_time_match.group(1))
        
        # Try to find proof size from proof file
        # Match by finding proof file with same N value and similar timestamp
        log_path = Path(log_file)
        log_mtime = log_path.stat().st_mtime
        
        proof_dir = log_path.parent.parent / "proofs"
        if proof_dir.exists():
            # Find proof files for this N
            proof_pattern = f"MAPLE_proof_n{n_value}_*.json"
            proof_files = list(proof_dir.glob(proof_pattern))
            if proof_files:
                # Find proof file with modification time closest to log file
                closest_proof = min(proof_files, key=lambda p: abs(p.stat().st_mtime - log_mtime))
                # Only use if within 24 hours
                if abs(closest_proof.stat().st_mtime - log_mtime) < 86400:
                    proof_size_bytes = closest_proof.stat().st_size
                    metrics['proof_size_mb'] = proof_size_bytes / (1024 * 1024)
        
    except Exception as e:
        pass  # Silent error for missing proof files
    
    return metrics

def calculate_stats(values):
    """Calculate statistics for a list of values"""
    if not values or all(v is None for v in values):
        return None
    
    valid_values = [v for v in values if v is not None]
    if not valid_values:
        return None
    
    return {
        'mean': statistics.mean(valid_values),
        'min': min(valid_values),
        'max': max(valid_values),
        'median': statistics.median(valid_values),
        'stdev': statistics.stdev(valid_values) if len(valid_values) > 1 else 0.0,
        'count': len(valid_values)
    }

def main():
    log_dir = Path("logs/MAPLE")
    
    # All N values to check
    n_values = [1, 10, 20, 50, 100, 200, 500, 700]
    
    print("# 📊 MAPLE PESSIMISTIC PROOF - THỐNG KÊ TOÀN BỘ SỐ LIỆU")
    from datetime import datetime
    print(f"\n**Ngày tạo:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("**Thuật toán:** MAPLE (SABMAPLE + LMTR4)")
    print("**Hệ thống proving:** SP1 (CPU-based)\n")
    print("---\n")
    
    all_results = {}
    
    for n in n_values:
        # Find all log files for this N
        pattern = str(log_dir / f"proof_ppgen_sabv_lmtr5_MAPLE_{n}_*.no_input.log")
        log_files = sorted(glob.glob(pattern))
        
        if not log_files:
            continue
        
        metrics_list = {
            'wall_time_seconds': [],
            'cpu_percent': [],
            'ram_gb': [],
            'user_time_seconds': [],
            'proof_size_mb': []
        }
        
        for log_file in log_files:
            metrics = parse_log_file(log_file, n)
            for key in metrics_list:
                if metrics[key] is not None:
                    metrics_list[key].append(metrics[key])
        
        # Calculate statistics
        stats = {}
        stats['wall_time'] = calculate_stats(metrics_list['wall_time_seconds'])
        stats['cpu_percent'] = calculate_stats(metrics_list['cpu_percent'])
        stats['ram_gb'] = calculate_stats(metrics_list['ram_gb'])
        stats['user_time'] = calculate_stats(metrics_list['user_time_seconds'])
        stats['proof_size'] = calculate_stats(metrics_list['proof_size_mb'])
        
        all_results[n] = {
            'count': len(log_files),
            'stats': stats
        }
    
    # Print summary table
    print("## 📈 Bảng Thống Kê Tổng Hợp\n")
    print("| N | Số Runs | Thời Gian TB (Wall) | CPU TB (%) | RAM TB (GB) | Thời Gian CPU TB (h) | Proof TB (MB) |")
    print("|---|---------|---------------------|------------|-------------|----------------------|---------------|")
    
    for n in n_values:
        if n not in all_results:
            continue
        
        result = all_results[n]
        count = result['count']
        stats = result['stats']
        
        # Format wall time
        if stats['wall_time']:
            wall_avg = format_time(stats['wall_time']['mean'])
        else:
            wall_avg = "N/A"
        
        # Format CPU
        if stats['cpu_percent']:
            cpu_avg = f"{stats['cpu_percent']['mean']:.1f}"
        else:
            cpu_avg = "N/A"
        
        # Format RAM
        if stats['ram_gb']:
            ram_avg = f"{stats['ram_gb']['mean']:.2f}"
        else:
            ram_avg = "N/A"
        
        # Format user time (convert seconds to hours)
        if stats['user_time']:
            user_hours = stats['user_time']['mean'] / 3600
            user_avg = f"{user_hours:.2f}"
        else:
            user_avg = "N/A"
        
        # Format proof size
        if stats['proof_size']:
            proof_avg = f"{stats['proof_size']['mean']:.2f}"
        else:
            proof_avg = "N/A"
        
        print(f"| {n} | {count} | {wall_avg} | {cpu_avg} | {ram_avg} | {user_avg} | {proof_avg} |")
    
    # Print detailed statistics for each N
    print("\n---\n")
    print("## 📊 Chi Tiết Theo Từng N\n")
    
    for n in n_values:
        if n not in all_results:
            continue
        
        result = all_results[n]
        count = result['count']
        stats = result['stats']
        
        print(f"### N = {n}")
        print(f"**Số runs:** {count}\n")
        
        print("| Metric | Trung Bình | Min | Max | Median | Std Dev |")
        print("|--------|-----------|-----|-----|--------|---------|")
        
        # Wall Time
        if stats['wall_time']:
            wt = stats['wall_time']
            print(f"| Thời Gian (Wall) | {format_time(wt['mean'])} | {format_time(wt['min'])} | {format_time(wt['max'])} | {format_time(wt['median'])} | {format_time(wt['stdev'])} |")
        
        # CPU Usage
        if stats['cpu_percent']:
            cpu = stats['cpu_percent']
            print(f"| CPU (%) | {cpu['mean']:.1f} | {cpu['min']:.1f} | {cpu['max']:.1f} | {cpu['median']:.1f} | {cpu['stdev']:.1f} |")
        
        # RAM Usage
        if stats['ram_gb']:
            ram = stats['ram_gb']
            print(f"| RAM (GB) | {ram['mean']:.2f} | {ram['min']:.2f} | {ram['max']:.2f} | {ram['median']:.2f} | {ram['stdev']:.2f} |")
        
        # User Time (hours)
        if stats['user_time']:
            ut = stats['user_time']
            ut_mean_h = ut['mean'] / 3600
            ut_min_h = ut['min'] / 3600
            ut_max_h = ut['max'] / 3600
            ut_med_h = ut['median'] / 3600
            ut_std_h = ut['stdev'] / 3600
            print(f"| Thời Gian CPU (h) | {ut_mean_h:.2f} | {ut_min_h:.2f} | {ut_max_h:.2f} | {ut_med_h:.2f} | {ut_std_h:.2f} |")
        
        # Proof Size
        if stats['proof_size']:
            ps = stats['proof_size']
            print(f"| Proof Size (MB) | {ps['mean']:.2f} | {ps['min']:.2f} | {ps['max']:.2f} | {ps['median']:.2f} | {ps['stdev']:.2f} |")
        
        print()

if __name__ == "__main__":
    main()

