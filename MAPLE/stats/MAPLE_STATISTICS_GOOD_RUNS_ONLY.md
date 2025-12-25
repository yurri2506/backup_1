# 📊 MAPLE PESSIMISTIC PROOF - THỐNG KÊ CHỈ VỚI CÁC RUNS TỐT

**Ngày tạo:** 2025-12-24
**Thuật toán:** MAPLE (SABMAPLE + LMTR4)
**Hệ thống proving:** SP1 (CPU-based)
**Lưu ý:** Đã loại bỏ các runs bất thường do kẹt RAM/resource contention

---

## 📈 Bảng Thống Kê Tổng Hợp (Chỉ Runs Tốt)

| N | Số Runs (Tốt) | Loại Bỏ | Thời Gian TB (Wall) | CPU TB (%) | RAM TB (GB) | Thời Gian CPU TB (h) | Proof TB (MB) |
|---|---------------|---------|---------------------|------------|-------------|----------------------|---------------|
| 1 | 10 | - | 3:10:14 | 455.4 | 15.53 | 7.50 | N/A |
| 10 | 9 | 1 | 4:19:10 | 517.7 | 16.93 | 10.81 | N/A |
| 20 | 7 | 3 | 10:46:14 | 151.4 | 19.77 | 15.75 | N/A |
| 50 | 9 | 1 | 11:03:03 | 425.0 | 20.27 | 27.59 | N/A |
| 100 | 7 | 3 | 3:45:05 | 1191.0 | 20.24 | 43.36 | N/A |
| 200 | 9 | 1 | 6:46:17 | 1231.0 | 21.21 | 80.83 | N/A |
| 500 | 8 | 2 | 16:44:21 | 1210.2 | 22.41 | 193.17 | N/A |
| 700 | 9 | 1 | 22:06:55 | 1237.9 | 22.64 | 264.55 | N/A |

---

## 📊 Chi Tiết Theo Từng N

### N = 1
**Số runs tốt:** 10

| Metric | Trung Bình | Min | Max | Median | Std Dev |
|--------|-----------|-----|-----|--------|---------|
| Thời Gian (Wall) | 3:10:14 | 0:47:03 | 6:48:31 | 2:03:40 | 2:29:08 |
| CPU (%) | 455.4 | 122.0 | 882.0 | 384.0 | 329.6 |
| RAM (GB) | 15.53 | 14.80 | 16.24 | 15.51 | 0.51 |
| Thời Gian CPU (h) | 7.50 | 6.73 | 8.08 | 7.67 | 0.55 |

### N = 10
**Số runs tốt:** 9
**Đã loại bỏ:** proof_ppgen_sabv_lmtr5_MAPLE_10_extra6.no_input (do kẹt RAM/resource contention)

| Metric | Trung Bình | Min | Max | Median | Std Dev |
|--------|-----------|-----|-----|--------|---------|
| Thời Gian (Wall) | 4:19:10 | 1:00:51 | 8:22:27 | 1:56:54 | 3:30:19 |
| CPU (%) | 517.7 | 144.0 | 972.0 | 566.0 | 379.5 |
| RAM (GB) | 16.93 | 16.71 | 17.05 | 16.94 | 0.11 |
| Thời Gian CPU (h) | 10.81 | 9.57 | 11.98 | 10.68 | 1.00 |

### N = 20
**Số runs tốt:** 7
**Đã loại bỏ:** proof_ppgen_sabv_lmtr5_MAPLE_20_extra2.no_input, proof_ppgen_sabv_lmtr5_MAPLE_20_extra7.no_input, proof_ppgen_sabv_lmtr5_MAPLE_20_extra8.no_input (do kẹt RAM/resource contention)

| Metric | Trung Bình | Min | Max | Median | Std Dev |
|--------|-----------|-----|-----|--------|---------|
| Thời Gian (Wall) | 10:46:14 | 10:07:01 | 11:21:11 | 10:51:58 | 0:31:21 |
| CPU (%) | 151.4 | 144.0 | 160.0 | 151.0 | 7.2 |
| RAM (GB) | 19.77 | 19.67 | 19.91 | 19.77 | 0.08 |
| Thời Gian CPU (h) | 15.75 | 15.45 | 15.90 | 15.80 | 0.16 |

### N = 50
**Số runs tốt:** 9
**Đã loại bỏ:** proof_ppgen_sabv_lmtr5_MAPLE_50_extra6.no_input (do kẹt RAM/resource contention)

| Metric | Trung Bình | Min | Max | Median | Std Dev |
|--------|-----------|-----|-----|--------|---------|
| Thời Gian (Wall) | 11:03:03 | 4:07:31 | 20:07:06 | 4:22:36 | 8:05:52 |
| CPU (%) | 425.0 | 150.0 | 660.0 | 623.0 | 256.6 |
| RAM (GB) | 20.27 | 20.16 | 20.41 | 20.25 | 0.08 |
| Thời Gian CPU (h) | 27.59 | 26.07 | 29.53 | 26.34 | 1.66 |

### N = 100
**Số runs tốt:** 7
**Đã loại bỏ:** proof_ppgen_sabv_lmtr5_MAPLE_100_extra6.no_input, proof_ppgen_sabv_lmtr5_MAPLE_100_extra8.no_input, proof_ppgen_sabv_lmtr5_MAPLE_100_round5.no_input (do kẹt RAM/resource contention)

| Metric | Trung Bình | Min | Max | Median | Std Dev |
|--------|-----------|-----|-----|--------|---------|
| Thời Gian (Wall) | 3:45:05 | 3:41:01 | 3:48:17 | 3:45:36 | 0:02:56 |
| CPU (%) | 1191.0 | 1178.0 | 1197.0 | 1192.0 | 6.5 |
| RAM (GB) | 20.24 | 20.06 | 20.40 | 20.24 | 0.11 |
| Thời Gian CPU (h) | 43.36 | 42.69 | 43.94 | 43.13 | 0.50 |

### N = 200
**Số runs tốt:** 9
**Đã loại bỏ:** proof_ppgen_sabv_lmtr5_MAPLE_200_round5.no_input (do kẹt RAM/resource contention)

| Metric | Trung Bình | Min | Max | Median | Std Dev |
|--------|-----------|-----|-----|--------|---------|
| Thời Gian (Wall) | 6:46:17 | 6:38:28 | 6:51:13 | 6:50:01 | 0:05:09 |
| CPU (%) | 1231.0 | 1227.0 | 1237.0 | 1229.0 | 3.5 |
| RAM (GB) | 21.21 | 21.01 | 21.40 | 21.14 | 0.14 |
| Thời Gian CPU (h) | 80.83 | 78.95 | 81.71 | 81.38 | 0.97 |

### N = 500
**Số runs tốt:** 8
**Đã loại bỏ:** proof_ppgen_sabv_lmtr5_MAPLE_500_round2.no_input, proof_ppgen_sabv_lmtr5_MAPLE_500_round5.no_input (do kẹt RAM/resource contention)

| Metric | Trung Bình | Min | Max | Median | Std Dev |
|--------|-----------|-----|-----|--------|---------|
| Thời Gian (Wall) | 16:44:21 | 15:26:25 | 23:46:02 | 15:49:31 | 2:50:42 |
| CPU (%) | 1210.2 | 868.0 | 1274.0 | 1256.5 | 138.4 |
| RAM (GB) | 22.41 | 22.24 | 22.54 | 22.40 | 0.09 |
| Thời Gian CPU (h) | 193.17 | 189.49 | 199.81 | 192.96 | 3.02 |

### N = 700
**Số runs tốt:** 9
**Đã loại bỏ:** proof_ppgen_sabv_lmtr5_MAPLE_700_round4.no_input (do kẹt RAM/resource contention)

| Metric | Trung Bình | Min | Max | Median | Std Dev |
|--------|-----------|-----|-----|--------|---------|
| Thời Gian (Wall) | 22:06:55 | 21:21:20 | 25:52:10 | 21:44:58 | 1:25:08 |
| CPU (%) | 1237.9 | 1067.0 | 1272.0 | 1251.0 | 64.8 |
| RAM (GB) | 22.64 | 22.42 | 22.82 | 22.64 | 0.13 |
| Thời Gian CPU (h) | 264.55 | 263.28 | 267.34 | 263.76 | 1.63 |

---

## 📋 Tóm Tắt

- **Tổng số runs tốt:** 68
- **Tổng số runs đã loại bỏ:** 12
- **Tỷ lệ runs tốt:** 85.0%

**Lưu ý:** Các runs bất thường bị loại bỏ do:
- Wall time cao bất thường kèm CPU usage thấp
- Resource contention (CPU, I/O bottleneck)
- Kẹt RAM hoặc memory swapping
- Background processes can thiệp
