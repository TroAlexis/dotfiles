#!/bin/bash
# Open FILE... in the nvim pane of the attached tmux session (active pane first), or
# start nvim for the project when there is none. Used by Raycast (Finder) and yazi.

export PATH="/opt/homebrew/bin:$PATH"
files=("$@")
[ ${#files[@]} -eq 0 ] && { echo "usage: open-in-nvim.sh FILE..." >&2; exit 1; }

# nvim pane in the attached session: active window/pane first, then most recent activity
pane=$(tmux list-panes -a -f '#{&&:#{session_attached},#{==:#{pane_current_command},nvim}}' \
  -F '#{window_active}#{pane_active} #{window_activity} #{pane_id} #{pane_pid}' 2>/dev/null | sort -r | head -1)

if [ -n "$pane" ]; then
  read -r _ _ pane_id pane_pid <<<"$pane"
  # nvim's RPC socket is named after its embedded server process, a descendant of the pane shell
  pids="$pane_pid $(pgrep -P "$pane_pid")"
  for p in $pids; do pids="$pids $(pgrep -P "$p")"; done
  for p in $pids; do
    sock=$(ls "${TMPDIR:-$(getconf DARWIN_USER_TEMP_DIR)}"nvim.$USER/*/nvim.$p.0 2>/dev/null | head -1)
    [ -n "$sock" ] && break
  done
  # Probe first: --remote falls back to a local (here: stuck, tty-less) nvim if the socket is stale
  if [ -n "$sock" ] && nvim --server "$sock" --remote-expr 1 >/dev/null 2>&1 </dev/null; then
    nvim --server "$sock" --remote "${files[@]}"
    tmux switch-client -t "$pane_id"
    open -a Ghostty
    exit 0
  fi
fi

# No nvim pane: new session for the project (git root, else folder), named by sesh.toml if
# listed there, else sesh-style after the folder
dir="${files[0]}"
[ -d "$dir" ] || dir="$(dirname "$dir")"
dir="$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null || echo "$dir")"
name=$(sesh list -c -j 2>/dev/null | jq -r --arg d "$dir" 'first(.[] | select(.Path == $d) | .Name) // empty')
[ -n "$name" ] || name="$(basename "$dir" | tr '.:' '__')"

# Typed into a shell like sesh's startup_command, so quitting nvim leaves the pane open
if tmux has-session -t "=$name" 2>/dev/null; then
  target=$(tmux new-window -P -F '#{pane_id}' -t "=$name:" -c "$dir")
else
  target=$(tmux new-session -d -P -F '#{pane_id}' -s "$name" -c "$dir")
fi
tmux send-keys -t "$target" "nvim $(printf '%q ' "${files[@]}")" Enter

if [ -n "$(tmux list-clients 2>/dev/null)" ]; then
  tmux switch-client -t "$target"
  open -a Ghostty
else
  open -na Ghostty --args -e tmux attach -t "$target"
fi
