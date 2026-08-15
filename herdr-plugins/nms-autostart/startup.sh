#!/bin/sh
# Herdr plugin startup hook: make sure the no-mistakes daemon is running in a
# visible "NMS" tab after every session restore.
#
# The daemon must run in the foreground from a herdr pane via the blessed
# launcher bin/no-mistakes-daemon (never launchd, never `daemon start`).
# This hook only recreates that pane; the launcher does the rest.
set -eu

NM="$HOME/.no-mistakes/bin/no-mistakes"
LAUNCHER="$HOME/dotfiles/bin/no-mistakes-daemon"
HERDR="${HERDR_BIN_PATH:-herdr}"
LABEL="NMS"

# Nothing to do if a daemon is already up. `daemon status` reports "not
# running" during the daemon's ~30s startup phase, so also treat a live
# `daemon run` process as running to avoid double-starting after a race.
if "$NM" daemon status 2>/dev/null | grep -q "daemon running"; then
  exit 0
fi
if pgrep -f "no-mistakes daemon run" >/dev/null 2>&1; then
  exit 0
fi

# Reuse an existing NMS tab (session restore preserves it as an idle shell).
tab_id=$("$HERDR" tab list | python3 -c '
import json, sys
tabs = json.load(sys.stdin)["result"]["tabs"]
m = [t["tab_id"] for t in tabs if t["label"] == "'"$LABEL"'"]
print(m[0] if m else "")
')

if [ -n "$tab_id" ]; then
  pane_id=$("$HERDR" pane list | python3 -c '
import json, sys
panes = json.load(sys.stdin)["result"]["panes"]
m = [p["pane_id"] for p in panes if p["tab_id"] == "'"$tab_id"'"]
print(m[0] if m else "")
')
else
  pane_id=""
fi

# Otherwise create the tab in the dotfiles workspace.
if [ -z "$pane_id" ]; then
  ws=$("$HERDR" workspace list | python3 -c '
import json, sys
ws = json.load(sys.stdin)["result"]["workspaces"]
m = [w["workspace_id"] for w in ws if w["label"] == "dotfiles"]
print(m[0] if m else ws[0]["workspace_id"])
')
  pane_id=$("$HERDR" tab create --workspace "$ws" --cwd "$HOME/dotfiles" \
    --label "$LABEL" --no-focus | python3 -c '
import json, sys
print(json.load(sys.stdin)["result"]["root_pane"]["pane_id"])
')
fi

exec "$HERDR" pane run "$pane_id" "$LAUNCHER"
