# Cấu Trúc Tổ Chức Files

Files đã được tổ chức lại vào các thư mục sau:

## 📁 docs/
Documentation và hướng dẫn

## 📁 reports/
Báo cáo và số liệu từ experiments

## 📁 scripts/experiments/
Scripts để chạy experiments

## 📁 scripts/utils/
Scripts tiện ích

## ⚠️ Lưu Ý

- **Không di chuyển logs/** - Logs đang được sử dụng bởi experiments
- **Không di chuyển khi experiments đang chạy**
- Các scripts có thể được gọi từ tmux sessions - kiểm tra trước khi sửa

## 🔄 Backward Compatibility

Một số file quan trọng có thể có symlinks ở root để đảm bảo scripts cũ vẫn hoạt động.
Nếu cần, tạo symlinks thủ công cho các scripts đang chạy.

## 📝 Cập nhật

Tổ chức lại: $(date)
