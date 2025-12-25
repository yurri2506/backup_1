# 🎯 HƯỚNG DẪN SỬ DỤNG TMUX - AggSandbox Experiments

## 📋 TỔNG QUAN

Script đang chạy trong tmux session: **`aggsandbox_experiments`**

## 🚀 LỆNH CƠ BẢN

### Attach vào session (Xem script đang chạy)
```bash
tmux attach -t aggsandbox_experiments
```

### Detach khỏi session (Thoát nhưng vẫn chạy)
```
Nhấn: Ctrl+B, sau đó nhấn D
```
Hoặc:
```bash
tmux detach
```

### Xem danh sách sessions
```bash
tmux list-sessions
```

### Xem log trong session (không cần attach)
```bash
tmux capture-pane -t aggsandbox_experiments -p | tail -50
```

### Kill session (Dừng script)
```bash
tmux kill-session -t aggsandbox_experiments
```

## 📊 THEO DÕI TIẾN TRÌNH

### Xem log file
```bash
# Log chính
tail -f logs/aggsandbox_exp/run.log

# Summary
cat logs/aggsandbox_exp/summary.txt

# Output của script
tail -f logs/aggsandbox_exp/run_all_output_*.log
```

### Xem output trong tmux (không attach)
```bash
tmux capture-pane -t aggsandbox_experiments -p
```

### Kiểm tra process
```bash
ps aux | grep run_all.sh
```

## 🎮 TMUX SHORTCUTS (Khi đã attach)

### Điều hướng
- `Ctrl+B` + `[` : Vào copy mode (scroll)
- `Ctrl+B` + `]` : Paste
- `Ctrl+B` + `D` : Detach (giữ script chạy)
- `Q` : Thoát copy mode

### Trong Copy Mode
- `Space` : Bắt đầu selection
- `Enter` : Copy selection
- Arrow keys : Di chuyển
- `/` : Tìm kiếm

## 🔍 XEM LOGS CỤ THỂ

### Xem log của test cụ thể
```bash
# Baseline N=1
tail -f logs/aggsandbox_exp/baseline_n1_*.log

# V5 N=50
tail -f logs/aggsandbox_exp/v5_n50_*.log
```

### Xem proof files
```bash
ls -lh logs/aggsandbox_exp/baseline/proofs/
ls -lh logs/aggsandbox_exp/v5/proofs/
```

## 📋 TẠO SESSION MỚI (Nếu cần)

```bash
# Tạo session mới và chạy script
tmux new-session -d -s aggsandbox_experiments
tmux send-keys -t aggsandbox_experiments "cd /home/ubuntu/thanhhuyen && bash scripts/aggsandbox/run_all.sh" Enter
tmux attach -t aggsandbox_experiments
```

Hoặc dùng script helper:
```bash
./scripts/aggsandbox/run_in_tmux.sh
```

## ⚠️ LƯU Ý

1. **Detach không dừng script**: Khi detach, script vẫn tiếp tục chạy trong background
2. **Kill session sẽ dừng script**: Dùng cẩn thận!
3. **Log files được lưu riêng**: Có thể xem logs mà không cần attach vào tmux
4. **Summary file được append**: Kết quả sẽ được thêm vào file, không bị ghi đè

## 🎯 WORKFLOW KHUYẾN NGHỊ

1. **Bắt đầu**: Script đã chạy trong tmux
2. **Theo dõi**: `tail -f logs/aggsandbox_exp/run.log` hoặc attach vào tmux
3. **Kiểm tra**: Xem summary file để biết tiến độ
4. **Khi xong**: Attach vào tmux để xem kết quả cuối cùng

---
*Cập nhật: 14:45 UTC, 02/12/2025*


