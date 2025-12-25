# 📊 Thống Kê Phát Hiện Gian Lận (Fraud Detection)

*Cập nhật: 2025-12-25*

## Tổng Quan

Thống kê khả năng phát hiện gian lận của Baseline và S-MAPLE (V5) khi có wrong global root.

## Kết Quả Chi Tiết

| Type | N | Total Runs | Fraud Detected | Success | Fraud Detection Rate |
|------|---|------------|----------------|---------|---------------------|
| Baseline | 1 | 6 | 0 | 3 | 0.0% |
| Baseline | 10 | 3 | 0 | 3 | 0.0% |
| Baseline | 100 | 3 | 0 | 3 | 0.0% |
| Baseline | 500 | 3 | 0 | 3 | 0.0% |
| Baseline | 700 | 3 | 0 | 3 | 0.0% |
| S-MAPLE | 1 | 3 | 3 | 0 | 100.0% |
| S-MAPLE | 10 | 3 | 3 | 0 | 100.0% |
| S-MAPLE | 100 | 3 | 3 | 0 | 100.0% |
| S-MAPLE | 500 | 3 | 3 | 0 | 100.0% |
| S-MAPLE | 700 | 3 | 3 | 0 | 100.0% |

## Phân Tích

### Baseline

- **Tổng runs:** 18
- **Phát hiện gian lận:** 0 (0.0%)
- **Kết luận:** Baseline không có khả năng phát hiện gian lận

### S-MAPLE (V5)

- **Tổng runs:** 15
- **Phát hiện gian lận:** 15 (100.0%)
- **Kết luận:** S-MAPLE phát hiện gian lận 100% trong các test cases

## So Sánh

| Metric | Baseline | S-MAPLE |
|--------|----------|---------|
| Fraud Detection Rate | 0.0% | 100.0% |
| Khả năng phát hiện | ❌ Không có | ✅ 100% |

**Kết luận:** S-MAPLE có khả năng phát hiện gian lận tốt hơn Baseline đáng kể nhờ SABV5 layer.