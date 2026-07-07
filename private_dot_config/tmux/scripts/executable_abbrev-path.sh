#!/bin/bash
# Abbreviate path: ~/.config/tmux -> ~/.c/tmux
# ~/WebstormProjects/lme-frontend -> ~/W/lme-frontend

path="$1"
home="$HOME"

# Replace home with ~ first
path="${path/$home/~}"

# Abbreviate all components except the last one
# If component starts with dot, keep dot + first letter (.config -> .c)
# Otherwise keep first letter (WebstormProjects -> W)
echo "$path" | awk -F'/' '{
    for(i=1; i<NF; i++) {
        if($i != "") {
            if(substr($i,1,1) == ".") {
                printf "%s/", substr($i,1,2)
            } else {
                printf "%s/", substr($i,1,1)
            }
        }
    }
    printf "%s", $NF
}'
