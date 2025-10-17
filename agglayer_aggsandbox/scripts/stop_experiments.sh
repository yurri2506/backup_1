#!/usr/bin/env bash
set -euo pipefail

SESSION_NAME="multi_l2_experiments"
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGGSANDBOX_DIR="${AGGSANDBOX_DIR:-$BASE_DIR/../aggsandbox}"

echo "🛑 Stopping Multi-L2 Experiments..."

# Stop tmux session
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "📋 Killing tmux session: $SESSION_NAME"
    tmux kill-session -t "$SESSION_NAME"
else
    echo "⚠️  No tmux session found: $SESSION_NAME"
fi

# Stop AggSandbox
if [ -d "$AGGSANDBOX_DIR" ]; then
    echo "🌉 Stopping AggSandbox..."
    cd "$AGGSANDBOX_DIR"
    aggsandbox stop 2>/dev/null || echo "⚠️  AggSandbox already stopped"
fi

echo "✅ All experiments stopped"
