#!/usr/bin/env bash
# Script để chạy AggSandbox experiments trong tmux session
# Usage: ./run_in_tmux.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SESSION_NAME="aggsandbox_experiments"
RUN_ALL_SCRIPT="$SCRIPT_DIR/run_all.sh"

# Check if tmux is available
if ! command -v tmux >/dev/null 2>&1; then
    echo "❌ tmux not found. Installing..."
    sudo apt-get update && sudo apt-get install -y tmux || {
        echo "❌ Failed to install tmux"
        exit 1
    }
fi

# Check if session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "⚠️  Session '$SESSION_NAME' already exists"
    echo ""
    echo "Options:"
    echo "  1. Attach to existing session: tmux attach -t $SESSION_NAME"
    echo "  2. Kill existing session and create new: tmux kill-session -t $SESSION_NAME && $0"
    echo ""
    read -p "Kill existing session and create new? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        tmux kill-session -t "$SESSION_NAME"
    else
        echo "Exiting. Attach to session with: tmux attach -t $SESSION_NAME"
        exit 0
    fi
fi

cd "$BASE_DIR"

echo "═══════════════════════════════════════════════════════════"
echo "🚀 Creating tmux session: $SESSION_NAME"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Create new tmux session and run the script
tmux new-session -d -s "$SESSION_NAME" -c "$BASE_DIR" "$RUN_ALL_SCRIPT"

# Wait a moment for session to start
sleep 2

# Check if session is running
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "✅ Session '$SESSION_NAME' created successfully!"
    echo ""
    echo "📋 Commands:"
    echo "   • Attach to session:    tmux attach -t $SESSION_NAME"
    echo "   • Detach from session:  Press Ctrl+B, then D"
    echo "   • List sessions:        tmux list-sessions"
    echo "   • Kill session:         tmux kill-session -t $SESSION_NAME"
    echo ""
    echo "🔍 View logs:"
    echo "   tail -f logs/aggsandbox_exp/run.log"
    echo ""
    echo "💡 Attaching to session now..."
    sleep 1
    tmux attach -t "$SESSION_NAME"
else
    echo "❌ Failed to create tmux session"
    exit 1
fi


