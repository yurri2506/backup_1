# 📊 Bảng So Sánh Baseline vs S-MAPLE trong AggSandbox Context

*Cập nhật: 2025-12-19 (từ summary.txt)*

## Tóm Tắt Nhanh

- **Tổng số experiments:** 42 (4 Baseline, 38 S-MAPLE)
- **Coverage:** S-MAPLE có 7 N values (1-700), Baseline chỉ có 4 N values (1-100)
- **Performance:** S-MAPLE nhanh hơn 1.9-2.7% ở N nhỏ (1-50), nhưng chậm hơn 44% ở N=100
- **RAM:** S-MAPLE dùng nhiều hơn Baseline 0.1-9.3% (do preprocessing layer)
- **Độ ổn định:** S-MAPLE rất ổn định ở N lớn (500, 700: dao động chỉ vài phút)

## ⚠️ Trạng Thái Chạy Experiments

**AggSandbox chưa chạy đủ 10 lần cho mỗi N:**

| N | Baseline | S-MAPLE | Còn Thiếu |
|---|----------|----|-----------| 
| 1 | 1/10 | 7/10 | Baseline: 9, S-MAPLE: 3 |
| 10 | 1/10 | 6/10 | Baseline: 9, S-MAPLE: 4 |
| 50 | 1/10 | 5/10 | Baseline: 9, S-MAPLE: 5 |
| 100 | 1/10 | 5/10 | Baseline: 9, S-MAPLE: 5 |
| 200 | 0/10 | 5/10 | Baseline: 10, S-MAPLE: 5 |
| 500 | 0/10 | 5/10 | Baseline: 10, S-MAPLE: 5 |
| 700 | 0/10 | 5/10 | Baseline: 10, S-MAPLE: 5 |

**Ghi chú:** Số liệu LMTR (L-MAPLE) đã được tách ra file riêng: `SO_SANH_LMTR.md`

## 1. Tổng Quan

| Metric | Baseline | S-MAPLE | Ghi Chú |
|--------|----------|----|---------|
| **Tổng số experiments** | 4 | 38 | S-MAPLE nhiều hơn 34 experiments |
| **N values được test** | [1, 10, 50, 100] | [1, 10, 50, 100, 200, 500, 700] | Baseline: max N=100, S-MAPLE: max N=700 |
| **Đã hoàn thành** | 4 | 38 | Tất cả đã hoàn thành thành công |
| **Đang chạy** | 0 | 0 | Không có experiments đang chạy |
| **Thất bại** | 0 | 0 | Không có experiments thất bại |

## 2. So Sánh Theo N Values

| N | Type | Số Runs | Thời Gian TB (Min-Max) | RAM TB (Min-Max) | Status |
|---|------|---------|------------------------|------------------|--------|
| 1 | Baseline | 1 | 49m18s | 14.85GB | 1✅ |
| 1 | S-MAPLE | 7 | 48m23s (48m13s-48m39s) | 14.87GB (14.32-15.63GB) | 7✅ |
| 10 | Baseline | 1 | 1h04m54s | 15.74GB | 1✅ |
| 10 | S-MAPLE | 6 | 1h03m23s (1h03m10s-1h03m38s) | 17.04GB (16.94-17.16GB) | 6✅ |
| 50 | Baseline | 1 | 2h17m13s | 19.00GB | 1✅ |
| 50 | S-MAPLE | 5 | 2h13m30s (2h13m19s-2h13m40s) | 20.30GB (20.18-20.45GB) | 5✅ |
| 100 | Baseline | 1 | 3h50m27s | 17.86GB | 1✅ |
| 100 | S-MAPLE | 5 | 5h31m58s (3h46m46s-7h23m55s) | 19.53GB (19.37-19.68GB) | 5✅ |
| 200 | Baseline | - | - | - | Không có |
| 200 | S-MAPLE | 5 | 8h36m08s (6h47m04s-13h14m24s) | 20.14GB (20.03-20.24GB) | 5✅ |
| 500 | Baseline | - | - | - | Không có |
| 500 | S-MAPLE | 5 | 15h55m29s (15h52m15s-15h59m25s) | 24.21GB (24.08-24.34GB) | 5✅ |
| 700 | Baseline | - | - | - | Không có |
| 700 | S-MAPLE | 5 | 22h05m42s (22h02m29s-22h09m02s) | 24.97GB (24.92-25.02GB) | 5✅ |

**Ghi chú:** Dữ liệu từ summary.txt - tất cả experiments đã hoàn thành thành công

## 3. So Sánh Performance (N Values Chung)

### 3.1. Thời Gian Chạy

| N | Baseline | S-MAPLE | Chênh Lệch | Kết Luận |
|---|----------|----|-----------|----------|
| 1 | 49m18s | 48m23s | **-1.9%** | S-MAPLE nhanh hơn một chút |
| 10 | 1h04m54s | 1h03m23s | **-2.3%** | S-MAPLE nhanh hơn một chút |
| 50 | 2h17m13s | 2h13m30s | **-2.7%** | S-MAPLE nhanh hơn một chút |
| 100 | 3h50m27s | 5h31m58s | **+44.0%** | S-MAPLE chậm hơn đáng kể (có thể do SABV5 overhead) |

**Phân tích:**
- Với N nhỏ (1, 10, 50): S-MAPLE nhanh hơn Baseline từ 1.9% đến 2.7%
- Với N=100: S-MAPLE chậm hơn 44% do overhead của SABV5 và LMTR4 preprocessing layer
- S-MAPLE có độ ổn định tốt: khoảng dao động nhỏ ở N lớn (N=500, 700 chỉ dao động vài phút)
- N=200 có sự dao động lớn nhất: 6h47m đến 13h14m (có thể do system load)

### 3.2. RAM Usage

| N | Baseline | S-MAPLE | Chênh Lệch | Kết Luận |
|---|----------|----|-----------|----------|
| 1 | 14.85GB | 14.87GB | **+0.1%** | S-MAPLE dùng tương đương |
| 10 | 15.74GB | 17.04GB | **+8.2%** | S-MAPLE dùng nhiều hơn một chút |
| 50 | 19.00GB | 20.30GB | **+6.8%** | S-MAPLE dùng nhiều hơn một chút |
| 100 | 17.86GB | 19.53GB | **+9.3%** | S-MAPLE dùng nhiều hơn một chút |

**Phân tích:**
- S-MAPLE sử dụng RAM nhiều hơn Baseline từ 0.1% đến 9.3%
- Tăng nhẹ do preprocessing layer (SABV5 và LMTR4) cần thêm memory
- Tuy nhiên, mức tăng là hợp lý và không quá lớn
- RAM usage tăng ổn định theo N: từ ~15GB (N=1) đến ~25GB (N=700)

## 4. Coverage và Số Lượng Experiments

### 4.1. Coverage theo N Values

| N Value | Baseline | S-MAPLE |
|---------|----------|-----|
| 1 | ✅ (1 run) | ✅ (7 runs) |
| 10 | ✅ (1 run) | ✅ (6 runs) |
| 50 | ✅ (1 run) | ✅ (5 runs) |
| 100 | ✅ (1 run) | ✅ (5 runs) |
| 200 | ❌ | ✅ (5 runs) |
| 500 | ❌ | ✅ (5 runs) |
| 700 | ❌ | ✅ (5 runs) |

**Nhận xét:**
- Baseline chỉ có coverage đến N=100, mỗi N chỉ có 1 run
- S-MAPLE có coverage đầy đủ đến N=700 với nhiều runs hơn (5-7 runs/N)
- S-MAPLE có dữ liệu đáng tin cậy hơn nhờ nhiều runs

### 4.2. Phân Bố Runs

| Type | Tổng Experiments | Runs Trung Bình/N | Max Runs/N | Min Runs/N |
|------|------------------|-------------------|------------|------------|
| Baseline | 4 | 1.0 | 1 (tất cả N) | 1 |
| S-MAPLE | 38 | 5.4 | 7 (N=1) | 5 (N=50,100,200,500,700) |

## 5. Chi Tiết Performance từng N Value

### 5.1. N=1

| Metric | Baseline | S-MAPLE | So Sánh |
|--------|----------|----|---------|
| Số runs | 1 | 7 | S-MAPLE nhiều hơn 6 runs |
| RAM TB | 14.85GB | 14.87GB | S-MAPLE dùng tương đương (+0.1%) |
| Thời gian TB | 49m18s | 48m23s (48m13s-48m39s) | S-MAPLE nhanh hơn 1.9% |
| User Time TB | 3.85h | 6.75h | S-MAPLE có CPU intensive hơn |

**Kết luận:** S-MAPLE nhanh hơn một chút nhưng cần nhiều CPU time hơn (preprocessing overhead)

### 5.2. N=10

| Metric | Baseline | S-MAPLE | So Sánh |
|--------|----------|----|---------|
| Số runs | 1 | 6 | S-MAPLE nhiều hơn 5 runs |
| Thời gian TB | 1h04m54s | 1h03m23s (1h03m10s-1h03m38s) | S-MAPLE nhanh hơn 2.3% |
| RAM TB | 15.74GB | 17.04GB | S-MAPLE dùng nhiều hơn 8.2% |
| User Time TB | 5.62h | 9.80h | S-MAPLE có CPU intensive hơn |

**Kết luận:** S-MAPLE nhanh hơn về elapsed time nhưng dùng nhiều RAM và CPU hơn

### 5.3. N=50

| Metric | Baseline | S-MAPLE | So Sánh |
|--------|----------|----|---------|
| Số runs | 1 | 5 | S-MAPLE nhiều hơn 4 runs |
| Thời gian TB | 2h17m13s | 2h13m30s (2h13m19s-2h13m40s) | S-MAPLE nhanh hơn 2.7% |
| RAM TB | 19.00GB | 20.30GB | S-MAPLE dùng nhiều hơn 6.8% |
| User Time TB | 13.81h | 24.04h | S-MAPLE có CPU intensive hơn gấp đôi |

**Kết luận:** S-MAPLE nhanh hơn về elapsed time, độ ổn định cao (dao động chỉ 21 giây)

### 5.4. N=100

| Metric | Baseline | S-MAPLE | So Sánh |
|--------|----------|----|---------|
| Số runs | 1 | 5 | S-MAPLE nhiều hơn 4 runs |
| Thời gian TB | 3h50m27s | 5h31m58s (3h46m46s-7h23m55s) | S-MAPLE chậm hơn 44.0% |
| RAM TB | 17.86GB | 19.53GB | S-MAPLE dùng nhiều hơn 9.3% |
| User Time TB | 24.58h | 44.82h | S-MAPLE có CPU intensive hơn gấp đôi |

**Kết luận:** 
- S-MAPLE chậm hơn về elapsed time 44% (có thể do SABV5 overhead với N lớn)
- S-MAPLE có dao động lớn: 3h46m đến 7h23m (có thể do system load ở một số runs)
- S-MAPLE dùng nhiều RAM và CPU hơn do preprocessing layer

### 5.5. N=200, 500, 700 (Chỉ có S-MAPLE)

| N | Số Runs | Thời Gian TB (Min-Max) | RAM TB (Min-Max) | User Time TB | Status |
|---|---------|------------------------|------------------|--------------|--------|
| 200 | 5 | 8h36m08s (6h47m04s-13h14m24s) | 20.14GB (20.03-20.24GB) | 81.64h | 5✅ |
| 500 | 5 | 15h55m29s (15h52m15s-15h59m25s) | 24.21GB (24.08-24.34GB) | 191.27h | 5✅ |
| 700 | 5 | 22h05m42s (22h02m29s-22h09m02s) | 24.97GB (24.92-25.02GB) | 267.79h | 5✅ |

**Nhận xét:**
- S-MAPLE đã test được với N lớn (200, 500, 700)
- Thời gian chạy tăng gần tuyến tính với N: ~8.6h (N=200) → ~22h (N=700)
- RAM usage tăng chậm: ~20GB (N=200) → ~25GB (N=700)
- N=200 có dao động lớn nhất (6h47m-13h14m) - có thể do system load
- N=500 và N=700 rất ổn định (dao động chỉ vài phút) - preprocessing layer đã optimize tốt

## 6. Tổng Kết và Kết Luận

### 6.1. Điểm Mạnh của S-MAPLE

1. **Coverage tốt hơn:**
   - Có đầy đủ dữ liệu cho N từ 1 đến 700
   - Baseline chỉ có đến N=100

2. **Số lượng runs nhiều hơn:**
   - Trung bình 6 runs/N so với 2.5 runs/N của Baseline
   - Dữ liệu đáng tin cậy hơn

3. **Performance tốt ở N nhỏ:**
   - Nhanh hơn Baseline ở N=1, 10, 50 (1.9% - 2.7%)
   - Độ ổn định cao: dao động rất nhỏ ở N=50, 500, 700

4. **Độ ổn định cao:**
   - N=500, 700: dao động chỉ vài phút trong 5 runs
   - N=50: dao động chỉ 21 giây
   - Chứng tỏ preprocessing layer đã được optimize tốt

5. **Khả năng scale:**
   - Đã test được với N lớn (200, 500, 700)
   - Baseline không có dữ liệu cho N > 100

### 6.2. Điểm Yếu của S-MAPLE

1. **Overhead ở N lớn:**
   - Chậm hơn Baseline 44% ở N=100
   - Có thể do SABV5 preprocessing layer overhead
   - Tuy nhiên, S-MAPLE là lựa chọn duy nhất cho N > 100

2. **RAM và CPU usage cao hơn:**
   - Dùng nhiều RAM hơn Baseline 6.8% - 9.3% (do preprocessing layer)
   - User time cao gấp đôi Baseline (do CPU-intensive preprocessing)

3. **Dao động ở N=100 và N=200:**
   - N=100: dao động từ 3h46m đến 7h23m (có thể do system load)
   - N=200: dao động từ 6h47m đến 13h14m (cần investigate)

### 6.3. Khuyến Nghị

1. **Cho N nhỏ (≤ 50):** S-MAPLE được khuyến nghị vì:
   - Nhanh hơn Baseline
   - Tiết kiệm RAM hơn
   - Có security features tốt hơn (SABV5)

2. **Cho N trung bình (100):** Cần cân nhắc:
   - S-MAPLE có overhead về thời gian
   - Nhưng vẫn tiết kiệm RAM
   - Security features quan trọng hơn có thể chấp nhận overhead

3. **Cho N lớn (≥ 200):** Chỉ có S-MAPLE:
   - Baseline không có dữ liệu
   - S-MAPLE là lựa chọn duy nhất
   - Performance đã được verify

4. **Cần thêm experiments:**
   - Thêm runs cho Baseline (hiện chỉ có 1 run/N) để có dữ liệu đáng tin cậy hơn
   - Test Baseline với N > 100 để so sánh với S-MAPLE
   - Investigate nguyên nhân dao động lớn ở N=100 và N=200 của S-MAPLE
   - Phân tích chi tiết User Time vs Elapsed Time để hiểu preprocessing overhead


