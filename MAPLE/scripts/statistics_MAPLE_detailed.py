#!/usr/bin/env python3
"""
Tạo file thống kê MAPLE chi tiết tương tự BASELINE_SUMMARY_ALL.md
"""
import re
import glob
import statistics
from pathlib import Path
from datetime import datetime

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

def format_time(seconds):
    """Format seconds to h:mm:ss"""
    hours = int(seconds // 3600)
    minutes = int((seconds % 3600) // 60)
    secs = int(seconds % 60)
    return f"{hours}:{minutes:02d}:{secs:02d}"

def parse_log_file(log_file, n_value):
    """Parse a single log file and extract metrics"""
    metrics = {}
    try:
        with open(log_file, 'r') as f:
            content = f.read()
        
        # Parse Elapsed (wall clock) time
        elapsed_match = re.search(r'Elapsed \(wall clock\) time.*?:\s*(\d+:\d+:\d+|\d+:\d+)', content)
        if elapsed_match:
            metrics['wall_time_seconds'] = parse_time_to_seconds(elapsed_match.group(1))
            metrics['wall_time_str'] = elapsed_match.group(1)
        else:
            return None
        
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
        
        # Parse System time (seconds)
        sys_time_match = re.search(r'System time \(seconds\):\s*([\d.]+)', content)
        if sys_time_match:
            metrics['sys_time_seconds'] = float(sys_time_match.group(1))
        
        # Parse proof size
        proof_match = re.search(r'Saved proof fixture to:\s*(.*?\.bin)', content)
        if proof_match:
            proof_path = proof_match.group(1).strip().split()[0]
            if proof_path and Path(proof_path).exists():
                metrics['proof_size_bytes'] = Path(proof_path).stat().st_size
        
    except Exception as e:
        return None
    
    return metrics if metrics.get('wall_time_seconds') else None

def calculate_stats(values):
    """Calculate statistics for a list of values"""
    if not values:
        return {'mean': 0, 'min': 0, 'max': 0, 'std': 0, 'cv': 0}
    
    mean = statistics.mean(values)
    min_val = min(values)
    max_val = max(values)
    std = statistics.stdev(values) if len(values) > 1 else 0
    cv = (std / mean * 100) if mean > 0 else 0
    
    return {
        'mean': mean,
        'min': min_val,
        'max': max_val,
        'std': std,
        'cv': cv,
    }

def main():
    log_dir = Path("logs/MAPLE")
    n_values = [1, 10, 20, 50, 100, 200, 500, 700]
    
    print("# Thống kê MAPLE - Số liệu hiện tại")
    print()
    print(f"**Cập nhật lúc:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()
    print("## Tổng quan")
    print()
    print("| N | Runs | Avg Time | Min | Max | CV | Avg CPU% | Min CPU% | Max CPU% | Avg RAM (GB) | Min RAM | Max RAM | Avg User(s) | Avg Sys(s) | Avg Proof Size (MB) |")
    print("|-:|-:|:-:|:-:|:-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|")
    
    all_results = {}
    
    for n in n_values:
        # Tìm cả pattern MAPLE và v5 (file thực tế vẫn dùng v5)
        pattern_maple = str(log_dir / f"proof_ppgen_sabv_lmtr5_MAPLE_{n}_*.no_input.log")
        pattern_v5 = str(log_dir / f"proof_ppgen_sabv_lmtr5_v5_{n}_*.no_input.log")
        log_files = sorted(set(glob.glob(pattern_maple) + glob.glob(pattern_v5)))
        
        if not log_files:
            continue
        
        all_runs = []
        for log_file in log_files:
            metrics = parse_log_file(log_file, n)
            if metrics:
                metrics['filename'] = Path(log_file).stem
                all_runs.append(metrics)
        
        if not all_runs:
            continue
        
        # Calculate statistics
        wall_times = [r['wall_time_seconds'] for r in all_runs]
        cpu_usages = [r.get('cpu_percent', 0) for r in all_runs if r.get('cpu_percent')]
        ram_usages = [r.get('ram_gb', 0) for r in all_runs if r.get('ram_gb')]
        user_times = [r.get('user_time_seconds', 0) for r in all_runs if r.get('user_time_seconds')]
        sys_times = [r.get('sys_time_seconds', 0) for r in all_runs if r.get('sys_time_seconds')]
        proof_sizes = [r.get('proof_size_bytes', 0) / (1024*1024) for r in all_runs if r.get('proof_size_bytes')]
        
        stats_wall = calculate_stats(wall_times)
        stats_cpu = calculate_stats(cpu_usages) if cpu_usages else {'mean': 0, 'min': 0, 'max': 0, 'cv': 0}
        stats_ram = calculate_stats(ram_usages) if ram_usages else {'mean': 0, 'min': 0, 'max': 0, 'cv': 0}
        stats_user = calculate_stats(user_times) if user_times else {'mean': 0}
        stats_sys = calculate_stats(sys_times) if sys_times else {'mean': 0}
        stats_proof = calculate_stats(proof_sizes) if proof_sizes else {'mean': 0}
        
        all_results[n] = {
            'runs': all_runs,
            'stats': {
                'wall': stats_wall,
                'cpu': stats_cpu,
                'ram': stats_ram,
                'user': stats_user,
                'sys': stats_sys,
                'proof': stats_proof,
            }
        }
        
        avg_time_str = format_time(stats_wall['mean'])
        min_time_str = format_time(stats_wall['min'])
        max_time_str = format_time(stats_wall['max'])
        avg_proof_mb = stats_proof['mean'] if stats_proof['mean'] > 0 else 0.0
        
        print(f"| {n} | {len(all_runs)} | {avg_time_str} | {min_time_str} | {max_time_str} | {stats_wall['cv']:.1f}% | {stats_cpu['mean']:.1f} | {stats_cpu['min']:.1f} | {stats_cpu['max']:.1f} | {stats_ram['mean']:.1f} | {stats_ram['min']:.1f} | {stats_ram['max']:.1f} | {stats_user['mean']:.1f} | {stats_sys['mean']:.1f} | {avg_proof_mb:.2f} |")
    
    print()
    print("## Chi tiết từng N")
    print()
    
    for n in n_values:
        if n not in all_results:
            continue
        
        data = all_results[n]
        runs = data['runs']
        
        print(f"### N = {n} ({len(runs)} runs completed)")
        print()
        print("| Run | Elapsed | CPU% | RAM (GB) | User(s) | Sys(s) | Proof Size (MB) |")
        print("|---:|:-:|----:|---------:|--------:|-------:|:----:|")
        
        for i, run in enumerate(runs, 1):
            elapsed = run.get('wall_time_str', format_time(run.get('wall_time_seconds', 0)))
            cpu = run.get('cpu_percent', 0)
            ram = run.get('ram_gb', 0)
            user = run.get('user_time_seconds', 0)
            sys_time = run.get('sys_time_seconds', 0)
            proof_bytes = run.get('proof_size_bytes', 0)
            proof_mb = proof_bytes / (1024*1024) if proof_bytes > 0 else 0.0
            
            # Extract run identifier from filename
            filename = run['filename']
            run_id = filename.replace(f'proof_ppgen_sabv_lmtr5_MAPLE_{n}_', '').replace('.no_input', '')
            
            print(f"| {i} | {elapsed} | {cpu:.1f} | {ram:.2f} | {user:.1f} | {sys_time:.1f} | {proof_mb:.2f} |")
        
        print()

if __name__ == "__main__":
    main()

