#!/bin/bash
# Xóa tất cả tmux sessions liên quan đến V5

echo "🧹 Cleaning up old tmux sessions..."

# List all tmux sessions
tmux list-sessions 2>/dev/null | while read -r line; do
    session_name=$(echo "$line" | cut -d: -f1)
    echo "Killing session: $session_name"
    tmux kill-session -t "$session_name" 2>/dev/null || true
done

echo "✅ All tmux sessions cleaned up"
tmux list-sessions 2>/dev/null || echo "No tmux sessions remaining"

