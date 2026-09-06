#!/bin/sh
# Fuzzy-pick a tmux binding and run it. Unannotated bindings show their command.
set -f
sel=$(tmux list-keys -Na -T prefix | LC_ALL=C grep -v "^C-a [^ ]*[^ -~]" | fzf --reverse --prompt='keys> ') || exit 0
client=$(tmux display -p '#{client_name}')
set -- $(printf '%s' "$sel" | cut -c1-12)   # key column, e.g. "C-a x"
# Popup children die on close, so let the server replay the keys after it's gone.
keys=${TMPDIR:-/tmp}/tmux-keys-picker.$$
printf '%s\0' "$@" > "$keys"
tmux run-shell -b -d 0.3 "xargs -0 tmux send-keys -K -c '$client' < '$keys'; rm -f '$keys'"
