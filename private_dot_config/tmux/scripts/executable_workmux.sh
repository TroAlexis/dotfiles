#!/usr/bin/env bash
# tmux popup helper for the workmux menu: add | branch | prompt | open | remove | close
# Popups have no TMUX_PANE, so workmux can't infer the session; ask tmux and pass it explicitly.
action="$1"
sess=(--parent-session "$(tmux display-message -p '#S')")
case "$action" in
  add)    printf 'Branch: '; read -r arg; cmd=(workmux add "${sess[@]}" "$arg") ;;
  prompt) printf 'Prompt: '; read -r arg; cmd=(workmux add "${sess[@]}" -A -p "$arg") ;;
  branch) # local branches not already in a worktree; ctrl-r fetches and switches to origin/* (ctrl-l back)
          local_list="comm -23 <(git branch --format='%(refname:short)' | sort) <(git worktree list --porcelain | sed -n 's#^branch refs/heads/##p' | sort)"
          remote_list="git fetch -q 2>/dev/null; git branch -r --format='%(refname:short)' | grep -v '/HEAD\$'"
          arg=$(bash -c "$local_list" | fzf --header 'ctrl-r: remote branches (fetches)  ctrl-l: local' \
                  --bind "ctrl-r:reload(bash -c \"$remote_list\")" --bind "ctrl-l:reload(bash -c \"$local_list\")")
          cmd=(workmux add "${sess[@]}" "$arg") ;;
  open)   arg=$(workmux list | tail -n +2 | fzf | awk '{print $1}'); cmd=(workmux open "${sess[@]}" "$arg") ;;
  remove|close)
          arg=$(workmux list | tail -n +2 | fzf | awk '{print $1}'); cmd=(workmux "$action" "$arg") ;;
  *)      exit 1 ;;
esac
[ -z "$arg" ] && exit 0
"${cmd[@]}" || { echo; read -rsn1 -p "workmux $action failed. Press any key."; }
