#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Open in Neovim (nvim)
# @raycast.mode silent
# @raycast.icon 📝
# @raycast.packageName Finder
# @raycast.description Open the selected Finder items (or current folder) in tmux nvim


# Finder selection, or the front window's folder (Desktop if none) when nothing is selected
files=()
while IFS= read -r f; do [ -n "$f" ] && files+=("${f%/}"); done < <(osascript -e '
tell application "Finder"
  set out to ""
  set sel to selection
  if sel is {} then
    if (count of Finder windows) > 0 then
      set sel to {target of front Finder window}
    else
      set sel to {desktop}
    end if
  end if
  repeat with i in sel
    set out to out & POSIX path of (i as alias) & linefeed
  end repeat
  return out
end tell')

[ ${#files[@]} -eq 0 ] && { echo "Nothing to open"; exit 1; }

exec ~/.config/tmux/scripts/open-in-nvim.sh "${files[@]}"
