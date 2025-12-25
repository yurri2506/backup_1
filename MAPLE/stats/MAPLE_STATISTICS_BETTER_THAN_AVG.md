# 📊 MAPLE PESSIMISTIC PROOF - THỐNG KÊ RUNS TỐT (NHỎ HƠN TRUNG BÌNH)

**Ngày tạo:** 2025-12-24
**Thuật toán:** MAPLE (SABMAPLE + LMTR4)
**Hệ thống proving:** SP1 (CPU-based)
**Định nghĩa run tốt:** Runs có thời gian NHỎ HƠN trung bình của tất cả 10 runs

---

## 📈 Bảng Thống Kê Tổng Hợp (Runs Nhỏ Hơn Trung Bình)

| N | Số Runs Tốt | Loại Bỏ | TB Tất Cả (phút) | TB Runs Tốt (phút) | TB Runs Tốt | Min (phút) | Max (phút) | CPU TB (%) | RAM TB (GB) | User Time TB (h) |
|---|-------------|---------|------------------|-------------------|-------------|------------|------------|------------|-------------|------------------|
| 1 | 6 | 4 | 190.2 | 77.8 | 1h 17.8m | 47.0 | 130.5 | 667.2 | 15.32 | 7.18 |
| 10 | 5 | 5 | 279.3 | 83.0 | 1h 23.0m | 60.9 | 116.9 | 809.8 | 16.97 | 10.04 |
| 20 | 5 | 5 | 641.4 | 611.3 | 10h 11.3m | 594.3 | 621.4 | 159.4 | 19.78 | 15.73 |
| 50 | 5 | 5 | 712.9 | 253.7 | 4h 13.7m | 247.5 | 262.6 | 641.2 | 20.31 | 26.19 |
| 100 | 8 | 2 | 297.6 | 225.4 | 3h 45.4m | 221.0 | 228.3 | 1191.0 | 20.17 | 43.42 |
| 200 | 9 | 1 | 445.7 | 406.3 | 6h 46.3m | 398.5 | 411.2 | 1231.0 | 21.21 | 80.83 |
| 500 | 8 | 2 | 1076.3 | 942.4 | 15h 42.4m | 926.4 | 953.8 | 1259.4 | 22.44 | 191.89 |
| 700 | 8 | 2 | 1444.1 | 1298.8 | 21h 38.8m | 1281.3 | 1313.0 | 1259.2 | 22.62 | 264.22 |

---

## 📊 Chi Tiết Theo Từng N

### N = 1
**Số runs tốt (nhỏ hơn TB):** 6
**Trung bình tất cả runs:** 3h 10.2m (190.2 phút)
**Trung bình runs tốt:** 1h 17.8m (77.8 phút)
**Cải thiện:** 1h 52.4m (112.4 phút, 59.1% nhanh hơn)
**Đã loại bỏ (≥TB):** 1_extra10, 1_extra7, 1_extra8, 1_extra9

| Metric | Trung Bình | Min | Max | Median | Std Dev |
|--------|-----------|-----|-----|--------|---------|
| Thời Gian (phút) | 77.8 | 47.0 | 130.5 | 62.6 | 37.7 |
| Thời Gian (đọc được) | 1h 17.8m | 47.0 phút | 2h 10.5m | 1h 2.6m | 37.7 phút |
| CPU (%) | 667.2 | 356.0 | 882.0 | 735.5 | 246.9 |
| RAM (GB) | 15.32 | 14.80 | 16.13 | 15.17 | 0.50 |
| Thời Gian CPU (h) | 7.18 | 6.73 | 7.80 | 7.13 | 0.48 |

### N = 10
**Số runs tốt (nhỏ hơn TB):** 5
**Trung bình tất cả runs:** 4h 39.3m (279.3 phút)
**Trung bình runs tốt:** 1h 23.0m (83.0 phút)
**Cải thiện:** 3h 16.2m (196.2 phút, 70.3% nhanh hơn)
**Đã loại bỏ (≥TB):** 10_extra10, 10_extra6, 10_extra7, 10_extra8, 10_extra9

| Metric | Trung Bình | Min | Max | Median | Std Dev |
|--------|-----------|-----|-----|--------|---------|
| Thời Gian (phút) | 83.0 | 60.9 | 116.9 | 61.7 | 29.6 |
| Thời Gian (đọc được) | 1h 23.0m | 1h 0.9m | 1h 56.9m | 1h 1.7m | 29.6 phút |
| CPU (%) | 809.8 | 566.0 | 972.0 | 968.0 | 218.9 |
| RAM (GB) | 16.97 | 16.84 | 17.05 | 17.00 | 0.08 |
| Thời Gian CPU (h) | 10.04 | 9.57 | 10.68 | 9.69 | 0.53 |

### N = 20
**Số runs tốt (nhỏ hơn TB):** 5
**Trung bình tất cả runs:** 10h 41.4m (641.4 phút)
**Trung bình runs tốt:** 10h 11.3m (611.3 phút)
**Cải thiện:** 30.1 phút (30.1 phút, 4.7% nhanh hơn)
**Đã loại bỏ (≥TB):** 20_extra1, 20_extra10, 20_extra5, 20_extra6, 20_extra8

| Metric | Trung Bình | Min | Max | Median | Std Dev |
|--------|-----------|-----|-----|--------|---------|
| Thời Gian (phút) | 611.3 | 594.3 | 621.4 | 615.6 | 10.9 |
| Thời Gian (đọc được) | 10h 11.3m | 9h 54.3m | 10h 21.4m | 10h 15.6m | 10.9 phút |
| CPU (%) | 159.4 | 153.0 | 168.0 | 159.0 | 5.5 |
| RAM (GB) | 19.78 | 19.71 | 19.85 | 19.78 | 0.05 |
| Thời Gian CPU (h) | 15.73 | 15.32 | 16.13 | 15.75 | 0.29 |

### N = 50
**Số runs tốt (nhỏ hơn TB):** 5
**Trung bình tất cả runs:** 11h 52.9m (712.9 phút)
**Trung bình runs tốt:** 4h 13.7m (253.7 phút)
**Cải thiện:** 7h 39.2m (459.2 phút, 64.4% nhanh hơn)
**Đã loại bỏ (≥TB):** 50_extra10, 50_extra6, 50_extra7, 50_extra8, 50_extra9

| Metric | Trung Bình | Min | Max | Median | Std Dev |
|--------|-----------|-----|-----|--------|---------|
| Thời Gian (phút) | 253.7 | 247.5 | 262.6 | 252.8 | 5.7 |
| Thời Gian (đọc được) | 4h 13.7m | 4h 7.5m | 4h 22.6m | 4h 12.8m | 5.7 phút |
| CPU (%) | 641.2 | 623.0 | 660.0 | 640.0 | 13.9 |
| RAM (GB) | 20.31 | 20.20 | 20.41 | 20.34 | 0.08 |
| Thời Gian CPU (h) | 26.19 | 26.07 | 26.34 | 26.15 | 0.14 |

### N = 100
**Số runs tốt (nhỏ hơn TB):** 8
**Trung bình tất cả runs:** 4h 57.6m (297.6 phút)
**Trung bình runs tốt:** 3h 45.4m (225.4 phút)
**Cải thiện:** 1h 12.3m (72.3 phút, 24.3% nhanh hơn)
**Đã loại bỏ (≥TB):** 100_extra6, 100_round5

| Metric | Trung Bình | Min | Max | Median | Std Dev |
|--------|-----------|-----|-----|--------|---------|
| Thời Gian (phút) | 225.4 | 221.0 | 228.3 | 226.4 | 2.8 |
| Thời Gian (đọc được) | 3h 45.4m | 3h 41.0m | 3h 48.3m | 3h 46.4m | 2.8 phút |
| CPU (%) | 1191.0 | 1178.0 | 1197.0 | 1191.5 | 6.0 |
| RAM (GB) | 20.17 | 19.68 | 20.40 | 20.24 | 0.22 |
| Thời Gian CPU (h) | 43.42 | 42.69 | 43.94 | 43.45 | 0.49 |

### N = 200
**Số runs tốt (nhỏ hơn TB):** 9
**Trung bình tất cả runs:** 7h 25.7m (445.7 phút)
**Trung bình runs tốt:** 6h 46.3m (406.3 phút)
**Cải thiện:** 39.4 phút (39.4 phút, 8.8% nhanh hơn)
**Đã loại bỏ (≥TB):** 200_round5

| Metric | Trung Bình | Min | Max | Median | Std Dev |
|--------|-----------|-----|-----|--------|---------|
| Thời Gian (phút) | 406.3 | 398.5 | 411.2 | 410.0 | 5.2 |
| Thời Gian (đọc được) | 6h 46.3m | 6h 38.5m | 6h 51.2m | 6h 50.0m | 5.2 phút |
| CPU (%) | 1231.0 | 1227.0 | 1237.0 | 1229.0 | 3.5 |
| RAM (GB) | 21.21 | 21.01 | 21.40 | 21.14 | 0.14 |
| Thời Gian CPU (h) | 80.83 | 78.95 | 81.71 | 81.38 | 0.97 |

### N = 500
**Số runs tốt (nhỏ hơn TB):** 8
**Trung bình tất cả runs:** 17h 56.3m (1076.3 phút)
**Trung bình runs tốt:** 15h 42.4m (942.4 phút)
**Cải thiện:** 2h 13.9m (133.9 phút, 12.4% nhanh hơn)
**Đã loại bỏ (≥TB):** 500_round4, 500_round5

| Metric | Trung Bình | Min | Max | Median | Std Dev |
|--------|-----------|-----|-----|--------|---------|
| Thời Gian (phút) | 942.4 | 926.4 | 953.8 | 949.0 | 11.5 |
| Thời Gian (đọc được) | 15h 42.4m | 15h 26.4m | 15h 53.8m | 15h 49.0m | 11.5 phút |
| CPU (%) | 1259.4 | 1254.0 | 1274.0 | 1257.0 | 6.4 |
| RAM (GB) | 22.44 | 22.24 | 22.63 | 22.44 | 0.12 |
| Thời Gian CPU (h) | 191.89 | 189.49 | 193.54 | 192.62 | 1.66 |

### N = 700
**Số runs tốt (nhỏ hơn TB):** 8
**Trung bình tất cả runs:** 24h 4.1m (1444.1 phút)
**Trung bình runs tốt:** 21h 38.8m (1298.8 phút)
**Cải thiện:** 2h 25.4m (145.4 phút, 10.1% nhanh hơn)
**Đã loại bỏ (≥TB):** 700_round4, 700_round5

| Metric | Trung Bình | Min | Max | Median | Std Dev |
|--------|-----------|-----|-----|--------|---------|
| Thời Gian (phút) | 1298.8 | 1281.3 | 1313.0 | 1304.2 | 11.5 |
| Thời Gian (đọc được) | 21h 38.8m | 21h 21.3m | 21h 53.0m | 21h 44.2m | 11.5 phút |
| CPU (%) | 1259.2 | 1250.0 | 1272.0 | 1255.5 | 10.0 |
| RAM (GB) | 22.62 | 22.42 | 22.82 | 22.64 | 0.13 |
| Thời Gian CPU (h) | 264.22 | 263.28 | 267.34 | 263.65 | 1.37 |

---

## 📋 Tóm Tắt

- **Tổng số runs tốt (nhỏ hơn TB):** 54
- **Tổng số runs đã loại bỏ (≥TB):** 26
- **Tỷ lệ runs tốt:** 67.5%

**Định nghĩa:**
- **Run tốt:** Wall time < Trung bình của tất cả 10 runs
- **Run loại bỏ:** Wall time ≥ Trung bình của tất cả 10 runs
