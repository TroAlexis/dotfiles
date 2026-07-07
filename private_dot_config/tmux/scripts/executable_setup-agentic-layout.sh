#!/usr/bin/env bash
# Agentic layout: create panes if needed, then apply layout
# Left pane 70%, right pane 30% (split into 2)

pane_count=$(tmux list-panes -F '#{pane_id}' | wc -l | tr -d ' ')

if [ "$pane_count" -eq 1 ]; then
  # Create 2 panes: split vertically
  tmux split-window -h
fi

# Apply layout: main-vertical with left pane at 70%
tmux select-layout -t 1 main-vertical
tmux resize-pane -t 1 -x 70%
