# 📊 Thống Kê Toàn Bộ L-MAPLE (LMTR/L-MAPLE) Experiments

*Cập nhật: 2025-12-25 01:39:34*

**Tổng số experiments:** 70

**Nguồn dữ liệu:** `logs/sabv_lmtr` và `logs/sabv4_lmtr4`

## 1. Tổng Quan

| Metric | Số Lượng | Tỷ Lệ |
|--------|----------|-------|
| Tổng experiments | 70 | 100% |
| Hoàn thành (Exit 0) | 13 | 18.6% |
| Thất bại | 55 | 78.6% |
| Chưa xác định | 2 | 2.9% |

## 2. Phân Bố Theo N Values

| N | Tổng Runs | Hoàn Thành | Thất Bại | Tỷ Lệ Thành Công |
|---|-----------|------------|----------|------------------|
| 1 | 38 | 7 | 30 | 18.4% |
| 5 | 6 | 1 | 4 | 16.7% |
| 10 | 5 | 1 | 4 | 20.0% |
| 20 | 5 | 1 | 4 | 20.0% |
| 50 | 6 | 2 | 4 | 33.3% |
| 100 | 5 | 1 | 4 | 20.0% |
| 1000 | 5 | 0 | 5 | 0.0% |

## 3. Chi Tiết Từng N Value

### N=1

**Tổng runs:** 38
**Hoàn thành:** 7
**Thất bại:** 31

**Thời gian chạy (Elapsed Time):**
- Trung bình: 1h02m24s
- Min: 23m39s
- Max: 1h29m38s
- Chênh lệch: 1h05m59s
- CV (Coefficient of Variation): 33.36%

**RAM Usage:**
- Trung bình: 14.97GB
- Min: 14.66GB
- Max: 15.29GB

**User Time (CPU Time):**
- Trung bình: 4.60h
- Min: 3.22h
- Max: 4.87h
- Tổng: 32.22h

**System Time:**
- Trung bình: 0.16h
- Min: 0.09h
- Max: 0.18h
- Tổng: 1.13h

**Chi tiết từng run (chỉ tính completed):**

| Run | Log File | Exit | Elapsed | RAM (GB) | User Time (h) | Sys Time (h) | L1 Verify |
|-----|----------|------|---------|----------|---------------|--------------|-----------|
| 1 | v4_n1_20251025_084358.log | 0 | 57:42 | 14.66 | 4.83h | 0.17h | N/A |
| 2 | v4_n1_20251025_094814.log | 0 | 1:00:05 | 14.71 | 4.83h | 0.18h | N/A |
| 3 | v4_n1_20251025_102528.log | 0 | 1:29:24 | 15.29 | 4.82h | 0.17h | N/A |
| 4 | v4_n1_20251025_132950.log | 0 | 58:38 | 15.14 | 4.84h | 0.17h | N/A |
| 5 | v4_n1_20251025_134706.log | 0 | 57:47 | 14.79 | 4.87h | 0.18h | N/A |
| 6 | v4_n1_20251025_141523.log | 0 | 1:29:38 | 14.98 | 4.81h | 0.16h | N/A |
| 7 | v4_n1_20251028_131710.log | 0 | 23:39 | 15.23 | 3.22h | 0.09h | N/A |

**Runs thất bại (30):**
- Exit code 101: 29 runs
- Exit code 127: 1 run

### N=5

**Tổng runs:** 6
**Hoàn thành:** 1
**Thất bại:** 5

**Thời gian chạy (Elapsed Time):**
- Trung bình: 1h35m52s

**RAM Usage:**
- Trung bình: 16.83GB

**User Time (CPU Time):**
- Trung bình: 5.56h

**System Time:**
- Trung bình: 0.19h

**Chi tiết từng run (chỉ tính completed):**

| Run | Log File | Exit | Elapsed | RAM (GB) | User Time (h) | Sys Time (h) | L1 Verify |
|-----|----------|------|---------|----------|---------------|--------------|-----------|
| 1 | proof_ppgen_sabv_lmtr_5.no_input.log | 0 | 1:35:52 | 16.83 | 5.56h | 0.19h | N/A |

**Runs thất bại (4):**
- Exit code 101: 4 runs

### N=10

**Tổng runs:** 5
**Hoàn thành:** 1
**Thất bại:** 4

**Thời gian chạy (Elapsed Time):**
- Trung bình: 1h17m49s

**RAM Usage:**
- Trung bình: 16.94GB

**User Time (CPU Time):**
- Trung bình: 6.99h

**System Time:**
- Trung bình: 0.26h

**Chi tiết từng run (chỉ tính completed):**

| Run | Log File | Exit | Elapsed | RAM (GB) | User Time (h) | Sys Time (h) | L1 Verify |
|-----|----------|------|---------|----------|---------------|--------------|-----------|
| 1 | proof_ppgen_sabv_lmtr_10.no_input.log | 0 | 1:17:49 | 16.94 | 6.99h | 0.26h | N/A |

**Runs thất bại (4):**
- Exit code 101: 4 runs

### N=20

**Tổng runs:** 5
**Hoàn thành:** 1
**Thất bại:** 4

**Thời gian chạy (Elapsed Time):**
- Trung bình: 1h38m38s

**RAM Usage:**
- Trung bình: 19.90GB

**User Time (CPU Time):**
- Trung bình: 9.34h

**System Time:**
- Trung bình: 0.36h

**Chi tiết từng run (chỉ tính completed):**

| Run | Log File | Exit | Elapsed | RAM (GB) | User Time (h) | Sys Time (h) | L1 Verify |
|-----|----------|------|---------|----------|---------------|--------------|-----------|
| 1 | proof_ppgen_sabv_lmtr_20.no_input.log | 0 | 1:38:38 | 19.90 | 9.34h | 0.36h | N/A |

**Runs thất bại (4):**
- Exit code 101: 4 runs

### N=50

**Tổng runs:** 6
**Hoàn thành:** 2
**Thất bại:** 4

**Thời gian chạy (Elapsed Time):**
- Trung bình: 4h28m30s
- Min: 2h43m02s
- Max: 6h13m59s
- Chênh lệch: 3h30m57s
- CV (Coefficient of Variation): 39.28%

**RAM Usage:**
- Trung bình: 20.39GB
- Min: 20.31GB
- Max: 20.48GB

**User Time (CPU Time):**
- Trung bình: 17.18h
- Min: 16.98h
- Max: 17.38h
- Tổng: 34.36h

**System Time:**
- Trung bình: 0.70h
- Min: 0.69h
- Max: 0.70h
- Tổng: 1.40h

**Chi tiết từng run (chỉ tính completed):**

| Run | Log File | Exit | Elapsed | RAM (GB) | User Time (h) | Sys Time (h) | L1 Verify |
|-----|----------|------|---------|----------|---------------|--------------|-----------|
| 1 | proof_ppgen_sabv_lmtr_50.no_input.log | 0 | 2:43:02 | 20.48 | 16.98h | 0.69h | N/A |
| 2 | proof_ppgen_sabv_lmtr_50.no_input.retry.log | 0 | 6:13:59 | 20.31 | 17.38h | 0.70h | N/A |

**Runs thất bại (4):**
- Exit code 101: 4 runs

### N=100

**Tổng runs:** 5
**Hoàn thành:** 1
**Thất bại:** 4

**Thời gian chạy (Elapsed Time):**
- Trung bình: 4h36m52s

**RAM Usage:**
- Trung bình: 20.32GB

**User Time (CPU Time):**
- Trung bình: 30.78h

**System Time:**
- Trung bình: 1.17h

**Chi tiết từng run (chỉ tính completed):**

| Run | Log File | Exit | Elapsed | RAM (GB) | User Time (h) | Sys Time (h) | L1 Verify |
|-----|----------|------|---------|----------|---------------|--------------|-----------|
| 1 | proof_ppgen_sabv_lmtr_100.no_input.log | 0 | 4:36:52 | 20.32 | 30.78h | 1.17h | N/A |

**Runs thất bại (4):**
- Exit code 101: 4 runs

### N=1000

**Tổng runs:** 5
**Hoàn thành:** 0
**Thất bại:** 5

⚠️  Không có runs nào hoàn thành thành công.

**Runs thất bại (5):**
- Exit code 101: 5 runs

## 4. Phân Tích Exit Codes

| Exit Code | Số Lượng | Mô Tả |
|-----------|----------|-------|
| 0 | 13 | Thành công |
| 101 | 54 | Có thể là lỗi hoặc chưa hoàn thành |
| 127 | 1 | Command not found hoặc lỗi khởi động |

## 5. Tổng Kết

### 5.1. Điểm Mạnh

- Có số liệu cho nhiều N values (1, 5, 10, 20, 50, 100, 1000)
- Một số runs thành công cho thấy LMTR có thể hoạt động
- Các runs thành công có performance ổn định
- Runs "no_input" có tỷ lệ thành công cao hơn

### 5.2. Điểm Yếu

- **Tỷ lệ thành công rất thấp:** Chỉ 18.6% (13/70) runs thành công
- **N=1000:** Không có run nào thành công (0/5)
- **Input files:** Nhiều runs với input files thất bại (exit code 101)
- **Thiếu L1 Verification:** Tất cả runs không có thông tin L1 verification
- **N=1 có biến động lớn:** CV = 33.36%, chênh lệch thời gian lên đến 1h05m59s

### 5.3. Phân Tích Chi Tiết

**Runs thành công (13 runs):**
- N=1: 7 runs (thời gian: 23m39s - 1h29m38s, RAM: 14.66-15.29GB)
- N=5: 1 run (1h35m52s, RAM: 16.83GB)
- N=10: 1 run (1h17m49s, RAM: 16.94GB)
- N=20: 1 run (1h38m38s, RAM: 19.90GB)
- N=50: 2 runs (2h43m02s - 6h13m59s, RAM: 20.31-20.48GB)
- N=100: 1 run (4h36m52s, RAM: 20.32GB)
- N=1000: 0 runs

**Runs thất bại (55 runs):**
- Exit code 101: 54 runs (77.1% tổng số)
- Exit code 127: 1 run (1.4%)
- Hầu hết là runs với input files

### 5.4. Khuyến Nghị

1. **Investigate nguyên nhân exit code 101:**
   - Kiểm tra log files chi tiết để tìm nguyên nhân
   - Có thể do thiếu dependencies, configuration issues, hoặc input files không tương thích
   - Cần phân tích chi tiết log files để xác định pattern

2. **Tập trung vào runs 'no_input':**
   - Tất cả runs thành công đều là "no_input"
   - Các runs với input files đều thất bại (exit code 101)
   - Khuyến nghị: Tạm thời chỉ chạy "no_input" hoặc fix input files

3. **Thêm runs để có dữ liệu đáng tin cậy hơn:**
   - Cần nhiều runs thành công hơn cho mỗi N value (đặc biệt N=5, 10, 20, 100)
   - N=1 đã có 7 runs thành công nhưng cần thêm để giảm biến động
   - N=50 cần thêm runs để có thống kê tốt hơn (hiện chỉ có 2 runs, CV cao 39.28%)

4. **Cải thiện L1 Verification:**
   - Tích hợp L1 verification vào pipeline
   - Đảm bảo tất cả runs có thông tin verification
   - Quan trọng để so sánh với Baseline và S-MAPLE trong AggSandbox

5. **So sánh với AggSandbox:**
   - L-MAPLE (LMTR) không nằm trong AggSandbox context
   - Nên chạy L-MAPLE trong AggSandbox context để có so sánh công bằng với Baseline và S-MAPLE


