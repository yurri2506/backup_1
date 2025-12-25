# 📊 Thống Kê L-MAPLE (LMTR/L-MAPLE) - Số Liệu Chính Thức

*Cập nhật: 2025-12-25*

## Bảng Số Liệu

| Batch Size N | Elapsed Time (min) | Elapsed Time | CPU (%) | CPU Utilization* | Max RAM (GB) |
|--------------|-------------------|--------------|---------|------------------|--------------|
| 1 | 23.7 | 23m42s | 839 | ~8.4x | 15.2 |
| 10 | 38.8 | 38m48s | 901 | ~9.0x | 16.9 |
| 20 | 53.2 | 53m12s | 979 | ~9.8x | 19.7 |
| 50 | 96.5 | 1h36m30s | 1064 | ~10.6x | 20.3 |
| 100 | 161.7 | 2h41m42s | 1128 | ~11.3x | 20.2 |
| 200 | 407.7 | 6h47m42s | 1215 | ~12.2x | 21.3 |
| 500 | 976.0 | 16h16m00s | 1254 | ~12.5x | 22.4 |
| 700 | 1325.0 | 22h05m00s | 1258 | ~12.6x | 22.4 |

*CPU Utilization = CPU% / 100 (cho thấy số cores được sử dụng hiệu quả)

## 1. Phân Tích Elapsed Time (Thời Gian Thực Tế)

### 1.1. Thời Gian Theo N

Thời gian thực tế để hoàn thành một batch:

| N | Elapsed Time | Giờ |
|---|--------------|-----|
| 1 | 23m42s | 0.40h |
| 10 | 38m48s | 0.65h |
| 20 | 53m12s | 0.89h |
| 50 | 1h36m30s | 1.61h |
| 100 | 2h41m42s | 2.70h |
| 200 | 6h47m42s | 6.80h |
| 500 | 16h16m00s | 16.27h |
| 700 | 22h05m00s | 22.08h |

### 1.2. Scaling Analysis

**Tỷ lệ so với N=1:**

| N | Time Ratio | Time per Exit* |
|---|------------|----------------|
| 1 | 1.0x | 23.7 min |
| 10 | 1.6x | 3.9 min |
| 20 | 2.2x | 2.7 min |
| 50 | 4.1x | 1.9 min |
| 100 | 6.8x | 1.6 min |
| 200 | 17.2x | 2.0 min |
| 500 | 41.2x | 2.0 min |
| 700 | 55.9x | 1.9 min |

*Time per Exit = Elapsed Time / N (thời gian trung bình cho mỗi exit)

**Nhận xét:**
- Time per exit giảm khi N tăng (từ 23.7 min cho N=1 xuống ~2 min cho N lớn)
- Hiệu quả parallelization tăng khi batch size tăng
- N=200 trở lên có time per exit ổn định khoảng 1.9-2.0 min

### 1.3. Growth Rate

**Tăng trưởng tuyến tính:**

| N Range | Avg Time per Exit | Growth |
|---------|-------------------|--------|
| 1-10 | 3.8 min | - |
| 10-20 | 3.3 min | -13% |
| 20-50 | 1.9 min | -42% |
| 50-100 | 1.6 min | -16% |
| 100-200 | 2.0 min | +25% |
| 200-500 | 2.0 min | 0% |
| 500-700 | 1.9 min | -5% |

Time per exit ổn định ở khoảng 1.9-2.0 min cho N ≥ 50.

## 2. Phân Tích CPU Utilization

### 2.1. CPU Usage

CPU utilization tăng dần khi N tăng:

| N | CPU (%) | Cores (ước tính) | Efficiency* |
|---|---------|------------------|-------------|
| 1 | 839 | ~8.4 | Baseline |
| 10 | 901 | ~9.0 | +7.4% |
| 20 | 979 | ~9.8 | +16.7% |
| 50 | 1064 | ~10.6 | +26.8% |
| 100 | 1128 | ~11.3 | +34.4% |
| 200 | 1215 | ~12.2 | +44.8% |
| 500 | 1254 | ~12.5 | +49.5% |
| 700 | 1258 | ~12.6 | +49.9% |

*Efficiency so với N=1

**Nhận xét:**
- CPU utilization tăng từ ~8.4 cores (N=1) lên ~12.6 cores (N=700)
- Có vẻ như hệ thống có ~12-13 cores và được sử dụng tốt hơn khi batch size tăng
- N=500 và N=700 có CPU utilization gần nhau (~1254-1258%), cho thấy đã đạt giới hạn parallelization

### 2.2. CPU Efficiency vs Batch Size

Khi N tăng, hệ thống sử dụng nhiều cores hơn và hiệu quả hơn:
- N=1: Sử dụng 8.4 cores
- N=700: Sử dụng 12.6 cores (tăng 50% so với N=1)

## 3. Phân Tích RAM Usage

### 3.1. RAM Usage by N

| N | Max RAM (GB) | RAM per Exit (MB)* |
|---|--------------|-------------------|
| 1 | 15.2 | 15,200 |
| 10 | 16.9 | 1,690 |
| 20 | 19.7 | 985 |
| 50 | 20.3 | 406 |
| 100 | 20.2 | 202 |
| 200 | 21.3 | 107 |
| 500 | 22.4 | 45 |
| 700 | 22.4 | 32 |

*RAM per Exit = Max RAM / N

**Nhận xét:**
- RAM tổng tăng chậm: từ 15.2GB (N=1) lên 22.4GB (N=700) - chỉ tăng 47%
- RAM per exit giảm nhanh khi N tăng (từ 15GB/exit xuống 32MB/exit)
- RAM ổn định ở ~22.4GB cho N ≥ 500
- Cho thấy L-MAPLE có memory efficiency tốt khi batch size tăng

### 3.2. RAM Scaling

**RAM growth:**
- N=1 → N=10: +11% (16.9/15.2)
- N=10 → N=20: +17% (19.7/16.9)
- N=20 → N=50: +3% (20.3/19.7)
- N=50 → N=100: -0.5% (20.2/20.3) - giảm nhẹ
- N=100 → N=200: +5% (21.3/20.2)
- N=200 → N=500: +5% (22.4/21.3)
- N=500 → N=700: 0% (22.4/22.4) - ổn định

RAM growth chậm và ổn định, không tăng tuyến tính với N.

## 4. Tổng Hợp Performance

### 4.1. Key Metrics Summary

**Thời gian (Elapsed Time):**
- N=1: 23.7 min (0.40h)
- N=700: 1325.0 min (22.08h) - gấp 55.9 lần

**CPU Utilization:**
- N=1: 839% (~8.4 cores)
- N=700: 1258% (~12.6 cores) - tăng 50%

**RAM:**
- N=1: 15.2GB
- N=700: 22.4GB - tăng 47%

### 4.2. Efficiency Metrics

**Time Efficiency (Time per Exit):**
- N=1: 23.7 min/exit
- N≥50: ~1.9-2.0 min/exit (hiệu quả hơn ~12x)

**RAM Efficiency (RAM per Exit):**
- N=1: 15.2GB/exit
- N=700: 32MB/exit (hiệu quả hơn ~475x)

**CPU Efficiency:**
- N=1: 8.4 cores
- N=700: 12.6 cores (sử dụng thêm 50% cores)

### 4.3. Optimal Batch Size

Dựa trên số liệu:

**Cho thời gian tối thiểu per exit:**
- Optimal: N ≥ 50 (time per exit ~1.9-2.0 min)
- N=700 có time per exit tốt nhất (1.9 min)

**Cho resource utilization:**
- CPU: N ≥ 200 (đạt ~12 cores)
- RAM: N ≥ 500 (ổn định ở 22.4GB)

**Kết luận:** N=500-700 là optimal cho L-MAPLE, cân bằng tốt giữa:
- Time efficiency (1.9-2.0 min/exit)
- CPU utilization (12.5-12.6 cores)
- RAM stability (22.4GB)

## 5. So Sánh với Số Liệu Cũ (Từ Log Files)

### 5.1. Elapsed Time Comparison

| N | Số Liệu Chính Thức | Số Liệu Từ Logs* | Chênh Lệch |
|---|-------------------|------------------|------------|
| 1 | 23m42s | 1h02m24s (TB) | -62% |
| 10 | 38m48s | 1h17m49s | -50% |
| 20 | 53m12s | 1h38m38s | -46% |
| 50 | 1h36m30s | 4h28m30s (TB) | -64% |
| 100 | 2h41m42s | 4h36m52s | -41% |

*Số liệu từ logs/sabv_lmtr và logs/sabv4_lmtr4

**Nhận xét:**
- Số liệu chính thức nhanh hơn đáng kể (nhanh hơn 40-64%)
- Có thể do:
  - Optimization cải thiện performance
  - Khác biệt hardware/config
  - Số liệu chính thức được đo trong điều kiện tối ưu hơn

### 5.2. RAM Comparison

| N | Số Liệu Chính Thức | Số Liệu Từ Logs* | Chênh Lệch |
|---|-------------------|------------------|------------|
| 1 | 15.2GB | 14.97GB (TB) | +1.5% |
| 10 | 16.9GB | 16.94GB | -0.2% |
| 20 | 19.7GB | 19.90GB | -1.0% |
| 50 | 20.3GB | 20.39GB (TB) | -0.4% |
| 100 | 20.2GB | 20.32GB | -0.1% |

*Số liệu từ logs

**Nhận xét:**
- RAM usage gần như giống nhau (chênh lệch <2%)
- RAM ổn định và nhất quán giữa các measurement

## 6. Kết Luận

### 6.1. Performance Highlights

1. **Thời gian (Elapsed Time):**
   - N=1: 23.7 min
   - N=700: 22.08h
   - Time per exit giảm từ 23.7 min → 1.9 min khi N tăng

2. **CPU Utilization:**
   - Tăng từ 8.4 cores (N=1) → 12.6 cores (N=700)
   - Đạt hiệu quả parallelization tốt với batch size lớn

3. **RAM:**
   - Chỉ tăng 47% khi N tăng từ 1 → 700
   - RAM per exit giảm từ 15.2GB → 32MB (hiệu quả hơn 475x)

### 6.2. Scaling Characteristics

- **Sub-linear time scaling:** Time không tăng tuyến tính với N
- **Linear CPU scaling:** CPU utilization tăng gần tuyến tính
- **Sub-linear RAM scaling:** RAM tăng chậm hơn N

### 6.3. Recommendations

- **Batch size tối ưu:** N=500-700 cho best performance
- **Resource requirements:**
  - CPU: ~12-13 cores recommended
  - RAM: ~22-23GB recommended
  - Time: ~16-22h cho N=500-700

