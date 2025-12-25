# 🔍 PHÂN TÍCH CÁC RUNS MAPLE THIẾU SỐ LIỆU VÀ BẤT THƯỜNG

**Ngày phân tích:** 2025-12-18

---

## N = 1

**Tổng số runs:** 10

### ✅ Tất Cả Runs Đều Có Đầy Đủ Metrics

### ✅ Không Có Runs Bất Thường

---

## N = 10

**Tổng số runs:** 10

### ✅ Tất Cả Runs Đều Có Đầy Đủ Metrics

### ⚠️ Runs Có Số Liệu Bất Thường

| Run | Vấn Đề | Giá Trị | Giá Trị TB | Phân Tích |
|-----|--------|---------|------------|-----------|
| proof_ppgen_sabv_lmtr5_MAPLE_10_extra6.no_input | RAM: 17.82 GB (z-score: 2.68, high) | Wall: 7:40:07<br>CPU: 157.0%<br>RAM: 17.82 GB | Wall: 4:39:16<br>CPU: 481.6%<br>RAM: 17.02 GB | ⚠️ Wall time cao + CPU thấp → Có thể do:<br>- System load cao (CPU contention)<br>- I/O bottleneck (disk đọc/ghi chậm)<br>- Memory swapping<br>- Background processes can thiệp |

---

## N = 20

**Tổng số runs:** 10

### ✅ Tất Cả Runs Đều Có Đầy Đủ Metrics

### ⚠️ Runs Có Số Liệu Bất Thường

| Run | Vấn Đề | Giá Trị | Giá Trị TB | Phân Tích |
|-----|--------|---------|------------|-----------|
| proof_ppgen_sabv_lmtr5_MAPLE_20_extra2.no_input | User Time: 15.32h (z-score: 1.85, low) | Wall: 10:18:19<br>CPU: 153.0%<br>RAM: 19.85 GB | Wall: 10:41:23<br>CPU: 152.7%<br>RAM: 19.71 GB | Cần kiểm tra thêm |
| proof_ppgen_sabv_lmtr5_MAPLE_20_extra7.no_input | CPU: 168.0% (z-score: 1.87, high)<br>User Time: 16.13h (z-score: 1.55, high) | Wall: 9:54:16<br>CPU: 168.0%<br>RAM: 19.78 GB | Wall: 10:41:23<br>CPU: 152.7%<br>RAM: 19.71 GB | Cần kiểm tra thêm |
| proof_ppgen_sabv_lmtr5_MAPLE_20_extra8.no_input | RAM: 19.03 GB (z-score: 2.74, low) | Wall: 11:17:41<br>CPU: 146.0%<br>RAM: 19.03 GB | Wall: 10:41:23<br>CPU: 152.7%<br>RAM: 19.71 GB | Cần kiểm tra thêm |

---

## N = 50

**Tổng số runs:** 10

### ✅ Tất Cả Runs Đều Có Đầy Đủ Metrics

### ⚠️ Runs Có Số Liệu Bất Thường

| Run | Vấn Đề | Giá Trị | Giá Trị TB | Phân Tích |
|-----|--------|---------|------------|-----------|
| proof_ppgen_sabv_lmtr5_MAPLE_50_extra6.no_input | RAM: 19.56 GB (z-score: 2.69, low) | Wall: 19:21:11<br>CPU: 155.0%<br>RAM: 19.56 GB | Wall: 11:52:52<br>CPU: 398.0%<br>RAM: 20.20 GB | ⚠️ Wall time cao + CPU thấp → Có thể do:<br>- System load cao (CPU contention)<br>- I/O bottleneck (disk đọc/ghi chậm)<br>- Memory swapping<br>- Background processes can thiệp |

---

## N = 100

**Tổng số runs:** 10

### ✅ Tất Cả Runs Đều Có Đầy Đủ Metrics

### ⚠️ Runs Có Số Liệu Bất Thường

| Run | Vấn Đề | Giá Trị | Giá Trị TB | Phân Tích |
|-----|--------|---------|------------|-----------|
| proof_ppgen_sabv_lmtr5_MAPLE_100_extra6.no_input | Wall Time: 12:25:55 (z-score: 2.64, high)<br>CPU: 384.0% (z-score: 2.37, low) | Wall: 12:25:55<br>CPU: 384.0%<br>RAM: 20.26 GB | Wall: 4:57:38<br>CPU: 1059.9%<br>RAM: 20.20 GB | ⚠️ Wall time cao + CPU thấp → Có thể do:<br>- System load cao (CPU contention)<br>- I/O bottleneck (disk đọc/ghi chậm)<br>- Memory swapping<br>- Background processes can thiệp |
| proof_ppgen_sabv_lmtr5_MAPLE_100_extra8.no_input | RAM: 19.68 GB (z-score: 2.54, low) | Wall: 3:47:12<br>CPU: 1191.0%<br>RAM: 19.68 GB | Wall: 4:57:38<br>CPU: 1059.9%<br>RAM: 20.20 GB | Cần kiểm tra thêm |
| proof_ppgen_sabv_lmtr5_MAPLE_100_round5.no_input | User Time: 47.29h (z-score: 2.12, high) | Wall: 7:07:33<br>CPU: 687.0%<br>RAM: 20.33 GB | Wall: 4:57:38<br>CPU: 1059.9%<br>RAM: 20.20 GB | Cần kiểm tra thêm |

---

## N = 200

**Tổng số runs:** 10

### ✅ Tất Cả Runs Đều Có Đầy Đủ Metrics

### ⚠️ Runs Có Số Liệu Bất Thường

| Run | Vấn Đề | Giá Trị | Giá Trị TB | Phân Tích |
|-----|--------|---------|------------|-----------|
| proof_ppgen_sabv_lmtr5_MAPLE_200_round5.no_input | Wall Time: 13:20:45 (z-score: 2.84, high)<br>CPU: 689.0% (z-score: 2.85, low)<br>User Time: 88.81h (z-score: 2.68, high) | Wall: 13:20:45<br>CPU: 689.0%<br>RAM: 21.33 GB | Wall: 7:25:43<br>CPU: 1176.8%<br>RAM: 21.22 GB | ⚠️ Wall time cao + CPU thấp → Có thể do:<br>- System load cao (CPU contention)<br>- I/O bottleneck (disk đọc/ghi chậm)<br>- Memory swapping<br>- Background processes can thiệp |

---

## N = 500

**Tổng số runs:** 10

### ✅ Tất Cả Runs Đều Có Đầy Đủ Metrics

### ⚠️ Runs Có Số Liệu Bất Thường

| Run | Vấn Đề | Giá Trị | Giá Trị TB | Phân Tích |
|-----|--------|---------|------------|-----------|
| proof_ppgen_sabv_lmtr5_MAPLE_500_round5.no_input | Wall Time: 29:57:55 (z-score: 2.44, high)<br>CPU: 720.0% (z-score: 2.24, low)<br>User Time: 208.25h (z-score: 2.45, high) | Wall: 29:57:55<br>CPU: 720.0%<br>RAM: 22.35 GB | Wall: 17:56:16<br>CPU: 1166.3%<br>RAM: 22.42 GB | ⚠️ Wall time cao + CPU thấp → Có thể do:<br>- System load cao (CPU contention)<br>- I/O bottleneck (disk đọc/ghi chậm)<br>- Memory swapping<br>- Background processes can thiệp |

---

## N = 700

**Tổng số runs:** 10

### ✅ Tất Cả Runs Đều Có Đầy Đủ Metrics

### ⚠️ Runs Có Số Liệu Bất Thường

| Run | Vấn Đề | Giá Trị | Giá Trị TB | Phân Tích |
|-----|--------|---------|------------|-----------|
| proof_ppgen_sabv_lmtr5_MAPLE_700_round4.no_input | Wall Time: 41:38:53 (z-score: 2.78, high)<br>CPU: 717.0% (z-score: 2.67, low)<br>User Time: 288.33h (z-score: 2.79, high) | Wall: 41:38:53<br>CPU: 717.0%<br>RAM: 22.66 GB | Wall: 24:04:07<br>CPU: 1185.8%<br>RAM: 22.64 GB | ⚠️ Wall time cao + CPU thấp → Có thể do:<br>- System load cao (CPU contention)<br>- I/O bottleneck (disk đọc/ghi chậm)<br>- Memory swapping<br>- Background processes can thiệp |

---

## 📊 Tóm Tắt

- **Tổng số runs đang chạy (chưa hoàn thành):** 0
- **Tổng số runs thiếu metrics (đã hoàn thành nhưng thiếu dữ liệu):** 0
- **Tổng số runs có số liệu bất thường:** 11

### 🔍 Giải Thích Chung Các Nguyên Nhân


1. **Wall Time Cao + CPU Usage Thấp:**
   - **Nguyên nhân chính:** System resource contention
   - CPU không được sử dụng tối đa do bị các processes khác tranh giành
   - Có thể do background jobs, system load cao, hoặc I/O wait
   - **Giải pháp:** Đảm bảo system không có processes nặng khác chạy đồng thời

2. **CPU Usage Thấp Bất Thường:**
   - Process không thể sử dụng hết CPU cores do:
     - System scheduler ưu tiên các processes khác
     - Memory bandwidth bottleneck
     - I/O wait time cao
   - **Đặc biệt ở N nhỏ (N=1, 10, 20):** Công việc không đủ để tận dụng hết parallelization

3. **Wall Time Cao Bất Thường:**
   - SP1 proving stage chiếm phần lớn thời gian và có thể biến thiên
   - System cache miss rate cao
   - Memory allocation/deallocation overhead

4. **Variation Lớn (High Std Dev):**
   - System state khác nhau giữa các runs
   - Background workload không consistent
   - Network I/O (nếu có)
   - File system cache state khác nhau

