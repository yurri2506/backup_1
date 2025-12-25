#!/usr/bin/env python3
"""Calculate remaining time for MAPLE runs"""

# Thời gian trung bình mỗi run (từ dữ liệu thực tế)
avg_times = {
    1: 4.19,    # giờ/run
    10: 4.65,
    20: 10.64,
    50: 4.23,
    100: 4.40,
    200: 8.02,
    500: 20.03,
    700: 26.36,
}

# Số runs đã hoàn thành
completed = {
    1: 10,
    10: 10,
    20: 6,   # Đang chạy run 6
    50: 5,
    100: 5,
    200: 5,
    500: 5,
    700: 5,
}

from datetime import datetime, timedelta

print("=" * 70)
print("📊 ƯỚC TÍNH THỜI GIAN CÒN LẠI ĐỂ CHẠY ĐỦ 10 LẦN")
print("=" * 70)
print()

total_hours = 0

for N in sorted(avg_times.keys()):
    avg = avg_times[N]
    comp = completed[N]
    remaining_count = 10 - comp
    
    if N == 20 and comp == 6:
        # Run hiện tại đã chạy ~4.5 giờ
        current_elapsed = 4.5
        current_remaining = max(0, avg - current_elapsed)
        # Cần: hoàn thành run hiện tại + 3 runs mới (7, 8, 9, 10)
        total_n_hours = current_remaining + (avg * 3)
        print(f"⏳ N={N:3d}:")
        print(f"   • Trung bình: {avg:.2f} giờ/run")
        print(f"   • Đã hoàn thành: {comp}/10 runs")
        print(f"   • Run hiện tại: đã chạy ~4.5 giờ, còn ~{current_remaining:.2f} giờ")
        print(f"   • Cần thêm: 4 runs (hoàn thành run hiện tại + 3 runs mới)")
        print(f"   • Ước tính: {total_n_hours:.2f} giờ")
    else:
        total_n_hours = avg * remaining_count
        icon = "✅" if remaining_count == 0 else "⏳"
        print(f"{icon} N={N:3d}:")
        print(f"   • Trung bình: {avg:.2f} giờ/run")
        print(f"   • Đã hoàn thành: {comp}/10 runs")
        print(f"   • Cần thêm: {remaining_count} runs")
        print(f"   • Ước tính: {total_n_hours:.2f} giờ")
    
    total_hours += total_n_hours
    print()

print("=" * 70)
total_days = total_hours / 24
print(f"⏱️  TỔNG THỜI GIAN CÒN LẠI: {total_hours:.2f} giờ = {total_days:.2f} ngày")
print()

now = datetime.now()
completion = now + timedelta(hours=total_hours)
print(f"🕐 Thời gian hiện tại: {now.strftime('%Y-%m-%d %H:%M:%S')}")
print(f"🎯 Dự kiến hoàn thành: {completion.strftime('%Y-%m-%d %H:%M:%S')}")
print()

if total_days >= 1:
    weeks = total_days / 7
    print(f"📅 Khoảng {int(total_days)} ngày ({weeks:.1f} tuần)")
print()

print("=" * 70)
print("📝 LƯU Ý:")
print("  • N=500 và N=700 mất nhiều thời gian nhất (~20-26 giờ/run)")
print("  • Thời gian có thể thay đổi tùy theo tải hệ thống")
print("  • Script đang chạy trong tmux session: baseline_ppgen_MAPLE_fill_10runs")
print("=" * 70)










