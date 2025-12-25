# 📊 Thống Kê AggSandbox Experiments

*Cập nhật: 2025-12-25 00:51:30*

**Tổng số experiments:** 42 (tất cả đã hoàn thành thành công)

## 1. Tổng Quan Theo Type

| Type | Số Experiments | Hoàn Thành | Đang Chạy | Thất Bại |
|------|----------------|------------|-----------|----------|
| Baseline | 4 | 4 | 0 | 0 |
| S-MAPLE (S-MAPLE) | 38 | 38 | 0 | 0 |
| **Tổng** | **42** | **42** | **0** | **0** |

**Tỷ lệ thành công:** 100% (42/42)

## 2. Phân Bố Theo N Values

| N | Baseline Runs | S-MAPLE Runs | Tổng Runs | Hoàn Thành | Target (10 runs/N) |
|---|---------------|---------|-----------|------------|-------------------|
| 1 | 1 | 7 | 8 | 8/8 | ❌ Thiếu 2 runs |
| 10 | 1 | 6 | 7 | 7/7 | ❌ Thiếu 3 runs |
| 50 | 1 | 5 | 6 | 6/6 | ❌ Thiếu 4 runs |
| 100 | 1 | 5 | 6 | 6/6 | ❌ Thiếu 4 runs |
| 200 | 0 | 5 | 5 | 5/5 | ❌ Thiếu 5 runs |
| 500 | 0 | 5 | 5 | 5/5 | ❌ Thiếu 5 runs |
| 700 | 0 | 5 | 5 | 5/5 | ❌ Thiếu 5 runs |

**Ghi chú:** Mục tiêu là 10 runs cho mỗi N (5 Baseline + 5 S-MAPLE), hiện tại chưa đạt đủ.

## 3. Chi Tiết Theo N Values

### N=1

**Baseline:**
- Số runs: 1 (Hoàn thành: 1) ✅
- Thời gian: TB 49m18s (49m18s - 49m18s)
- RAM: TB 14.85GB (14.85GB - 14.85GB)
- User Time: TB 3.85h
- System Time: TB 0.11h

**S-MAPLE (S-MAPLE):**
- Số runs: 7 (Hoàn thành: 7) ✅
- Thời gian: TB 48m22s (48m13s - 48m39s)
- RAM: TB 14.87GB (14.32GB - 15.63GB)
- User Time: TB 6.75h
- System Time: TB 0.22h

**So Sánh:**
- ✅ S-MAPLE nhanh hơn Baseline **1.9%** về thời gian
- ⚠️ S-MAPLE dùng nhiều hơn Baseline **0.1%** về RAM (gần tương đương)
- ⚠️ S-MAPLE dùng User Time cao hơn Baseline **75%** (6.75h vs 3.85h)

**Kết luận:** S-MAPLE nhanh hơn một chút về elapsed time nhưng tốn CPU hơn đáng kể.

### N=10

**Baseline:**
- Số runs: 1 (Hoàn thành: 1) ✅
- Thời gian: TB 1h04m54s (1h04m54s - 1h04m54s)
- RAM: TB 15.74GB (15.74GB - 15.74GB)
- User Time: TB 5.62h
- System Time: TB 0.18h

**S-MAPLE (S-MAPLE):**
- Số runs: 6 (Hoàn thành: 6) ✅
- Thời gian: TB 1h03m23s (1h03m10s - 1h03m38s)
- RAM: TB 17.04GB (16.94GB - 17.16GB)
- User Time: TB 9.80h
- System Time: TB 0.33h

**So Sánh:**
- ✅ S-MAPLE nhanh hơn Baseline **2.3%** về thời gian
- ⚠️ S-MAPLE dùng nhiều hơn Baseline **8.2%** về RAM
- ⚠️ S-MAPLE dùng User Time cao hơn Baseline **74%** (9.80h vs 5.62h)

**Kết luận:** S-MAPLE nhanh hơn một chút nhưng dùng nhiều RAM và CPU hơn.

### N=50

**Baseline:**
- Số runs: 1 (Hoàn thành: 1) ✅
- Thời gian: TB 2h17m13s (2h17m13s - 2h17m13s)
- RAM: TB 19.00GB (19.00GB - 19.00GB)
- User Time: TB 13.81h
- System Time: TB 0.48h

**S-MAPLE (S-MAPLE):**
- Số runs: 5 (Hoàn thành: 5) ✅
- Thời gian: TB 2h13m30s (2h13m19s - 2h13m40s)
- RAM: TB 20.30GB (20.18GB - 20.45GB)
- User Time: TB 24.04h
- System Time: TB 0.87h

**So Sánh:**
- ✅ S-MAPLE nhanh hơn Baseline **2.7%** về thời gian
- ⚠️ S-MAPLE dùng nhiều hơn Baseline **6.8%** về RAM
- ⚠️ S-MAPLE dùng User Time cao hơn Baseline **74%** (24.04h vs 13.81h)
- ✅ S-MAPLE có độ ổn định cao: dao động chỉ **21 giây** (2h13m19s - 2h13m40s)

**Kết luận:** S-MAPLE nhanh hơn, ổn định hơn nhưng tốn RAM và CPU hơn.

### N=100

**Baseline:**
- Số runs: 1 (Hoàn thành: 1) ✅
- Thời gian: TB 3h50m27s (3h50m27s - 3h50m27s)
- RAM: TB 17.86GB (17.86GB - 17.86GB)
- User Time: TB 24.58h
- System Time: TB 0.78h

**S-MAPLE (S-MAPLE):**
- Số runs: 5 (Hoàn thành: 5) ✅
- Thời gian: TB 5h31m57s (3h46m46s - 7h23m55s)
- RAM: TB 19.53GB (19.37GB - 19.68GB)
- User Time: TB 44.82h
- System Time: TB 1.75h

**So Sánh:**
- ❌ S-MAPLE chậm hơn Baseline **44.0%** về thời gian
- ⚠️ S-MAPLE dùng nhiều hơn Baseline **9.3%** về RAM
- ⚠️ S-MAPLE dùng User Time cao hơn Baseline **82%** (44.82h vs 24.58h)
- ⚠️ S-MAPLE có dao động lớn: **3h37m09s** (3h46m46s - 7h23m55s)

**Kết luận:** 
- S-MAPLE chậm hơn đáng kể ở N=100 (có thể do SABV5 overhead)
- Dao động lớn có thể do system load ở một số runs
- S-MAPLE vẫn tốn RAM và CPU hơn Baseline

### N=200

**S-MAPLE (S-MAPLE):**
- Số runs: 5 (Hoàn thành: 5) ✅
- Thời gian: TB 8h36m07s (6h47m04s - 13h14m24s)
- RAM: TB 20.14GB (20.03GB - 20.24GB)
- User Time: TB 81.64h
- System Time: TB 3.29h

**Phân tích:**
- ⚠️ Dao động lớn nhất: **6h27m20s** (6h47m04s - 13h14m24s)
- Có thể do system load hoặc memory pressure ở một số runs
- RAM usage ổn định: dao động chỉ 0.21GB

### N=500

**S-MAPLE (S-MAPLE):**
- Số runs: 5 (Hoàn thành: 5) ✅
- Thời gian: TB 15h55m28s (15h52m15s - 15h59m25s)
- RAM: TB 24.21GB (24.08GB - 24.34GB)
- User Time: TB 191.27h
- System Time: TB 7.01h

**Phân tích:**
- ✅ Rất ổn định: dao động chỉ **7 phút 10 giây** (15h52m15s - 15h59m25s)
- RAM usage ổn định: dao động chỉ 0.26GB
- Performance nhất quán và đáng tin cậy

### N=700

**S-MAPLE (S-MAPLE):**
- Số runs: 5 (Hoàn thành: 5) ✅
- Thời gian: TB 22h05m41s (22h02m29s - 22h09m02s)
- RAM: TB 24.97GB (24.92GB - 25.02GB)
- User Time: TB 267.79h
- System Time: TB 9.77h

**Phân tích:**
- ✅ Rất ổn định: dao động chỉ **6 phút 33 giây** (22h02m29s - 22h09m02s)
- RAM usage ổn định nhất: dao động chỉ 0.10GB
- Performance nhất quán và đáng tin cậy

## 4. Thống Kê Performance Tổng Hợp

### 4.1. Thời Gian Chạy Trung Bình (chỉ tính completed)

| N | Baseline | S-MAPLE | Chênh Lệch | Kết Luận |
|---|----------|----|-----------|----------|
| 1 | 49m18s | 48m22s | **-1.9%** | ✅ S-MAPLE nhanh hơn |
| 10 | 1h04m54s | 1h03m23s | **-2.3%** | ✅ S-MAPLE nhanh hơn |
| 50 | 2h17m13s | 2h13m30s | **-2.7%** | ✅ S-MAPLE nhanh hơn |
| 100 | 3h50m27s | 5h31m57s | **+44.0%** | ❌ S-MAPLE chậm hơn |
| 200 | - | 8h36m07s | - | Chỉ có S-MAPLE |
| 500 | - | 15h55m28s | - | Chỉ có S-MAPLE |
| 700 | - | 22h05m41s | - | Chỉ có S-MAPLE |

**Phân tích:**
- S-MAPLE nhanh hơn Baseline ở N nhỏ (1, 10, 50): **1.9% - 2.7%**
- S-MAPLE chậm hơn Baseline ở N=100: **44.0%** (có thể do SABV5 overhead)
- S-MAPLE là lựa chọn duy nhất cho N lớn (200, 500, 700)

### 4.2. RAM Usage Trung Bình

| N | Baseline | S-MAPLE | Chênh Lệch | Kết Luận |
|---|----------|----|-----------|----------|
| 1 | 14.85GB | 14.87GB | **+0.1%** | Tương đương |
| 10 | 15.74GB | 17.04GB | **+8.2%** | S-MAPLE dùng nhiều hơn |
| 50 | 19.00GB | 20.30GB | **+6.8%** | S-MAPLE dùng nhiều hơn |
| 100 | 17.86GB | 19.53GB | **+9.3%** | S-MAPLE dùng nhiều hơn |
| 200 | - | 20.14GB | - | Chỉ có S-MAPLE |
| 500 | - | 24.21GB | - | Chỉ có S-MAPLE |
| 700 | - | 24.97GB | - | Chỉ có S-MAPLE |

**Phân tích:**
- S-MAPLE dùng RAM nhiều hơn Baseline từ **0.1% đến 9.3%**
- Tăng nhẹ do preprocessing layer (SABV5 và LMTR4) cần thêm memory
- RAM usage tăng ổn định theo N: từ ~15GB (N=1) đến ~25GB (N=700)

### 4.3. User Time (CPU Time)

| N | Baseline | S-MAPLE | Chênh Lệch |
|---|----------|----|-----------|
| 1 | 3.85h | 6.75h | **+75%** |
| 10 | 5.62h | 9.80h | **+74%** |
| 50 | 13.81h | 24.04h | **+74%** |
| 100 | 24.58h | 44.82h | **+82%** |

**Phân tích:**
- S-MAPLE dùng User Time cao hơn Baseline từ **74% đến 82%**
- Do preprocessing layer (SABV5 và LMTR4) là CPU-intensive
- Tuy nhiên, elapsed time của S-MAPLE lại nhanh hơn ở N nhỏ do parallelization

### 4.4. Độ Ổn Định (Variability)

| N | Type | Min Time | Max Time | Range | CV (Estimated) |
|---|------|----------|----------|-------|----------------|
| 1 | S-MAPLE | 48m13s | 48m39s | 26s | ~0.9% |
| 10 | S-MAPLE | 1h03m10s | 1h03m38s | 28s | ~0.7% |
| 50 | S-MAPLE | 2h13m19s | 2h13m40s | 21s | ~0.3% |
| 100 | S-MAPLE | 3h46m46s | 7h23m55s | 3h37m09s | ~65% |
| 200 | S-MAPLE | 6h47m04s | 13h14m24s | 6h27m20s | ~37% |
| 500 | S-MAPLE | 15h52m15s | 15h59m25s | 7m10s | ~0.1% |
| 700 | S-MAPLE | 22h02m29s | 22h09m02s | 6m33s | ~0.05% |

**Phân tích:**
- S-MAPLE rất ổn định ở N nhỏ (1, 10, 50): dao động < 30 giây
- S-MAPLE rất ổn định ở N lớn (500, 700): dao động chỉ vài phút
- S-MAPLE có dao động lớn ở N=100 và N=200: có thể do system load hoặc memory pressure

## 5. Tổng Kết và Kết Luận

### 5.1. Điểm Mạnh

1. **100% Success Rate:** Tất cả 42 experiments đều hoàn thành thành công
2. **Performance tốt ở N nhỏ:** S-MAPLE nhanh hơn Baseline 1.9-2.7% ở N=1, 10, 50
3. **Độ ổn định cao:** S-MAPLE rất ổn định ở N nhỏ và N lớn (dao động chỉ vài phút)
4. **Khả năng scale:** S-MAPLE đã test được với N lớn (200, 500, 700) mà Baseline không có dữ liệu

### 5.2. Điểm Yếu

1. **Chưa đủ runs:** Chưa đạt mục tiêu 10 runs/N (5 Baseline + 5 S-MAPLE)
2. **Overhead ở N=100:** S-MAPLE chậm hơn Baseline 44% (có thể do SABV5 overhead)
3. **RAM và CPU usage cao:** S-MAPLE dùng nhiều RAM (0.1-9.3%) và CPU (74-82%) hơn Baseline
4. **Dao động lớn ở N=100 và N=200:** Cần investigate nguyên nhân

### 5.3. Khuyến Nghị

1. **Tiếp tục chạy experiments để đạt mục tiêu 10 runs/N:**
   - N=1: Cần thêm 2 runs (1 Baseline + 1 S-MAPLE)
   - N=10: Cần thêm 3 runs (1 Baseline + 2 S-MAPLE)
   - N=50, 100: Cần thêm 4 runs mỗi N (4 Baseline + 0 S-MAPLE)
   - N=200, 500, 700: Cần thêm 5 runs mỗi N (5 Baseline + 0 S-MAPLE)

2. **Investigate nguyên nhân dao động lớn ở N=100 và N=200:**
   - Kiểm tra system load tại thời điểm chạy
   - Kiểm tra memory pressure
   - Có thể cần chạy lại các runs có thời gian bất thường

3. **Phân tích chi tiết User Time vs Elapsed Time:**
   - Hiểu rõ hơn về preprocessing overhead
   - Tối ưu hóa parallelization

4. **Cho production:**
   - **N ≤ 50:** S-MAPLE được khuyến nghị (nhanh hơn, ổn định)
   - **N = 100:** Cần cân nhắc (chậm hơn nhưng có security features)
   - **N ≥ 200:** Chỉ có S-MAPLE (Baseline không có dữ liệu)
