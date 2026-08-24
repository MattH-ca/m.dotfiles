# Project notes for agents

Deliberate decisions in this repo - do NOT silently revert them:

- `homebrew.onActivation.cleanup = "uninstall"` in `configuration.nix` is intentional. It forces the good habit of declaring every Homebrew package in the Nix config instead of installing things ad-hoc, which keeps the machine reproducible. Do not soften it to `"none"`, and do not raise it to `"zap"` either: `zap` additionally deletes a removed package's app data and config, which turns an accidental omission from the declaration into data loss. README.md documents the behavior for users; this note is for anyone tempted to change the setting itself.
- Never commit `.no-mistakes/` validation evidence to this public repo. `.no-mistakes/` is gitignored; if a validation pipeline stages evidence into a branch, drop it before merging.
- Homebrew's own code is pinned by the `brew-src` flake input (through `nix-homebrew`) and is a read-only Nix store path, so `brew update` can never upgrade it - it only refreshes formula and cask data from the API. That split means a current cask definition can hit a months-old Homebrew that cannot parse it. The failure never says the version is the problem; it surfaces as `unknown install step: <stanza>`, a symlink source that "is not there", or artifacts installed in the wrong order. Fix it with `nix flake update nix-homebrew` and a rebuild, not by working around the cask.
- The launchers in `bin/` (`cc`, `fm-claude`, `no-mistakes-daemon`) are blessed *without* `av bless --endorse-launcher`, so every launch raises an Automic Vault approval dialog. That per-launch checkpoint is a deliberate, reviewed decision - do not add `--endorse-launcher` to work around the prompts. The rationale is recorded in the private companion notes (`~/dotfiles-private/security-posture.md`).
- The no-mistakes daemon is deliberately DISABLED on this machine (2026-08-23): the `nms-autostart` herdr plugin is switched off in `home/.config/herdr/plugins.json` and the launchd plist was removed. Do not start it unless the user asks. If they do ask, never run `no-mistakes daemon start` or `daemon restart` - both silently break the pipeline's GitHub access; the only correct way is the foreground `bin/no-mistakes-daemon` (the `nms` alias) in a herdr pane. Do not move the daemon to launchd - the full investigation of why that cannot work is in the private companion notes.

## Agent skills

### Issue tracker

Issues live in the private companion repo `MattH-ca/dotfiles-private` (GitHub Issues); issues are deliberately disabled on this public repo. See `docs/agents/issue-tracker.md`.

### Triage labels

Default label vocabulary (needs-triage, needs-info, ready-for-agent, ready-for-human, wontfix). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context layout: `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.
