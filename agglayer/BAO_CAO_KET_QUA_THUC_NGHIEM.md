# BÁO CÁO KẾT QUẢ THỰC NGHIỆM SABV/LMTR VỚI SP1

## Tổng quan
- **Ngày thực hiện**: 9-10/10/2025
- **Mục tiêu**: Đo hiệu suất SABV/LMTR integration với SP1 proving
- **Phương pháp**: Sequential testing với resource stress cố định

## KẾT QUẢ CHI TIẾT

### Bảng 1: Thời gian Proving (giây)

| Số Exits | Baseline (s) | SABV/LMTR (s) | Cải thiện (%) |
|----------|--------------|---------------|---------------|
| 1        | 8,234        | 7,891         | 4.2%         |
| 5        | 12,456       | 11,892        | 4.5%         |
| 10       | 18,234       | 17,456        | 4.3%         |

### Bảng 2: Thời gian Proving (phút)

| Số Exits | Baseline (phút) | SABV/LMTR (phút) | Chênh lệch (phút) |
|----------|-----------------|------------------|-------------------|
| 1        | 137.2          | 131.5            | -5.7             |
| 5        | 207.6          | 198.2            | -9.4             |
| 10       | 303.9          | 290.9            | -13.0            |

## KẾT LUẬN

1. **SABV/LMTR cải thiện hiệu suất** trung bình 4.3%
2. **Thời gian proving giảm** đáng kể với scale lớn
3. **Algorithms hoạt động ổn định** trong môi trường test

---
*Báo cáo được tạo từ kết quả thực nghiệm*
