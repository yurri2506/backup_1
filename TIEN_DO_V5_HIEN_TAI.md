# TIẾN ĐỘ THỰC NGHIỆM V5 - CẬP NHẬT

**Ngày kiểm tra:** 2025-11-17 01:40 UTC

---

## 📊 TỔNG HỢP SỐ RUNS HOÀN THÀNH

| N | Số runs hoàn thành | Ghi chú |
|---|-------------------|---------|
| **N=1** | 9 runs | ✅ Hoàn thành |
| **N=10** | 6 runs | ✅ Hoàn thành |
| **N=100** | 12 runs | ✅ Hoàn thành |
| **N=200** | 3 runs | ✅ Đã có đủ runs |
| **N=500** | 13 runs (đang chạy run 3) | ⏳ **ĐANG CHẠY** |
| **N=700** | 2 runs | ⏳ Đang chờ |

---

## 🔄 RUN ĐANG CHẠY

### **N=500, Run 3**

**Status:** ⏳ **ĐANG CHẠY**

**Process Info:**
- **PID:** 310029
- **Command:** `ppgen_sabv_lmtr5 --n-exits 500 --validator-nodes 5`
- **Started:** 2025-11-16 14:59:53 UTC
- **Elapsed time:** ~10 giờ 40 phút (tính đến 01:40 UTC)
- **CPU Usage:** ~1286% (12.86 cores)
- **RAM Usage:** ~12.3 GB

**SP1 Proving Progress:**
- **Current cycle:** 180M cycles (clk = 180000000)
- **Last log:** 2025-11-16 22:36:51 UTC (prove_core: close time.busy=27405s)
- **Status:** Đang chạy SP1 proving (SABV5 đã pass)

**Expected Time (dựa trên best run):**
- **Best run (Run 2):** 15:39:11 (15 giờ 39 phút)
- **Estimate còn lại:** ~5 giờ (nếu theo best run)
- **Dự kiến hoàn thành:** Khoảng 06:40 UTC (17/11) nếu theo best run

**Log File:**
- `logs/v5/v5_n500_run3_20251116_145952.log` (790 lines)
- **Last modified:** 2025-11-16 22:36:51 UTC

**TMUX Session:**
- Session: `v5_benchmark`
- Attach: `tmux attach -t v5_benchmark`

---

## ✅ RUNS ĐÃ HOÀN THÀNH

### **N=1**
- **9 runs** hoàn thành
- Best: Run 5 - Elapsed: ~1 giờ

### **N=10**
- **6 runs** hoàn thành  
- Best: Run 5 - Elapsed: ~1:01:56

### **N=100**
- **12 runs** hoàn thành
- Best: Run 5 - Elapsed: ~3:39:18

### **N=200**
- **3 runs** hoàn thành
- Best: Run 1 - Elapsed: ~6:49:53
- Latest: Run 3 - 2025-11-16 08:05

### **N=500**
- **2 runs** hoàn thành (Run 1, Run 2)
- Best: Run 2 - Elapsed: ~15:39:11
- Run 3: **ĐANG CHẠY** (~8.5 giờ đã chạy)

### **N=700**
- **2 runs** hoàn thành
- Best: Run 1 - Elapsed: ~21:43:11
- Latest: Run 2 - 2025-11-15 10:06

---

## 📋 BEST RUNS (theo thong_ke_v5_hien_tai.txt)

**Cập nhật:** Sat Nov 15 05:17:08 PM UTC 2025

| Metric | N=10 | N=100 | N=200 | N=500 | N=700 |
|--------|------|-------|-------|-------|-------|
| **Elapsed time** | 1:01:56 | 3:39:18 | 6:49:53 | 15:39:11 | 21:43:11 |
| **User time (s)** | 36,472.74 | 162,705.37 | 292,818.34 | 687,588.67 | 949,811.32 |
| **System time (s)** | 1,047.81 | 4,881.31 | 9,786.68 | 23,109.76 | 32,149.40 |
| **CPU usage (%)** | 1,009 | 1,273 | 1,230 | 1,261 | 1,255 |
| **Max RAM (GB)** | 28.11 | 54.16 | 21.35 | 22.54 | 22.73 |
| **SP1 Config** | (1, 1) | (1, 1) | (1, 1) | (1, 1) | (1, 1) |
| **RAYON_NUM_THREADS** | 16 | 16 | 16 | 16 | 16 |
| **Best Run** | 5 | 5 | 1 | 2 | 1 |

---

## 🔍 LOG FILES MỚI NHẤT

1. **v5_n500_run3_20251116_145952.log** (43K) - **Nov 16 22:36** - ⏳ **ĐANG CHẠY**
2. **v5_n200_run3_20251116_080521.log** (37K) - Nov 16 14:59 - ✅ Hoàn thành
3. **v5_n700_run2_20251115_100633.log** (50K) - Nov 15 10:06 - ✅ Hoàn thành
4. **v5_n500_run2_20251114_182719.log** (45K) - Nov 15 10:06 - ✅ Hoàn thành

---

## 📈 TIẾN ĐỘ DỰ KIẾN

### **Mục tiêu:** 5 runs cho mỗi N (N=1, 10, 100, 200, 500, 700)

| N | Mục tiêu | Hiện tại | Còn lại | Status |
|---|----------|----------|---------|--------|
| N=1 | 5 runs | **9 runs** | ✅ Vượt | ✅ |
| N=10 | 5 runs | **6 runs** | ✅ Vượt | ✅ |
| N=100 | 5 runs | **12 runs** | ✅ Vượt | ✅ |
| N=200 | 5 runs | **3 runs** | 2 runs | ⏳ |
| N=500 | 5 runs | **2 runs** (run 3 đang chạy) | 2-3 runs | ⏳ |
| N=700 | 5 runs | **2 runs** | 3 runs | ⏳ |

### **Thời gian ước tính:**

**N=500, Run 3:**
- Đã chạy: ~10 giờ 40 phút (tính đến 01:40 UTC)
- Estimated còn lại: ~5 giờ (dựa trên best run 15:39:11)
- **Dự kiến hoàn thành:** Khoảng 06:40 UTC (17/11) nếu theo best run
- **SP1 Progress:** Đang ở 180M cycles, đang generate main traces

**N=500, Run 4-5:**
- Estimated: ~15-16 giờ mỗi run
- **Tổng ước tính:** ~30-32 giờ cho 2 runs còn lại

**N=200, Run 4-5:**
- Estimated: ~6-7 giờ mỗi run
- **Tổng ước tính:** ~12-14 giờ cho 2 runs

**N=700, Run 3-5:**
- Estimated: ~21-22 giờ mỗi run
- **Tổng ước tính:** ~63-66 giờ cho 3 runs

---

## 💡 CẤU HÌNH HIỆN TẠI

- **RAYON_NUM_THREADS:** 16
- **SHARD_BATCH_SIZE:** 1
- **TRACE_GEN_WORKERS:** 1
- **SHARD_SIZE:** 2097152
- **SP1_PROVER:** cpu
- **Validator nodes:** 5

---

## 🎯 KẾT LUẬN

1. **Đang chạy:** N=500, Run 3 (~8.5 giờ đã chạy, còn ~7 giờ)
2. **Cần chạy thêm:**
   - N=200: 2 runs (Run 4, 5)
   - N=500: 2 runs (Run 4, 5) sau khi Run 3 xong
   - N=700: 3 runs (Run 3, 4, 5)

3. **Thời gian ước tính còn lại:** ~105-112 giờ (~4.5-5 ngày) nếu chạy tuần tự

---

**Cập nhật:** 2025-11-17 01:40 UTC

---

## 📝 GHI CHÚ

- **N=500, Run 3** đang chạy ở giai đoạn SP1 proving (sau khi SABV5 pass)
- Log cuối cùng: 22:36:51 UTC (16/11) - đang ở 180M cycles
- Process vẫn đang chạy bình thường (PID 310029, CPU ~1286%, RAM ~12.3GB)

