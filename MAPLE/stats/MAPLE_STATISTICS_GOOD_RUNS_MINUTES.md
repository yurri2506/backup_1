# 📊 MAPLE PESSIMISTIC PROOF - THỐNG KÊ RUNS TỐT (THEO PHÚT)

**Ngày tạo:** 2025-12-24
**Thuật toán:** MAPLE (SABMAPLE + LMTR4)
**Hệ thống proving:** SP1 (CPU-based)
**Lưu ý:** Đã loại bỏ các runs bất thường do kẹt RAM/resource contention

---

## 📈 Bảng Thống Kê Tổng Hợp (Thời Gian Theo Phút)

| N | Số Runs (Tốt) | Loại Bỏ | Thời Gian TB (phút) | Thời Gian TB | Min (phút) | Max (phút) | CPU TB (%) | RAM TB (GB) | User Time TB (h) |
|---|---------------|---------|---------------------|--------------|------------|------------|------------|-------------|------------------|
| 1 | 10 | - | 190.2 | 3h 10.2m | 47.0 | 408.5 | 455.4 | 15.53 | 7.50 |
| 10 | 9 | 1 | 259.2 | 4h 19.2m | 60.9 | 502.4 | 517.7 | 16.93 | 10.81 |
| 20 | 7 | 3 | 646.2 | 10h 46.2m | 607.0 | 681.2 | 151.4 | 19.77 | 15.75 |
| 50 | 9 | 1 | 663.1 | 11h 3.1m | 247.5 | 1207.1 | 425.0 | 20.27 | 27.59 |
| 100 | 7 | 3 | 225.1 | 3h 45.1m | 221.0 | 228.3 | 1191.0 | 20.24 | 43.36 |
| 200 | 9 | 1 | 406.3 | 6h 46.3m | 398.5 | 411.2 | 1231.0 | 21.21 | 80.83 |
| 500 | 8 | 2 | 1004.4 | 16h 44.4m | 926.4 | 1426.0 | 1210.2 | 22.41 | 193.17 |
| 700 | 9 | 1 | 1326.9 | 22h 6.9m | 1281.3 | 1552.2 | 1237.9 | 22.64 | 264.55 |

---

## 📊 Chi Tiết Theo Từng N

### N = 1
**Số runs tốt:** 10

| Metric | Trung Bình | Min | Max | Median | Std Dev |
|--------|-----------|-----|-----|--------|---------|
| Thời Gian (phút) | 190.2 | 47.0 | 408.5 | 123.7 | 149.1 |
| Thời Gian (đọc được) | 3h 10.2m | 47.0 phút | 6h 48.5m | 2h 3.7m | 2h 29.1m |
| CPU (%) | 455.4 | 122.0 | 882.0 | 384.0 | 329.6 |
| RAM (GB) | 15.53 | 14.80 | 16.24 | 15.51 | 0.51 |
| Thời Gian CPU (h) | 7.50 | 6.73 | 8.08 | 7.67 | 0.55 |

### N = 10
**Số runs tốt:** 9
**Đã loại bỏ:** proof_ppgen_sabv_lmtr5_MAPLE_10_extra6.no_input (do kẹt RAM/resource contention)

| Metric | Trung Bình | Min | Max | Median | Std Dev |
|--------|-----------|-----|-----|--------|---------|
| Thời Gian (phút) | 259.2 | 60.9 | 502.4 | 116.9 | 210.3 |
| Thời Gian (đọc được) | 4h 19.2m | 1h 0.9m | 8h 22.4m | 1h 56.9m | 3h 30.3m |
| CPU (%) | 517.7 | 144.0 | 972.0 | 566.0 | 379.5 |
| RAM (GB) | 16.93 | 16.71 | 17.05 | 16.94 | 0.11 |
| Thời Gian CPU (h) | 10.81 | 9.57 | 11.98 | 10.68 | 1.00 |

### N = 20
**Số runs tốt:** 7
**Đã loại bỏ:** proof_ppgen_sabv_lmtr5_MAPLE_20_extra2.no_input, proof_ppgen_sabv_lmtr5_MAPLE_20_extra7.no_input, proof_ppgen_sabv_lmtr5_MAPLE_20_extra8.no_input (do kẹt RAM/resource contention)

| Metric | Trung Bình | Min | Max | Median | Std Dev |
|--------|-----------|-----|-----|--------|---------|
| Thời Gian (phút) | 646.2 | 607.0 | 681.2 | 652.0 | 31.4 |
| Thời Gian (đọc được) | 10h 46.2m | 10h 7.0m | 11h 21.2m | 10h 52.0m | 31.4 phút |
| CPU (%) | 151.4 | 144.0 | 160.0 | 151.0 | 7.2 |
| RAM (GB) | 19.77 | 19.67 | 19.91 | 19.77 | 0.08 |
| Thời Gian CPU (h) | 15.75 | 15.45 | 15.90 | 15.80 | 0.16 |

### N = 50
**Số runs tốt:** 9
**Đã loại bỏ:** proof_ppgen_sabv_lmtr5_MAPLE_50_extra6.no_input (do kẹt RAM/resource contention)

| Metric | Trung Bình | Min | Max | Median | Std Dev |
|--------|-----------|-----|-----|--------|---------|
| Thời Gian (phút) | 663.1 | 247.5 | 1207.1 | 262.6 | 485.9 |
| Thời Gian (đọc được) | 11h 3.1m | 4h 7.5m | 20h 7.1m | 4h 22.6m | 8h 5.9m |
| CPU (%) | 425.0 | 150.0 | 660.0 | 623.0 | 256.6 |
| RAM (GB) | 20.27 | 20.16 | 20.41 | 20.25 | 0.08 |
| Thời Gian CPU (h) | 27.59 | 26.07 | 29.53 | 26.34 | 1.66 |

### N = 100
**Số runs tốt:** 7
**Đã loại bỏ:** proof_ppgen_sabv_lmtr5_MAPLE_100_extra6.no_input, proof_ppgen_sabv_lmtr5_MAPLE_100_extra8.no_input, proof_ppgen_sabv_lmtr5_MAPLE_100_round5.no_input (do kẹt RAM/resource contention)

| Metric | Trung Bình | Min | Max | Median | Std Dev |
|--------|-----------|-----|-----|--------|---------|
| Thời Gian (phút) | 225.1 | 221.0 | 228.3 | 225.6 | 2.9 |
| Thời Gian (đọc được) | 3h 45.1m | 3h 41.0m | 3h 48.3m | 3h 45.6m | 2.9 phút |
| CPU (%) | 1191.0 | 1178.0 | 1197.0 | 1192.0 | 6.5 |
| RAM (GB) | 20.24 | 20.06 | 20.40 | 20.24 | 0.11 |
| Thời Gian CPU (h) | 43.36 | 42.69 | 43.94 | 43.13 | 0.50 |

### N = 200
**Số runs tốt:** 9
**Đã loại bỏ:** proof_ppgen_sabv_lmtr5_MAPLE_200_round5.no_input (do kẹt RAM/resource contention)

| Metric | Trung Bình | Min | Max | Median | Std Dev |
|--------|-----------|-----|-----|--------|---------|
| Thời Gian (phút) | 406.3 | 398.5 | 411.2 | 410.0 | 5.2 |
| Thời Gian (đọc được) | 6h 46.3m | 6h 38.5m | 6h 51.2m | 6h 50.0m | 5.2 phút |
| CPU (%) | 1231.0 | 1227.0 | 1237.0 | 1229.0 | 3.5 |
| RAM (GB) | 21.21 | 21.01 | 21.40 | 21.14 | 0.14 |
| Thời Gian CPU (h) | 80.83 | 78.95 | 81.71 | 81.38 | 0.97 |

### N = 500
**Số runs tốt:** 8
**Đã loại bỏ:** proof_ppgen_sabv_lmtr5_MAPLE_500_round2.no_input, proof_ppgen_sabv_lmtr5_MAPLE_500_round5.no_input (do kẹt RAM/resource contention)

| Metric | Trung Bình | Min | Max | Median | Std Dev |
|--------|-----------|-----|-----|--------|---------|
| Thời Gian (phút) | 1004.4 | 926.4 | 1426.0 | 949.5 | 170.7 |
| Thời Gian (đọc được) | 16h 44.4m | 15h 26.4m | 23h 46.0m | 15h 49.5m | 2h 50.7m |
| CPU (%) | 1210.2 | 868.0 | 1274.0 | 1256.5 | 138.4 |
| RAM (GB) | 22.41 | 22.24 | 22.54 | 22.40 | 0.09 |
| Thời Gian CPU (h) | 193.17 | 189.49 | 199.81 | 192.96 | 3.02 |

### N = 700
**Số runs tốt:** 9
**Đã loại bỏ:** proof_ppgen_sabv_lmtr5_MAPLE_700_round4.no_input (do kẹt RAM/resource contention)

| Metric | Trung Bình | Min | Max | Median | Std Dev |
|--------|-----------|-----|-----|--------|---------|
| Thời Gian (phút) | 1326.9 | 1281.3 | 1552.2 | 1305.0 | 85.1 |
| Thời Gian (đọc được) | 22h 6.9m | 21h 21.3m | 25h 52.2m | 21h 45.0m | 1h 25.1m |
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
