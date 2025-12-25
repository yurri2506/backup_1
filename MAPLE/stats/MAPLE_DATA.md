# MAPLE Pessimistic Proof - Số Liệu Thực Nghiệm

**Ngày tạo:** 2025-11-25  
**Thuật toán:** MAPLE (SABMAPLE + LMTR4)  
**Hệ thống proving:** SP1 (CPU-based)

---

## Cấu Hình Thử Nghiệm

- **Các trường hợp test**: N ∈ {1, 10, 100, 200, 500, 700} exits
- **Số lần lặp lại**: Nhiều rounds cho mỗi N (xem bảng dưới)
- **Môi trường**: Linux 6.8.0-57-generic, Rust (release mode)
- **Song song hóa**: RAYON_NUM_THREADS=32, OMP_NUM_THREADS=32, SP1_CORE_OPTS_TRACE_GEN_WORKERS=8

---

## Thống Kê Tổng Hợp

| N | Rounds | Thời Gian TB (Wall) | Thời Gian CPU TB (h) | CPU TB (%) | RAM TB (GB) | Kích Thước Proof TB (MB) |
|---|--------|---------------------|----------------------|------------|-------------|--------------------------|
| 1 | 5 | 1:07:15 | 7.11 | 729.4 | 15.24 | N/A |
| 10 | 3 | 1:01:26 | 9.65 | 969.7 | 16.99 | N/A |
| 100 | 3 | 3:43:40 | 43.07 | 1190.3 | 20.32 | N/A |
| 200 | 3 | 6:41:47 | 80.22 | 1235.0 | 21.34 | N/A |
| 500 | 3 | 15:28:35 | 189.99 | 1265.3 | 22.47 | N/A |
| 700 | 3 | 21:25:33 | 264.18 | 1270.7 | 22.61 | N/A |

---

## Hiệu Suất Theo Từng N

### N = 1
**Số rounds:** 5 (round 1, 2, 3, 4, 5)

| Chỉ Số | Giá Trị |
|--------|---------|
| Thời Gian TB (Wall) | 1:07:15 |
| Thời Gian CPU TB | 7.11 giờ |
| CPU TB | 729.4% |
| RAM TB | 15.24 GB |

### N = 10
**Số rounds:** 3 (round 2, 3, 4)

| Chỉ Số | Giá Trị |
|--------|---------|
| Thời Gian TB (Wall) | 1:01:26 |
| Thời Gian CPU TB | 9.65 giờ |
| CPU TB | 969.7% |
| RAM TB | 16.99 GB |

### N = 100
**Số rounds:** 3 (round 1, 2, 3)

| Chỉ Số | Giá Trị |
|--------|---------|
| Thời Gian TB (Wall) | 3:43:40 |
| Thời Gian CPU TB | 43.07 giờ |
| CPU TB | 1190.3% |
| RAM TB | 20.32 GB |

### N = 200
**Số rounds:** 3 (round 1, 2, 3)

| Chỉ Số | Giá Trị |
|--------|---------|
| Thời Gian TB (Wall) | 6:41:47 |
| Thời Gian CPU TB | 80.22 giờ |
| CPU TB | 1235.0% |
| RAM TB | 21.34 GB |

### N = 500
**Số rounds:** 3 (round 1, 2, 3)

| Chỉ Số | Giá Trị |
|--------|---------|
| Thời Gian TB (Wall) | 15:28:35 |
| Thời Gian CPU TB | 189.99 giờ |
| CPU TB | 1265.3% |
| RAM TB | 22.47 GB |

### N = 700
**Số rounds:** 3 (round 1, 2, 3)

| Chỉ Số | Giá Trị |
|--------|---------|
| Thời Gian TB (Wall) | 21:25:33 |
| Thời Gian CPU TB | 264.18 giờ |
| CPU TB | 1270.7% |
| RAM TB | 22.61 GB |

---

## Kết Quả Phát Hiện Gian Lận

Tất cả các rounds đều pass cả 3 checks phát hiện gian lận:
- ✅ Check 1 (Nhất quán nội bộ): Tỷ lệ pass 100%
- ✅ Check 2 (Toàn vẹn rebalancing): Tỷ lệ pass 100%
- ✅ Check 3 (Toàn vẹn blockchain): Tỷ lệ pass 100%

---

## Trạng Thái Thu Thập Dữ Liệu

- ✅ Thời gian thực (Wall Time): Đã thu thập
- ✅ Thời gian CPU (User Time): Đã thu thập
- ✅ Sử dụng CPU: Đã thu thập
- ✅ Sử dụng RAM: Đã thu thập
- ⏳ Kích thước Proof: Đang thu thập

---

**Cập nhật lần cuối:** 2025-11-25
