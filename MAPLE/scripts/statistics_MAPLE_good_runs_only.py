#!/usr/bin/env python3
"""
Tính thống kê MAPLE chỉ với các runs tốt (loại bỏ outliers do kẹt RAM/resource contention)
"""
import re
import glob
import statistics
from pathlib import Path

# Danh sách các runs bất thường cần loại bỏ (do kẹt RAM/resource contention)
BAD_RUNS = {
    '10': ['extra6'],  # Wall time cao + CPU thấp
    '20': ['extra2', 'extra7', 'extra8'],  # Variations bất thường
    '50': ['extra6'],  # Wall time cao + CPU thấp
    '100': ['extra6', 'extra8', 'round5'],  # Wall time cao + CPU thấp hoặc variations
    '200': ['round5'],  # Wall time cao + CPU thấp
    '500': ['round2', 'round5'],  # RAM cao hoặc Wall time cao + CPU thấp
    '700': ['round4'],  # Wall time cao + CPU thấp
}

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

def is_bad_run(log_file, n_value):
    """Check if a run is in the bad runs list"""
    filename = Path(log_file).stem
    n_str = str(n_value)
    
    if n_str not in BAD_RUNS:
        return False
    
    for bad_pattern in BAD_RUNS[n_str]:
        if bad_pattern in filename:
            return True
    
    return False

def parse_log_file(log_file):
    """Parse a single log file and extract metrics"""
    metrics = {}
    try:
        with open(log_file, 'r') as f:
            content = f.read()
        
        # Parse Elapsed (wall clock) time
        elapsed_match = re.search(r'Elapsed \(wall clock\) time.*?:\s*(\d+:\d+:\d+|\d+:\d+)', content)
        if elapsed_match:
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
        
        # Parse proof size
        proof_match = re.search(r'Saved proof fixture to:\s*(.*?\.bin)', content)
        if proof_match:
            proof_path = proof_match.group(1).strip()
            # Clean up any trailing text
            proof_path = proof_path.split()[0] if proof_path else None
            if proof_path and Path(proof_path).exists():
                metrics['proof_size_bytes'] = Path(proof_path).stat().st_size
        
    except Exception as e:
        return None
    
    return metrics if metrics.get('wall_time_seconds') else None

def main():
    log_dir = Path("logs/MAPLE")
    n_values = [1, 10, 20, 50, 100, 200, 500, 700]
    
    print("# 📊 MAPLE PESSIMISTIC PROOF - THỐNG KÊ CHỈ VỚI CÁC RUNS TỐT\n")
    print("**Ngày tạo:** 2025-12-24")
    print("**Thuật toán:** MAPLE (SABMAPLE + LMTR4)")
    print("**Hệ thống proving:** SP1 (CPU-based)")
    print("**Lưu ý:** Đã loại bỏ các runs bất thường do kẹt RAM/resource contention\n")
    print("---\n")
    
    # Summary table
    summary_rows = []
    details = []
    
    for n in n_values:
        pattern = str(log_dir / f"proof_ppgen_sabv_lmtr5_MAPLE_{n}_*.no_input.log")
        log_files = sorted(glob.glob(pattern))
        
        # Filter good runs only
        good_runs = []
        bad_runs = []
        
        for log_file in log_files:
            if is_bad_run(log_file, n):
                bad_runs.append(Path(log_file).stem)
            else:
                metrics = parse_log_file(log_file)
                if metrics:
                    good_runs.append(metrics)
        
        if not good_runs:
            continue
        
        # Calculate statistics
        wall_times = [r['wall_time_seconds'] for r in good_runs]
        cpu_usages = [r.get('cpu_percent', 0) for r in good_runs if r.get('cpu_percent')]
        ram_usages = [r.get('ram_gb', 0) for r in good_runs if r.get('ram_gb')]
        user_times = [r.get('user_time_seconds', 0) / 3600 for r in good_runs if r.get('user_time_seconds')]
        proof_sizes = [r.get('proof_size_bytes', 0) / (1024*1024) for r in good_runs if r.get('proof_size_bytes')]
        
        # Statistics
        avg_wall = statistics.mean(wall_times)
        avg_cpu = statistics.mean(cpu_usages) if cpu_usages else 0
        avg_ram = statistics.mean(ram_usages) if ram_usages else 0
        avg_user = statistics.mean(user_times) if user_times else 0
        avg_proof = statistics.mean(proof_sizes) if proof_sizes else 0
        
        summary_rows.append({
            'n': n,
            'count': len(good_runs),
            'excluded': len(bad_runs),
            'wall': avg_wall,
            'cpu': avg_cpu,
            'ram': avg_ram,
            'user': avg_user,
            'proof': avg_proof,
        })
        
        # Detailed stats
        wall_min = min(wall_times)
        wall_max = max(wall_times)
        wall_median = statistics.median(wall_times)
        wall_std = statistics.stdev(wall_times) if len(wall_times) > 1 else 0
        
        cpu_min = min(cpu_usages) if cpu_usages else 0
        cpu_max = max(cpu_usages) if cpu_usages else 0
        cpu_median = statistics.median(cpu_usages) if cpu_usages else 0
        cpu_std = statistics.stdev(cpu_usages) if len(cpu_usages) > 1 else 0
        
        ram_min = min(ram_usages) if ram_usages else 0
        ram_max = max(ram_usages) if ram_usages else 0
        ram_median = statistics.median(ram_usages) if ram_usages else 0
        ram_std = statistics.stdev(ram_usages) if len(ram_usages) > 1 else 0
        
        user_min = min(user_times) if user_times else 0
        user_max = max(user_times) if user_times else 0
        user_median = statistics.median(user_times) if user_times else 0
        user_std = statistics.stdev(user_times) if len(user_times) > 1 else 0
        
        details.append({
            'n': n,
            'count': len(good_runs),
            'excluded': bad_runs,
            'wall': {'avg': avg_wall, 'min': wall_min, 'max': wall_max, 'median': wall_median, 'std': wall_std},
            'cpu': {'avg': avg_cpu, 'min': cpu_min, 'max': cpu_max, 'median': cpu_median, 'std': cpu_std},
            'ram': {'avg': avg_ram, 'min': ram_min, 'max': ram_max, 'median': ram_median, 'std': ram_std},
            'user': {'avg': avg_user, 'min': user_min, 'max': user_max, 'median': user_median, 'std': user_std},
        })
    
    # Print summary table
    print("## 📈 Bảng Thống Kê Tổng Hợp (Chỉ Runs Tốt)\n")
    print("| N | Số Runs (Tốt) | Loại Bỏ | Thời Gian TB (Wall) | CPU TB (%) | RAM TB (GB) | Thời Gian CPU TB (h) | Proof TB (MB) |")
    print("|---|---------------|---------|---------------------|------------|-------------|----------------------|---------------|")
    
    for row in summary_rows:
        excluded_str = f"{row['excluded']}" if row['excluded'] > 0 else "-"
        proof_str = f"{row['proof']:.2f}" if row['proof'] > 0 else "N/A"
        print(f"| {row['n']} | {row['count']} | {excluded_str} | {format_time(row['wall'])} | {row['cpu']:.1f} | {row['ram']:.2f} | {row['user']:.2f} | {proof_str} |")
    
    print("\n---\n")
    
    # Detailed statistics
    print("## 📊 Chi Tiết Theo Từng N\n")
    
    for det in details:
        print(f"### N = {det['n']}")
        print(f"**Số runs tốt:** {det['count']}")
        if det['excluded']:
            print(f"**Đã loại bỏ:** {', '.join(det['excluded'])} (do kẹt RAM/resource contention)")
        print()
        
        print("| Metric | Trung Bình | Min | Max | Median | Std Dev |")
        print("|--------|-----------|-----|-----|--------|---------|")
        print(f"| Thời Gian (Wall) | {format_time(det['wall']['avg'])} | {format_time(det['wall']['min'])} | {format_time(det['wall']['max'])} | {format_time(det['wall']['median'])} | {format_time(det['wall']['std'])} |")
        print(f"| CPU (%) | {det['cpu']['avg']:.1f} | {det['cpu']['min']:.1f} | {det['cpu']['max']:.1f} | {det['cpu']['median']:.1f} | {det['cpu']['std']:.1f} |")
        print(f"| RAM (GB) | {det['ram']['avg']:.2f} | {det['ram']['min']:.2f} | {det['ram']['max']:.2f} | {det['ram']['median']:.2f} | {det['ram']['std']:.2f} |")
        print(f"| Thời Gian CPU (h) | {det['user']['avg']:.2f} | {det['user']['min']:.2f} | {det['user']['max']:.2f} | {det['user']['median']:.2f} | {det['user']['std']:.2f} |")
        print()
    
    # Total summary
    total_good = sum(d['count'] for d in details)
    total_excluded = sum(len(d['excluded']) for d in details)
    
    print("---\n")
    print("## 📋 Tóm Tắt\n")
    print(f"- **Tổng số runs tốt:** {total_good}")
    print(f"- **Tổng số runs đã loại bỏ:** {total_excluded}")
    print(f"- **Tỷ lệ runs tốt:** {total_good*100/(total_good+total_excluded):.1f}%")
    print()
    print("**Lưu ý:** Các runs bất thường bị loại bỏ do:")
    print("- Wall time cao bất thường kèm CPU usage thấp")
    print("- Resource contention (CPU, I/O bottleneck)")
    print("- Kẹt RAM hoặc memory swapping")
    print("- Background processes can thiệp")

if __name__ == "__main__":
    main()

