# Task surface for this repo. Run `just` (or `just --list`) to see everything.
#
# The vault-blessed launchers in bin/ (cc, oc, fm-claude, no-mistakes-daemon)
# are deliberately NOT here. They are blessed without --endorse-launcher, and
# routing them through just would put an extra process between your shell and
# a blessed script - exactly what Automic Vault's caller verification checks.
# Keep running those from the shell via their aliases.
#
# Note on comments: just uses only the LAST comment line above a recipe as its
# --list description. Keep doc comments to one line, and put any longer
# rationale in a block separated by a blank line, as below.

[private]
default:
    @just --list

# Rebuild the system from this flake (prompts for sudo)
rebuild:
    ./rebuild.sh

# First-time setup on a fresh Mac
bootstrap:
    ./bootstrap.sh

# Validate the flake without building anything
check:
    nix flake check --no-build

# Build the whole system without activating it
dry-run:
    nix build .#darwinConfigurations.mac.system --dry-run

# bin/ is excluded on purpose: shellcheck cannot parse the `av inject` shebang,
# and adding a shellcheck directive would change those files' contents and cost
# you a re-bless.

# Lint the shell scripts (bin/ excluded, see above)
lint:
    shellcheck bootstrap.sh rebuild.sh tests/lib.sh tests/*.test.sh home/.claude/statusline.sh

# Run the Pi Calm extension test suite
test:
    tests/pi-calm.test.sh

# Fixes `unknown install step: <stanza>`, a symlink source that "is not there",
# or artifacts landing in the wrong order - all symptoms of a current cask
# definition meeting a months-old pinned Homebrew. See CLAUDE.md for why this
# beats patching the cask.

# Unpin Homebrew's own code and rebuild
update-homebrew:
    nix flake update nix-homebrew
    ./rebuild.sh
