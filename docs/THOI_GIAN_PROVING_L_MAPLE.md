# ⏱️ Thời Gian Proving Của L-MAPLE (LMTR/L-MAPLE)

*Cập nhật: 2025-12-25 13:07:36*

## Ghi Chú Quan Trọng

- **Proving Time**: Trong L-MAPLE, proving time được đo bằng **User Time (CPU Time)** - đây là tổng thời gian CPU được sử dụng cho quá trình proving. 
- **Elapsed Time**: Tổng thời gian wall clock (thời gian thực tế từ lúc bắt đầu đến kết thúc)
- **System Time**: Thời gian system calls
- **Lưu ý**: User Time có thể lớn hơn Elapsed Time khi chạy đa lõi (parallel processing), vì User Time là tổng của tất cả các cores.
- Tất cả thời gian được tính từ các runs thành công (Exit code 0)

## 1. Tổng Quan

**Tổng số runs thành công:** 13

## 2. So Sánh Thời Gian

| N | Runs | Elapsed Time (TB) | Proving Time / User Time (TB) | System Time (TB) | CPU Utilization* |
|---|------|-------------------|--------------------------------|------------------|-------------------|
| 1 | 7 | 1h02m24s | 4h36m11s | 9m39s | ~4.4x |
| 5 | 1 | 1h35m52s | 5h33m45s | 11m35s | ~3.5x |
| 10 | 1 | 1h17m49s | 6h59m09s | 15m19s | ~5.4x |
| 20 | 1 | 1h38m38s | 9h20m29s | 21m50s | ~5.7x |
| 50 | 2 | 4h28m30s | 17h10m41s | 41m51s | ~3.8x |
| 100 | 1 | 4h36m52s | 30h46m53s | 1h10m23s | ~6.7x |

*CPU Utilization = User Time / Elapsed Time (tỷ lệ này > 1 cho thấy đang sử dụng nhiều cores song song)

## 3. Chi Tiết Từng N Value

### N=1

**Số runs:** 7

**Proving Time (User Time / CPU Time):**
- Trung bình: **4h36m11s**
- Min: 3h13m08s
- Max: 4h52m08s
- Chênh lệch: 1h39m00s
- CV (Coefficient of Variation): 12.28%

**Elapsed Time (Wall Clock - Thời gian thực tế):**
- Trung bình: **1h02m24s**
- Min: 23m39s
- Max: 1h29m38s

**CPU Utilization:** Trung bình ~4.4 cores được sử dụng song song

**Chi tiết từng run:**

| Run | Log File | Elapsed Time | Proving Time (User) | System Time |
|-----|----------|--------------|---------------------|-------------|
| 1 | v4_n1_20251025_084358.log | 57m42s | 4h49m47s | 10m25s |
| 2 | v4_n1_20251025_094814.log | 1h00m05s | 4h49m59s | 10m44s |
| 3 | v4_n1_20251025_102528.log | 1h29m24s | 4h49m20s | 10m02s |
| 4 | v4_n1_20251025_132950.log | 58m38s | 4h50m28s | 10m29s |
| 5 | v4_n1_20251025_134706.log | 57m47s | 4h52m08s | 10m47s |
| 6 | v4_n1_20251025_141523.log | 1h29m38s | 4h48m26s | 9m40s |
| 7 | v4_n1_20251028_131710.log | 23m39s | 3h13m08s | 5m25s |

### N=5

**Số runs:** 1

**Proving Time (User Time / CPU Time):**
- Trung bình: **5h33m45s**

**Elapsed Time (Wall Clock):**
- Trung bình: **1h35m52s**

**CPU Utilization:** ~3.5 cores

**Chi tiết từng run:**

| Run | Log File | Elapsed Time | Proving Time (User) | System Time |
|-----|----------|--------------|---------------------|-------------|
| 1 | proof_ppgen_sabv_lmtr_5.no_input.log | 1h35m52s | 5h33m45s | 11m35s |

### N=10

**Số runs:** 1

**Proving Time (User Time / CPU Time):**
- Trung bình: **6h59m09s**

**Elapsed Time (Wall Clock):**
- Trung bình: **1h17m49s**

**CPU Utilization:** ~5.4 cores

**Chi tiết từng run:**

| Run | Log File | Elapsed Time | Proving Time (User) | System Time |
|-----|----------|--------------|---------------------|-------------|
| 1 | proof_ppgen_sabv_lmtr_10.no_input.log | 1h17m49s | 6h59m09s | 15m19s |

### N=20

**Số runs:** 1

**Proving Time (User Time / CPU Time):**
- Trung bình: **9h20m29s**

**Elapsed Time (Wall Clock):**
- Trung bình: **1h38m38s**

**CPU Utilization:** ~5.7 cores

**Chi tiết từng run:**

| Run | Log File | Elapsed Time | Proving Time (User) | System Time |
|-----|----------|--------------|---------------------|-------------|
| 1 | proof_ppgen_sabv_lmtr_20.no_input.log | 1h38m38s | 9h20m29s | 21m50s |

### N=50

**Số runs:** 2

**Proving Time (User Time / CPU Time):**
- Trung bình: **17h10m41s**
- Min: 16h58m41s
- Max: 17h22m41s
- Chênh lệch: 23m59s
- CV (Coefficient of Variation): 1.16% (rất ổn định)

**Elapsed Time (Wall Clock):**
- Trung bình: **4h28m30s**
- Min: 2h43m02s
- Max: 6h13m59s

**CPU Utilization:** Trung bình ~3.8 cores

**Chi tiết từng run:**

| Run | Log File | Elapsed Time | Proving Time (User) | System Time |
|-----|----------|--------------|---------------------|-------------|
| 1 | proof_ppgen_sabv_lmtr_50.no_input.log | 2h43m02s | 16h58m41s | 41m35s |
| 2 | proof_ppgen_sabv_lmtr_50.no_input.retry.log | 6h13m59s | 17h22m41s | 42m07s |

### N=100

**Số runs:** 1

**Proving Time (User Time / CPU Time):**
- Trung bình: **30h46m53s**

**Elapsed Time (Wall Clock):**
- Trung bình: **4h36m52s**

**CPU Utilization:** ~6.7 cores

**Chi tiết từng run:**

| Run | Log File | Elapsed Time | Proving Time (User) | System Time |
|-----|----------|--------------|---------------------|-------------|
| 1 | proof_ppgen_sabv_lmtr_100.no_input.log | 4h36m52s | 30h46m53s | 1h10m23s |

## 4. Phân Tích

### 4.1. Thời Gian Thực Tế (Elapsed Time)

Thời gian thực tế để hoàn thành một run L-MAPLE:

| N | Elapsed Time (Trung Bình) |
|---|---------------------------|
| 1 | ~1h02m |
| 5 | ~1h36m |
| 10 | ~1h18m |
| 20 | ~1h39m |
| 50 | ~4h28m |
| 100 | ~4h37m |

**Nhận xét:**
- N=1 đến N=20: Thời gian tăng chậm (từ 1h đến 1h39m)
- N=50 và N=100: Thời gian tăng đáng kể (lên 4h+)
- Có vẻ như có parallelization tốt cho N nhỏ, nhưng hiệu quả giảm khi N lớn

### 4.2. Tổng CPU Time (User Time) - Proving Time

Tổng thời gian CPU được sử dụng (proving time):

| N | Proving Time (Trung Bình) | Scaling Factor* |
|---|---------------------------|-----------------|
| 1 | 4.6h | 1.0x |
| 5 | 5.6h | 1.2x |
| 10 | 7.0h | 1.5x |
| 20 | 9.3h | 2.0x |
| 50 | 17.2h | 3.7x |
| 100 | 30.8h | 6.7x |

*Scaling Factor so với N=1

**Nhận xét:**
- Proving time tăng gần như tuyến tính với N
- N=100 cần ~6.7x thời gian của N=1
- Scaling khá tốt, không có exponential growth

### 4.3. CPU Utilization (Parallelization)

Tỷ lệ User Time / Elapsed Time cho thấy mức độ parallelization:

| N | CPU Utilization | Số Cores Ước Tính |
|---|-----------------|-------------------|
| 1 | ~4.4x | ~4-5 cores |
| 5 | ~3.5x | ~3-4 cores |
| 10 | ~5.4x | ~5-6 cores |
| 20 | ~5.7x | ~5-6 cores |
| 50 | ~3.8x | ~4 cores |
| 100 | ~6.7x | ~6-7 cores |

**Nhận xét:**
- L-MAPLE sử dụng khoảng 3-7 cores song song
- N=100 có utilization cao nhất (~6.7x)
- N=5 và N=50 có utilization thấp hơn (có thể do I/O wait hoặc không tối ưu)

### 4.4. So Sánh Elapsed Time vs Proving Time

**Thời gian thực tế (Elapsed) cho user:**
- N=1: ~1 giờ
- N=100: ~4.5 giờ

**Tổng công việc CPU (User Time):**
- N=1: ~4.6 giờ CPU
- N=100: ~30.8 giờ CPU

### 4.5. Độ Ổn Định (Stability)

- **N=1**: CV = 12.28% (khá ổn định trong 7 runs)
- **N=50**: CV = 1.16% (rất ổn định trong 2 runs)
- **N=5, 10, 20, 100**: Chỉ có 1 run nên không thể đánh giá

## 5. Kết Luận

### 5.1. Thời Gian Proving (User Time)

Proving time của L-MAPLE tăng gần như tuyến tính với N:
- **N=1**: ~4.6h
- **N=100**: ~30.8h (gấp 6.7 lần)

### 5.2. Thời Gian Thực Tế (Elapsed Time)

Thời gian thực tế để hoàn thành:
- **N=1**: ~1h
- **N=100**: ~4.5h

Nhờ parallelization, thời gian thực tế ngắn hơn nhiều so với tổng CPU time.

### 5.3. Hiệu Quả Parallelization

L-MAPLE sử dụng khoảng 3-7 cores song song, với utilization tốt nhất ở N=100 (~6.7x).

