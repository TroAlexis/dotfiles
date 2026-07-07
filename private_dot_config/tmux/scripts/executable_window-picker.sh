#!/usr/bin/env bash
set -euo pipefail

cmd="$HOME/.config/tmux/window-picker.sh"

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
      tmux command-prompt -I '#W' 'rename-window \'%%\''
    else
      tmux select-window -t ":$idx"
    fi
    ;;
esac
