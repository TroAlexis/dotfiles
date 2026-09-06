#!/usr/bin/env bash
# tmux popup helper for the workmux menu: add | branch | prompt | open | remove | close
action="$1"
case "$action" in
  add)    printf 'Branch: '; read -r arg; cmd=(workmux add "$arg") ;;
  prompt) printf 'Prompt: '; read -r arg; cmd=(workmux add -A -p "$arg") ;;
  branch) arg=$(git branch --format='%(refname:short)' | fzf); cmd=(workmux add "$arg") ;;
  open|remove|close)
          arg=$(workmux list | tail -n +2 | fzf | awk '{print $1}'); cmd=(workmux "$action" "$arg") ;;
  *)      exit 1 ;;
esac
[ -z "$arg" ] && exit 0
"${cmd[@]}" || { echo; read -rsn1 -p "workmux $action failed. Press any key."; }
