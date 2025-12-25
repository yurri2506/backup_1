# 📊 Thống Kê S-MAPLE (V5) - Số Liệu Chính Thức (Standalone)

*Cập nhật: 2025-12-25*

## Ghi Chú

- **S-MAPLE (V5)**: SABV5 + LMTR4 (Secure Aggregated Block Verification + Local Merkle Tree Rebalancing)
- **Standalone**: Chạy ngoài AggSandbox context
- **Nguồn dữ liệu**: Từ `reports/BAO_CAO_V5_TONG_HOP.md` - Best runs standalone

## Bảng Số Liệu

| Batch Size N | Elapsed Time (min) | Elapsed Time | CPU (%) | CPU Utilization* | Max RAM (GB) |
|--------------|-------------------|--------------|---------|------------------|--------------|
| 1 | 47.6 | 47m34s | 895 | ~9.0x | 17.1 |
| 10 | 62.0 | 1h02m01s | 1012 | ~10.1x | 24.0 |
| 100 | 220.0 | 3h40m01s | 1193 | ~11.9x | 20.4 |
| 200 | 409.9 | 6h49m53s | 1230 | ~12.3x | 21.4 |
| 500 | 948.1 | 15h48m09s | 1265 | ~12.7x | 22.5 |
| 700 | 1303.2 | 21h43m11s | 1255 | ~12.6x | 22.7 |

*CPU Utilization = CPU% / 100 (cho thấy số cores được sử dụng hiệu quả)

## 1. Phân Tích Elapsed Time (Thời Gian Thực Tế)

### 1.1. Thời Gian Theo N

Thời gian thực tế để hoàn thành một batch:

| N | Elapsed Time | Giờ |
|---|--------------|-----|
| 1 | 47m34s | 0.79h |
| 10 | 1h02m01s | 1.03h |
| 100 | 3h40m01s | 3.67h |
| 200 | 6h49m53s | 6.83h |
| 500 | 15h48m09s | 15.80h |
| 700 | 21h43m11s | 21.72h |

### 1.2. Scaling Analysis

**Tỷ lệ so với N=1:**

| N | Time Ratio | Time per Exit* |
|---|------------|----------------|
| 1 | 1.0x | 47.6 min |
| 10 | 1.3x | 6.2 min |
| 100 | 4.6x | 2.2 min |
| 200 | 8.6x | 2.0 min |
| 500 | 19.9x | 1.9 min |
| 700 | 27.4x | 1.9 min |

*Time per Exit = Elapsed Time / N (thời gian trung bình cho mỗi exit)

**Nhận xét:**
- Time per exit giảm khi N tăng (từ 47.6 min cho N=1 xuống ~1.9 min cho N lớn)
- Hiệu quả parallelization tăng khi batch size tăng
- N=500 và N=700 có time per exit ổn định khoảng 1.9 min

## 2. Phân Tích CPU Utilization

### 2.1. CPU Usage

CPU utilization tăng dần khi N tăng:

| N | CPU (%) | Cores (ước tính) | Increase vs N=1 |
|---|---------|------------------|-----------------|
| 1 | 895 | ~9.0 | Baseline |
| 10 | 1012 | ~10.1 | +13.1% |
| 100 | 1193 | ~11.9 | +33.3% |
| 200 | 1230 | ~12.3 | +37.4% |
| 500 | 1265 | ~12.7 | +41.3% |
| 700 | 1255 | ~12.6 | +40.2% |

**Nhận xét:**
- CPU utilization tăng từ ~9.0 cores (N=1) lên ~12.7 cores (N=500)
- N=500 và N=700 có CPU utilization gần nhau (~1255-1265%), cho thấy đã đạt giới hạn parallelization

## 3. Phân Tích RAM Usage

### 3.1. RAM Usage by N

| N | Max RAM (GB) | RAM per Exit (MB)* |
|---|--------------|-------------------|
| 1 | 17.1 | 17,100 |
| 10 | 24.0 | 2,400 |
| 100 | 20.4 | 204 |
| 200 | 21.4 | 107 |
| 500 | 22.5 | 45 |
| 700 | 22.7 | 32 |

*RAM per Exit = Max RAM / N

**Nhận xét:**
- RAM tăng từ 17.1GB (N=1) lên 22.7GB (N=700) - tăng 33%
- RAM per exit giảm từ 17.1GB/exit xuống 32MB/exit (hiệu quả hơn ~534x)
- N=10 có RAM cao nhất (24.0GB) - có thể do preprocessing overhead
- RAM ổn định ở ~20-23GB cho N ≥ 100

## 4. Chi Tiết Từng Best Run

### N=1
- **Elapsed:** 47m34s (0.79h)
- **CPU:** 895% (~9.0 cores)
- **RAM:** 17.1GB
- **File:** v5_n1_run4_20251111_222449.log

### N=10
- **Elapsed:** 1h02m01s (1.03h)
- **CPU:** 1012% (~10.1 cores)
- **RAM:** 24.0GB
- **File:** v5_n10_run3_20251111_211038.log

### N=100
- **Elapsed:** 3h40m01s (3.67h)
- **CPU:** 1193% (~11.9 cores)
- **RAM:** 20.4GB
- **Config:** RAYON_NUM_THREADS=8 (baseline optimal)
- **Note:** Best run với optimal configuration

### N=200
- **Elapsed:** 6h49m53s (6.83h)
- **CPU:** 1230% (~12.3 cores)
- **RAM:** 21.4GB
- **File:** v5_n200_run1_20251112_151812.log

### N=500
- **Elapsed:** 15h48m09s (15.80h)
- **CPU:** 1265% (~12.7 cores)
- **RAM:** 22.5GB
- **File:** v5_n500_run1_20251112_220808.log

### N=700
- **Elapsed:** 21h43m11s (21.72h)
- **CPU:** 1255% (~12.6 cores)
- **RAM:** 22.7GB
- **File:** v5_n700_run1_20251113_135619.log

## 5. Tổng Hợp Performance

### 5.1. Key Metrics Summary

**Thời gian (Elapsed Time):**
- N=1: 47.6 min (0.79h)
- N=700: 1303.2 min (21.72h) - gấp 27.4 lần

**CPU Utilization:**
- N=1: 895% (~9.0 cores)
- N=500: 1265% (~12.7 cores) - tăng 41%

**RAM:**
- N=1: 17.1GB
- N=700: 22.7GB - tăng 33%

### 5.2. Efficiency Metrics

**Time Efficiency (Time per Exit):**
- N=1: 47.6 min/exit
- N≥500: ~1.9 min/exit (hiệu quả hơn ~25x)

**RAM Efficiency (RAM per Exit):**
- N=1: 17.1GB/exit
- N=700: 32MB/exit (hiệu quả hơn ~534x)

**CPU Efficiency:**
- N=1: 9.0 cores
- N=500: 12.7 cores (sử dụng thêm 41% cores)

### 5.3. Optimal Batch Size

Dựa trên số liệu:

**Cho thời gian tối thiểu per exit:**
- Optimal: N ≥ 500 (time per exit ~1.9 min)

**Cho resource utilization:**
- CPU: N ≥ 200 (đạt ~12 cores)
- RAM: N ≥ 100 (ổn định ở ~20-23GB)

**Kết luận:** N=500-700 là optimal cho S-MAPLE, cân bằng tốt giữa:
- Time efficiency (1.9 min/exit)
- CPU utilization (12.5-12.7 cores)
- RAM stability (22.5-22.7GB)

