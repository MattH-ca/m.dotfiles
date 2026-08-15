#!/bin/sh
# Claude Code status line: model | dir | branch | context% | effort | style
#
# Claude Code pipes a JSON blob on stdin (schema: `/statusline` or the docs).
# Note the branch is NOT in that payload - only `worktree.branch`, and only in
# --worktree sessions - so it comes from git itself.
#
# Referenced by home/.claude/settings.json as $HOME/.dotfiles/... - the same
# out-of-store path home.nix uses, so it survives relocating the repo. settings
# .json reaches this repo through a symlink, so edits here need no rebuild.

input=$(cat)

field() { printf '%s' "$input" | jq -r "$1 // empty"; }

model=$(field '.model.display_name')
# Drop a trailing parenthetical: "Opus 5 (1M context)" becomes "Opus 5". The
# variant is implied by the model already chosen, so it only eats width.
model=$(printf '%s' "$model" | sed 's/ *([^)]*)$//')
dir=$(field '.workspace.current_dir')
style=$(field '.output_style.name')
used=$(field '.context_window.used_percentage')
effort=$(field '.effort.level')

CYAN='\033[96m'
GREEN='\033[92m'
YELLOW='\033[93m'
RED='\033[91m'
DIM='\033[90m'
OFF='\033[0m'

out=""
sep=""
add() { out="${out}${sep}${1}"; sep="${DIM} | ${OFF}"; }

[ -n "$model" ] && add "${CYAN}[${model}]${OFF}"
[ -n "$dir" ] && add "${CYAN}📁 $(basename "$dir")${OFF}"

if [ -n "$dir" ]; then
  branch=$(git -C "$dir" branch --show-current 2>/dev/null)
  [ -n "$branch" ] && add "${GREEN}🌿 ${branch}${OFF}"
fi

[ -n "$used" ] && add "${CYAN}📊 $(printf '%.0f' "$used")%${OFF}"

# Only present when the model supports reasoning effort. Abbreviated to keep the
# segment to a few cells; an unrecognised level still shows rather than vanishing.
if [ -n "$effort" ]; then
  case "$effort" in
    low) short=LO ;;
    medium) short=MED ;;
    high) short=HI ;;
    xhigh) short=XH ;;
    max) short=MAX ;;
    *) short=$(printf '%s' "$effort" | tr '[:lower:]' '[:upper:]') ;;
  esac
  add "${YELLOW}🧠 ${short}${OFF}"
fi

# "default" is the implicit style; showing it is just noise.
[ -n "$style" ] && [ "$style" != "default" ] && add "${RED}${style}${OFF}"

printf '%b' "$out"
