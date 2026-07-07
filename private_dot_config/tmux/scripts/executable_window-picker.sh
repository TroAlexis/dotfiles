#!/usr/bin/env bash
set -euo pipefail

cmd="$HOME/.config/tmux/scripts/window-picker.sh"

# Open popup for text input, returns the input value
popup_input() {
  local prompt="$1"
  local default="$2"
  local tmp=$(mktemp)
  tmux display-popup -w 60% -h 15% -E "bash -c 'echo -n \"$prompt\"; read -e -i \"$default\" val; echo \"\$val\" > \"$tmp\"'"
  cat "$tmp"
  rm -f "$tmp"
}

case "${1:-picker}" in
  list)
    tmux list-windows -F '#I: #W — #{pane_current_path}'
    ;;
  kill)
    tmux kill-window -t ":$2"
    ;;
  new)
    [ -n "${2:-}" ] && tmux new-window -n "$2" || tmux new-window
    ;;

  picker)
    tmp=$(mktemp)
    trap 'rm -f "$tmp"' EXIT

    "$cmd" list | fzf-tmux -p 80%,70% \
      --expect=ctrl-r \
      --no-sort --ansi --delimiter=':' --with-nth=2.. \
      --border-label ' windows ' --prompt '🪟  ' \
      --header '  ⏎ switch ^n new ^r rename ^d kill' \
      --bind "ctrl-d:execute-silent($cmd kill {1})+reload($cmd list)" \
      --bind "ctrl-n:execute-silent($cmd new {q})+reload($cmd list)" \
      --preview-window 'right:55%' \
      --preview 'tmux capture-pane -ep -t :{1}' >"$tmp" || true

    key=$(sed -n '1p' "$tmp")
    choice=$(sed -n '2p' "$tmp")
    [ -z "$choice" ] && exit 0

    idx="${choice%%:*}"
    if [ "$key" = ctrl-r ]; then
      tmux select-window -t ":$idx"
      current_name=$(tmux display-message -p -t ":$idx" '#W')
      new_name=$(popup_input "Rename window: " "$current_name")
      [ -n "$new_name" ] && tmux rename-window -t ":$idx" "$new_name"
    else
      tmux select-window -t ":$idx"
    fi
    ;;
esac
