# 📊 SỐ LIỆU BASELINE

**Nguồn:** BASELINE_SUMMARY_ALL.md  
**Ngày cập nhật:** 2025-11-17  
**Thuật toán:** Baseline Pessimistic Proof  
**Hệ thống proving:** SP1 (CPU-based)

---

## Bảng Tổng Hợp

| N | Số Runs | Elapsed Time | Elapsed Time (phút) | CPU (%) | Max RAM (GB) |
|---|---------|--------------|---------------------|---------|--------------|
| 1 | 10 | 44:20 | 44.3 | 737.1 | 15.1 |
| 10 | 10 | 1:03:31 | 63.5 | 977.8 | 17.0 |
| 20 | 10 | 1:18:50 | 78.8 | 1050.0 | 19.8 |
| 50 | 10 | 2:10:14 | 130.2 | 1138.0 | 20.3 |
| 100 | 10 | 3:40:43 | 220.7 | 1191.5 | 20.2 |
| 200 | 10 | 6:38:13 | 398.2 | 1233.0 | 21.2 |
| 500 | 10 | 15:24:32 | 924.5 | 1265.9 | 22.5 |
| 700 | 5 | 21:52:19 | 1312.3 | 1262.0 | 22.7 |

---

## Format Theo Phút (Để So Sánh)

| N | Elapsed Time (phút) | CPU (%) | Max RAM (GB) |
|---|---------------------|---------|--------------|
| 1 | 44.3 | 737.1 | 15.1 |
| 10 | 63.5 | 977.8 | 17.0 |
| 20 | 78.8 | 1050.0 | 19.8 |
| 50 | 130.2 | 1138.0 | 20.3 |
| 100 | 220.7 | 1191.5 | 20.2 |
| 200 | 398.2 | 1233.0 | 21.2 |
| 500 | 924.5 | 1265.9 | 22.5 |
| 700 | 1312.3 | 1262.0 | 22.7 |

---

## Chi Tiết Theo Từng N

### N = 1 (10 runs completed)

**Trung bình:** Time=44:20, CPU=737.1%, RAM=15.1 GB  
**Min:** Time=31:07, CPU=433.0%, RAM=14.7 GB  
**Max:** Time=1:07:01, CPU=881.0%, RAM=15.4 GB  
**CV:** 30.0%

### N = 10 (10 runs completed)

**Trung bình:** Time=1:03:31, CPU=977.8%, RAM=17.0 GB  
**Min:** Time=1:03:11, CPU=974.0%, RAM=16.9 GB  
**Max:** Time=1:03:45, CPU=983.0%, RAM=17.2 GB  
**CV:** 0.2%

### N = 20 (10 runs completed)

**Trung bình:** Time=1:18:50, CPU=1050.0%, RAM=19.8 GB  
**Min:** Time=1:17:30, CPU=1045.0%, RAM=19.7 GB  
**Max:** Time=1:19:53, CPU=1059.0%, RAM=20.0 GB  
**CV:** 1.2%

### N = 50 (10 runs completed)

**Trung bình:** Time=2:10:14, CPU=1138.0%, RAM=20.3 GB  
**Min:** Time=2:08:57, CPU=1127.0%, RAM=20.1 GB  
**Max:** Time=2:11:01, CPU=1145.0%, RAM=20.6 GB  
**CV:** 0.5%

### N = 100 (10 runs completed)

**Trung bình:** Time=3:40:43, CPU=1191.5%, RAM=20.2 GB  
**Min:** Time=3:40:01, CPU=1185.0%, RAM=19.9 GB  
**Max:** Time=3:41:21, CPU=1196.0%, RAM=20.4 GB  
**CV:** 0.2%

### N = 200 (10 runs completed)

**Trung bình:** Time=6:38:13, CPU=1233.0%, RAM=21.2 GB  
**Min:** Time=6:37:09, CPU=1228.0%, RAM=20.8 GB  
**Max:** Time=6:40:26, CPU=1243.0%, RAM=21.5 GB  
**CV:** 0.2%

### N = 500 (10 runs completed)

**Trung bình:** Time=15:24:32, CPU=1265.9%, RAM=22.5 GB  
**Min:** Time=15:19:04, CPU=1257.0%, RAM=21.9 GB  
**Max:** Time=15:29:12, CPU=1279.0%, RAM=22.8 GB  
**CV:** 0.4%

### N = 700 (5 runs completed)

**Trung bình:** Time=21:52:19, CPU=1262.0%, RAM=22.7 GB  
**Min:** Time=21:25:38, CPU=1203.0%, RAM=22.6 GB  
**Max:** Time=23:19:43, CPU=1283.0%, RAM=22.8 GB  
**CV:** 3.7%

---

## Nhận Xét

1. **Tất cả các giá trị là trung bình** của các runs hoàn thành
2. **N=1-500:** 10 runs mỗi N
3. **N=700:** 5 runs (do chỉ có 5 runs hoàn thành)
4. **Độ ổn định:** CV rất thấp cho N≥10 (0.2-1.2%), cho thấy performance rất ổn định
5. **N=1:** CV cao hơn (30%) do variation lớn giữa các runs
6. **CPU Usage:** Tăng dần từ 737% (N=1) đến ~1265% (N≥500), cho thấy parallelization tốt
7. **RAM Usage:** Tăng dần từ 15.1 GB (N=1) đến 22.7 GB (N=700)

---

**File đầy đủ:** `BASELINE_SUMMARY_ALL.md`

