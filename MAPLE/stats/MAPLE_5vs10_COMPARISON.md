# 📊 So Sánh 5 Runs Đầu vs 10 Runs (Trung Bình)

**Mục đích:** Kiểm tra xem số liệu trung bình 10 runs có tốt hơn (nhỏ hơn cho thời gian) so với 5 runs đầu không

---

## So Sánh Wall Time (Thời Gian Thực Tế)

| N | 5 Runs TB | 10 Runs TB | Chênh Lệch | % Thay Đổi | Nhận Xét |
|---|-----------|------------|------------|------------|----------|
| 1 | 5:13:14 | 3:10:14 | -2:02:59 | -39.3% | ✅ 10 runs NHỎ HƠN (tốt hơn) |
| 10 | 7:55:30 | 4:39:16 | -3:16:13 | -41.3% | ✅ 10 runs NHỎ HƠN (tốt hơn) |
| 20 | 10:33:01 | 10:41:23 | +0:08:22 | +1.3% | ⚠️ 10 runs LỚN HƠN (chậm hơn) |
| 50 | 19:32:01 | 11:52:52 | -7:39:09 | -39.2% | ✅ 10 runs NHỎ HƠN (tốt hơn) |
| 100 | 5:31:21 | 4:57:38 | -0:33:43 | -10.2% | ✅ 10 runs NHỎ HƠN (tốt hơn) |
| 200 | 6:50:32 | 7:25:43 | +0:35:11 | +8.6% | ⚠️ 10 runs LỚN HƠN (chậm hơn) |
| 500 | 15:50:36 | 17:56:16 | +2:05:40 | +13.2% | ⚠️ 10 runs LỚN HƠN (chậm hơn) |
| 700 | 21:46:41 | 24:04:07 | +2:17:25 | +10.5% | ⚠️ 10 runs LỚN HƠN (chậm hơn) |

---

## So Sánh CPU Usage (%)

| N | 5 Runs TB | 10 Runs TB | Chênh Lệch | % Thay Đổi | Nhận Xét |
|---|-----------|------------|------------|------------|----------|
| 1 | 181.4% | 455.4% | +274.0% | +151.0% | ✅ 10 runs CAO HƠN (tốt hơn - parallelization tốt) |
| 10 | 153.4% | 481.6% | +328.2% | +214.0% | ✅ 10 runs CAO HƠN (tốt hơn - parallelization tốt) |
| 20 | 153.0% | 152.7% | -0.3% | -0.2% | ⚠️ 10 runs THẤP HƠN (kém hơn) |
| 50 | 154.8% | 398.0% | +243.2% | +157.1% | ✅ 10 runs CAO HƠN (tốt hơn - parallelization tốt) |
| 100 | 1029.2% | 1059.9% | +30.7% | +3.0% | ✅ 10 runs CAO HƠN (tốt hơn - parallelization tốt) |
| 200 | 1229.4% | 1176.8% | -52.6% | -4.3% | ⚠️ 10 runs THẤP HƠN (kém hơn) |
| 500 | 1255.8% | 1166.3% | -89.5% | -7.1% | ⚠️ 10 runs THẤP HƠN (kém hơn) |
| 700 | 1252.4% | 1185.8% | -66.6% | -5.3% | ⚠️ 10 runs THẤP HƠN (kém hơn) |

---

## So Sánh RAM Usage (GB)

| N | 5 Runs TB | 10 Runs TB | Chênh Lệch | % Thay Đổi |
|---|-----------|------------|------------|------------|
| 1 | 15.82 | 15.53 | -0.29 | -1.8% |
| 10 | 17.07 | 17.02 | -0.05 | -0.3% |
| 20 | 19.78 | 19.71 | -0.07 | -0.4% |
| 50 | 20.09 | 20.20 | +0.11 | +0.5% |
| 100 | 20.08 | 20.20 | +0.12 | +0.6% |
| 200 | 21.14 | 21.22 | +0.08 | +0.4% |
| 500 | 22.43 | 22.42 | -0.01 | -0.0% |
| 700 | 22.63 | 22.64 | +0.01 | +0.1% |

---

## So Sánh User Time (CPU Time, giờ)

| N | 5 Runs TB | 10 Runs TB | Chênh Lệch | % Thay Đổi |
|---|-----------|------------|------------|------------|
| 1 | 7.88h | 7.50h | -0.39h | -4.9% |
| 10 | 11.76h | 10.90h | -0.86h | -7.3% |
| 20 | 15.61h | 15.76h | +0.15h | +1.0% |
| 50 | 29.29h | 27.74h | -1.55h | -5.3% |
| 100 | 44.34h | 44.09h | -0.25h | -0.6% |
| 200 | 81.57h | 81.63h | +0.06h | +0.1% |
| 500 | 193.03h | 194.32h | +1.29h | +0.7% |
| 700 | 264.24h | 266.93h | +2.69h | +1.0% |

---

## 📊 Tóm Tắt

**Wall Time:**
- 10 runs NHỎ HƠN 5 runs: 4/8 N values (tốt hơn)
- 10 runs LỚN HƠN 5 runs: 4/8 N values (chậm hơn)
- Bằng nhau: 0/8

**CPU Usage:**
- 10 runs CAO HƠN 5 runs: 4/8 N values (tốt hơn)
- 10 runs THẤP HƠN 5 runs: 4/8 N values (kém hơn)

### Kết Luận

✅ **Trung bình, 10 runs NHỎ HƠN 5 runs khoảng 12.0%**
   → Số liệu 10 runs TỐT HƠN (nhanh hơn) so với 5 runs đầu

**Giải thích:**
- Nếu 10 runs nhỏ hơn: Có thể 5 runs đầu có outliers chậm, 10 runs đã loại bỏ được
- Nếu 10 runs lớn hơn: Có thể 5 runs đầu may mắn chạy nhanh, 10 runs phản ánh đúng hơn
- Thông thường, 10 runs sẽ ổn định hơn và phản ánh performance thực tế tốt hơn
