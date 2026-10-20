#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Open in Neovim (nvim)
# @raycast.mode silent
# @raycast.icon 📝
# @raycast.packageName Finder
# @raycast.description Open the selected Finder items in nvim (Ghostty)

files=()
while IFS= read -r f; do [ -n "$f" ] && files+=("$f"); done < <(osascript -e '
tell application "Finder"
  set out to ""
  repeat with i in (get selection)
    set out to out & POSIX path of (i as alias) & linefeed
  end repeat
  return out
end tell')

[ ${#files[@]} -eq 0 ] && { echo "No Finder selection"; exit 1; }

# cd to the first item's folder so nvim's cwd (and LazyVim root) makes sense
dir="${files[0]%/}"
[ -d "$dir" ] || dir="$(dirname "$dir")"

open -na Ghostty --args --working-directory="$dir" -e /opt/homebrew/bin/nvim "${files[@]}"
