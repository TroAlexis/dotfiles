#!/bin/sh
# :CodeDiff for lazygit custom commands. Inside nvim (<leader>gg) it opens in a new tab of that
# nvim, and lazygit stays in its float; elsewhere a fresh nvim quits back to lazygit on close.
if [ -n "$NVIM" ]; then
  nvim --server "$NVIM" --remote-expr "execute('CodeDiff $*')" >/dev/null
else
  nvim +"CodeDiff --exit-on-close $*"
fi
