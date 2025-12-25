#!/usr/bin/env python3
"""
So sánh số liệu trung bình của 5 runs đầu vs 10 runs
"""
import re
import glob
import statistics
from pathlib import Path

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
        
    except Exception as e:
        pass
    
    return metrics

def main():
    log_dir = Path("logs/baseline_v5")
    n_values = [1, 10, 20, 50, 100, 200, 500, 700]
    
    print("# 📊 So Sánh 5 Runs Đầu vs 10 Runs (Trung Bình)\n")
    print("**Mục đích:** Kiểm tra xem số liệu trung bình 10 runs có tốt hơn (nhỏ hơn cho thời gian) so với 5 runs đầu không\n")
    print("---\n")
    
    results = []
    
    for n in n_values:
        pattern = str(log_dir / f"proof_ppgen_sabv_lmtr5_v5_{n}_*.no_input.log")
        log_files = sorted(glob.glob(pattern))
        
        if len(log_files) < 10:
            continue
        
        # Parse all runs
        all_metrics = {'wall_time': [], 'cpu': [], 'ram': [], 'user_time': []}
        
        for log_file in log_files:
            metrics = parse_log_file(log_file)
            if metrics.get('wall_time_seconds'):
                all_metrics['wall_time'].append(metrics['wall_time_seconds'])
            if metrics.get('cpu_percent'):
                all_metrics['cpu'].append(metrics['cpu_percent'])
            if metrics.get('ram_gb'):
                all_metrics['ram'].append(metrics['ram_gb'])
            if metrics.get('user_time_seconds'):
                all_metrics['user_time'].append(metrics['user_time_seconds'] / 3600)  # Convert to hours
        
        if len(all_metrics['wall_time']) >= 10:
            # 5 runs đầu
            wall_5 = all_metrics['wall_time'][:5]
            cpu_5 = all_metrics['cpu'][:5] if len(all_metrics['cpu']) >= 5 else []
            ram_5 = all_metrics['ram'][:5] if len(all_metrics['ram']) >= 5 else []
            user_5 = all_metrics['user_time'][:5] if len(all_metrics['user_time']) >= 5 else []
            
            # 10 runs
            wall_10 = all_metrics['wall_time'][:10]
            cpu_10 = all_metrics['cpu'][:10] if len(all_metrics['cpu']) >= 10 else []
            ram_10 = all_metrics['ram'][:10] if len(all_metrics['ram']) >= 10 else []
            user_10 = all_metrics['user_time'][:10] if len(all_metrics['user_time']) >= 10 else []
            
            # Calculate averages
            avg_wall_5 = statistics.mean(wall_5) if wall_5 else 0
            avg_wall_10 = statistics.mean(wall_10) if wall_10 else 0
            avg_cpu_5 = statistics.mean(cpu_5) if cpu_5 else 0
            avg_cpu_10 = statistics.mean(cpu_10) if cpu_10 else 0
            avg_ram_5 = statistics.mean(ram_5) if ram_5 else 0
            avg_ram_10 = statistics.mean(ram_10) if ram_10 else 0
            avg_user_5 = statistics.mean(user_5) if user_5 else 0
            avg_user_10 = statistics.mean(user_10) if user_10 else 0
            
            # Calculate difference
            diff_wall = avg_wall_10 - avg_wall_5
            diff_wall_pct = (diff_wall / avg_wall_5 * 100) if avg_wall_5 > 0 else 0
            diff_cpu = avg_cpu_10 - avg_cpu_5
            diff_cpu_pct = (diff_cpu / avg_cpu_5 * 100) if avg_cpu_5 > 0 else 0
            diff_ram = avg_ram_10 - avg_ram_5
            diff_ram_pct = (diff_ram / avg_ram_5 * 100) if avg_ram_5 > 0 else 0
            diff_user = avg_user_10 - avg_user_5
            diff_user_pct = (diff_user / avg_user_5 * 100) if avg_user_5 > 0 else 0
            
            results.append({
                'n': n,
                'wall_5': avg_wall_5,
                'wall_10': avg_wall_10,
                'diff_wall': diff_wall,
                'diff_wall_pct': diff_wall_pct,
                'cpu_5': avg_cpu_5,
                'cpu_10': avg_cpu_10,
                'diff_cpu': diff_cpu,
                'diff_cpu_pct': diff_cpu_pct,
                'ram_5': avg_ram_5,
                'ram_10': avg_ram_10,
                'diff_ram': diff_ram,
                'diff_ram_pct': diff_ram_pct,
                'user_5': avg_user_5,
                'user_10': avg_user_10,
                'diff_user': diff_user,
                'diff_user_pct': diff_user_pct,
            })
    
    # Print comparison table
    print("## So Sánh Wall Time (Thời Gian Thực Tế)\n")
    print("| N | 5 Runs TB | 10 Runs TB | Chênh Lệch | % Thay Đổi | Nhận Xét |")
    print("|---|-----------|------------|------------|------------|----------|")
    
    for r in results:
        wall_5_str = format_time(r['wall_5'])
        wall_10_str = format_time(r['wall_10'])
        diff_str = format_time(abs(r['diff_wall']))
        
        if r['diff_wall'] < 0:
            diff_str = f"-{diff_str}"
            comment = "✅ 10 runs NHỎ HƠN (tốt hơn)"
        elif r['diff_wall'] > 0:
            diff_str = f"+{diff_str}"
            comment = "⚠️ 10 runs LỚN HƠN (chậm hơn)"
        else:
            comment = "➖ Bằng nhau"
        
        pct_str = f"{r['diff_wall_pct']:+.1f}%"
        print(f"| {r['n']} | {wall_5_str} | {wall_10_str} | {diff_str} | {pct_str} | {comment} |")
    
    print("\n---\n")
    
    print("## So Sánh CPU Usage (%)\n")
    print("| N | 5 Runs TB | 10 Runs TB | Chênh Lệch | % Thay Đổi | Nhận Xét |")
    print("|---|-----------|------------|------------|------------|----------|")
    
    for r in results:
        if r['diff_cpu'] > 0:
            comment = "✅ 10 runs CAO HƠN (tốt hơn - parallelization tốt)"
        elif r['diff_cpu'] < 0:
            comment = "⚠️ 10 runs THẤP HƠN (kém hơn)"
        else:
            comment = "➖ Bằng nhau"
        
        pct_str = f"{r['diff_cpu_pct']:+.1f}%"
        print(f"| {r['n']} | {r['cpu_5']:.1f}% | {r['cpu_10']:.1f}% | {r['diff_cpu']:+.1f}% | {pct_str} | {comment} |")
    
    print("\n---\n")
    
    print("## So Sánh RAM Usage (GB)\n")
    print("| N | 5 Runs TB | 10 Runs TB | Chênh Lệch | % Thay Đổi |")
    print("|---|-----------|------------|------------|------------|")
    
    for r in results:
        pct_str = f"{r['diff_ram_pct']:+.1f}%"
        print(f"| {r['n']} | {r['ram_5']:.2f} | {r['ram_10']:.2f} | {r['diff_ram']:+.2f} | {pct_str} |")
    
    print("\n---\n")
    
    print("## So Sánh User Time (CPU Time, giờ)\n")
    print("| N | 5 Runs TB | 10 Runs TB | Chênh Lệch | % Thay Đổi |")
    print("|---|-----------|------------|------------|------------|")
    
    for r in results:
        pct_str = f"{r['diff_user_pct']:+.1f}%"
        print(f"| {r['n']} | {r['user_5']:.2f}h | {r['user_10']:.2f}h | {r['diff_user']:+.2f}h | {pct_str} |")
    
    print("\n---\n")
    
    # Summary
    print("## 📊 Tóm Tắt\n")
    
    better_wall = sum(1 for r in results if r['diff_wall'] < 0)
    worse_wall = sum(1 for r in results if r['diff_wall'] > 0)
    same_wall = sum(1 for r in results if r['diff_wall'] == 0)
    
    print(f"**Wall Time:**")
    print(f"- 10 runs NHỎ HƠN 5 runs: {better_wall}/8 N values (tốt hơn)")
    print(f"- 10 runs LỚN HƠN 5 runs: {worse_wall}/8 N values (chậm hơn)")
    print(f"- Bằng nhau: {same_wall}/8")
    
    better_cpu = sum(1 for r in results if r['diff_cpu'] > 0)
    worse_cpu = sum(1 for r in results if r['diff_cpu'] < 0)
    
    print(f"\n**CPU Usage:**")
    print(f"- 10 runs CAO HƠN 5 runs: {better_cpu}/8 N values (tốt hơn)")
    print(f"- 10 runs THẤP HƠN 5 runs: {worse_cpu}/8 N values (kém hơn)")
    
    print("\n### Kết Luận\n")
    
    avg_diff_wall_pct = statistics.mean([r['diff_wall_pct'] for r in results])
    
    if avg_diff_wall_pct < 0:
        print(f"✅ **Trung bình, 10 runs NHỎ HƠN 5 runs khoảng {abs(avg_diff_wall_pct):.1f}%**")
        print("   → Số liệu 10 runs TỐT HƠN (nhanh hơn) so với 5 runs đầu")
    elif avg_diff_wall_pct > 0:
        print(f"⚠️ **Trung bình, 10 runs LỚN HƠN 5 runs khoảng {avg_diff_wall_pct:.1f}%**")
        print("   → Số liệu 10 runs CHẬM HƠN so với 5 runs đầu")
    else:
        print("➖ **Số liệu 10 runs và 5 runs gần như bằng nhau**")
    
    print("\n**Giải thích:**")
    print("- Nếu 10 runs nhỏ hơn: Có thể 5 runs đầu có outliers chậm, 10 runs đã loại bỏ được")
    print("- Nếu 10 runs lớn hơn: Có thể 5 runs đầu may mắn chạy nhanh, 10 runs phản ánh đúng hơn")
    print("- Thông thường, 10 runs sẽ ổn định hơn và phản ánh performance thực tế tốt hơn")

if __name__ == "__main__":
    main()

