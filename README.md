# Matthew's Agentic Mac Setup

## Start Here

**[Open the Agentic Macbook Field Guide](https://matth-ca.github.io/m.dotfiles/)**

The field guide is the current reference for this setup. It explains how the
system fits together, how to install software, and how to use Herdr, Lazygit,
ripgrep, fzf, Nix, Homebrew, and the recovery tools. Read it before running the
bootstrap or changing the configuration.

My personal Mac setup, managed with nix-darwin and home-manager.
One repo, one command, and a fresh Mac ends up configured the same way every time.

## What you get

Running the switch builds:

- System settings (dark mode, key repeat, dock, Finder, trackpad)
- Homebrew apps (casks and CLI tools, including Node.js and the Pi coding agent)
- Nix user packages (bat, fd, fzf, Git, Hermes Agent, htop, jq, Lazygit, Micro, OpenCode, ripgrep, rsync, tmux, tree, Treehouse, uv, wget, Hack Nerd Font)
- Shell (zsh, aliases, starship prompt)
- Editor (Micro config with the rose-pine moon theme)
- Terminal (WezTerm config with the rose-pine moon theme and dimmed unfocused windows)
- Agent CLIs (Claude Code, Codex, OpenCode, Pi coding agent, and Hermes Agent)
- Shared agent policy (Claude, Codex, and OpenCode read the same AGENTS.md)
- First Mate agent distro and crew orchestrator, cloned into `~/firstmate` during bootstrap
- First Mate worker tooling: tmux and Treehouse via Nix, plus an npm-installed CLI layer (see "Agent worker tooling" below)
- Secret hardening (Automic Vault: a hardened GitHub CLI plus approval gates that keep agents from silently reading your credentials)
- Optional Pi theme and local extensions, generic UI settings and model overrides, plus two deliberately pinned third-party Pi packages

## Prerequisites

- Apple Silicon Mac, by default.
- Intel Mac: change one line.
  In `configuration.nix`, set `nixpkgs.hostPlatform = "x86_64-darwin";` (the comment right there tells you the same thing).

## Fresh-machine setup

On a brand new Mac, from a bare clone of this repo:

```sh
git clone https://github.com/MattH-ca/m.dotfiles.git dotfiles
cd dotfiles
```

Before you run it: review "Make it yours" below.
Change the host label or CPU architecture if needed, and read the Homebrew cleanup warning.
`bootstrap.sh` applies the config to your machine, so do this first.

```sh
./bootstrap.sh
```

`bootstrap.sh` does five things, in order:

1. Installs Determinate Nix, if it isn't already installed.
2. Symlinks this repo to `~/.dotfiles`.
   This has to happen before the first build, because `home.nix` points at config files through `~/.dotfiles`.
3. Checks the `user` configured in `flake.nix` against your actual macOS username, and offers to fix it for you if they differ.
4. Runs the first `darwin-rebuild switch`.
   It fetches the `darwin-rebuild` tool from the nix-darwin 26.05 release branch, then applies this repo's locked flake config.
5. Clones First Mate into `~/firstmate`, unless an existing clone is already there.

After that, `darwin-rebuild` exists and you're on the normal workflow below.
Before launching First Mate for the first time, authenticate its GitHub CLI dependency with `gh auth login`.

### Validate without applying

Once Nix is installed (`bootstrap.sh` step 1 handles that), you can check that the config builds without touching your system - handy when you have edited something:

```sh
nix flake check --no-build
nix build .#darwinConfigurations.mac.system --dry-run
```

If you renamed the host label in "Make it yours", substitute your label for `mac` in these commands.

## Daily use

Edit the config files in place, then apply:

```sh
./rebuild.sh
```

That's it.
No separate build-and-copy step.

## Make it yours

This repo is mine.
If you clone it, review these before you run `bootstrap.sh`:

- **Username**: run `./bootstrap.sh` (it detects your macOS username and offers to set it) OR change the single `user = "matth"` line in `flake.nix`.
  Everything else (`configuration.nix`, `home.nix`, home directory paths) is threaded from that one variable.
- **Host label** `"mac"`, in three places: `flake.nix` (the `darwinConfigurations."mac"` name), `rebuild.sh:5` (the `#mac` at the end of the flake reference), and `bootstrap.sh`'s first-switch command (also `#mac`).
  All three have to match.
- **CPU architecture**, `hostPlatform` in `configuration.nix` (see Prerequisites above).

**Git identity:** this config deliberately does not set your git name or email.
Git will stop your first commit and tell you to set them (`git config --global user.name "Your Name"` and `git config --global user.email you@example.com`).
If you'd rather manage that declaratively, add this back to `home.nix` with your own identity:

```nix
programs.git = {
  enable = true;
  settings.user = {
    name = "Your Name";
    email = "you@example.com";
  };
};
```

**Homebrew cleanup warning:** `configuration.nix` sets `homebrew.onActivation.cleanup = "uninstall"`.
That means every time you switch, Homebrew removes any package or cask on your machine that isn't listed in the `brews` and `casks` arrays in `configuration.nix` (their app data and config files are left in place; that would need `"zap"`).
If you already have Homebrew stuff installed that isn't in that list, the first switch will uninstall it.
Read through `brews` and `casks` before you run `bootstrap.sh` or `rebuild.sh` for the first time, and add anything you want to keep.

**About `herdr`:** it's in the `brews` list.
It's a real public Homebrew formula (`brew info herdr` finds it in homebrew-core, no tap needed), so it will install fine.
If you don't use it, just remove it from `brews` in your copy.

**About Automic Vault:** the `automic-vault` cask and the `automic-vault/isotopes/gh-cli` brew (from the `automic-vault/isotopes` tap) install a background security tool that hardens secret access on this Mac.
It replaces the GitHub CLI with a codesigned build whose token lives in the Keychain, so any authenticated `gh` use - including commands your agents run - passes through an approval gate. Expect an approval notification the first time an agent uses `gh`; that is the tool working, not a broken CLI.
The command is `av` (the app is spelled "Automic Vault"): `av doctor` verifies the hardening, `av scan` audits the system, and `av save` / `av inject` / `av bless` store and hand secrets to individual commands. The [field guide's Automic Vault section](https://matth-ca.github.io/m.dotfiles/#vault) covers the full workflow.
To opt out, remove all three entries (the tap, the `gh-cli` brew, and the cask) from `configuration.nix`, and the `av` PATH line from `home.nix`.

**Heads-up:**

- `home/AGENTS.md` is my personal agent policy, and `home.nix` installs it for Claude, Codex, and OpenCode.
  If you clone this repo, you'd silently inherit my agent instructions - edit or delete `home/AGENTS.md` if you don't want that.
- The `cc` and `co` shell aliases in `home.nix` are high-agency shortcuts: `claude --dangerously-skip-permissions` and `codex --full-auto`.
  They're convenient for me, but know what they do before you use them.
- The `oc` alias runs `bin/oc`, which hands OpenCode an `ANTHROPIC_API_KEY` from Automic Vault instead of letting `opencode auth login` write credentials to disk.
  It needs that key saved (`av save ANTHROPIC_API_KEY`) and the script blessed (`av bless ~/dotfiles/bin/oc`); without both, plain `opencode` still works but has no provider configured.

## Repo tour

- `flake.nix` - the entry point.
  Wires up nixpkgs, nix-darwin, home-manager, and nix-homebrew, and declares the `mac` machine.
- `configuration.nix` - system-level config: macOS defaults, Homebrew.
- `home.nix` - user-level config: shell, packages, prompt, and the symlinks described below.
- `rebuild.sh` - re-applies the config after the first switch.
  Run this every time you make a change.
- `home/` - the actual config files that get symlinked into place (WezTerm, herdr, Claude settings, the shared `AGENTS.md`, Pi themes and extensions).
  The sections below explain the shared symlink model and Pi's narrower selective setup.

## How the symlinks work

The files under `home/` are the real files - editing them here is editing your live config, no rebuild needed to see the change in your editor.
`home.nix` uses `mkOutOfStoreSymlink` to point paths like `~/.config/wezterm` straight at `home/.config/wezterm` in this repo, so the two never drift out of sync.
You only run `./rebuild.sh` when you change something that isn't just a symlinked file, like a package list or a system default.

## Agent worker tooling

First Mate needs a set of tools to host and validate its worker agents.
The declarative half lives in this repo: `tmux` (hosts each worker in its own terminal session) and Treehouse (a pool of isolated git worktrees, pulled in as a flake input) are Nix packages, and `home.nix` sets `NPM_CONFIG_PREFIX` to `~/.npm-global` so npm globals land in a writable prefix rather than alongside the runtime.

The imperative half is installed once per machine and is NOT managed by Nix, so on a fresh Mac rerun these after bootstrap:

```sh
npm install -g gh-axi chrome-devtools-axi lavish-axi tasks-axi quota-axi gnhf @deepseek-ai/dsh
gh-axi setup hooks && chrome-devtools-axi setup hooks && lavish-axi setup hooks
NO_MISTAKES_LINK_DIR="$HOME/.no-mistakes/bin" \
  sh -c 'curl -fsSL https://raw.githubusercontent.com/kunchenguid/no-mistakes/main/docs/install.sh | sh'
npx -y skills add kunchenguid/lavish-axi --skill lavish -g
npx -y skills add kunchenguid/gnhf --skill gnhf -g
```

- The axi tools are agent-facing CLIs: `gh-axi` (GitHub), `chrome-devtools-axi` (browser), `lavish-axi` (visual reports and decisions), `tasks-axi` (task queue), `quota-axi` (usage headroom). Their `setup hooks` steps write ambient-context hooks into the tracked `home/.claude/settings.json`.
- `gnhf` is an overnight autonomous-loop orchestrator, installed with its agent skill.
- `@deepseek-ai/dsh` is [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness), a plugin-based agent runtime.
  Launch it on demand with the `dsh` alias, which runs the blessed `bin/dsh` (injects `GH_TOKEN` from Automic Vault; needs `av bless ~/dotfiles/bin/dsh`); the web UI listens on `127.0.0.1:3080`.
  Its model backend signs in with ChatGPT OAuth from the web UI's Settings → Models page and keeps that token in its own credential store, like Codex's `~/.codex/auth.json`.
- `no-mistakes` is the git push validation pipeline First Mate uses for delivery. Setting `NO_MISTAKES_LINK_DIR` to the install dir makes the installer skip its `/usr/local/bin` symlink, which is the only step that wants sudo; `home.nix` puts `~/.no-mistakes/bin` on the PATH instead.
- The `skills add` commands install the `lavish` and `gnhf` skills globally for Claude Code (`~/.claude/skills` and `~/.agents/skills`).

On this machine the no-mistakes daemon is not run from its launchd agent. Start it from a herdr pane instead:

```sh
~/dotfiles/bin/no-mistakes-daemon
```

It runs in the foreground; leave it in its own pane, and herdr keeps it across disconnects and restarts. Never run `no-mistakes daemon start` or `daemon restart` - both silently break the pipeline's GitHub access (see `AGENTS.md`).

One gotcha after a rebuild that changes the PATH (like the one that added `~/.npm-global/bin`): existing terminal sessions never pick the change up.
Home-manager applies session variables once and sets a guard (`__HM_SESS_VARS_SOURCED`) that every nested shell inherits, so agents launched from a pre-rebuild shell report `command not found` for these tools even though they are installed.
Open a fresh WezTerm tab (or reboot), and restart long-lived hosts like the herdr server from that fresh tab so their child sessions inherit the new PATH.

## Optional Pi configuration

Pi is often installed with a manual `npm install -g`. This repo declares it instead, as the
homebrew-core `pi-coding-agent` formula in `configuration.nix`, so the switch installs it
for you. Homebrew is used rather than Nix because the `nixpkgs-26.05-darwin` release branch
freezes Pi at 0.75.4 while Pi itself ships releases continuously; homebrew-core tracks them.

The formula depends on Homebrew's `node`, which is why `home.nix` no longer declares a Nix
`nodejs`. Pi's bottle carries native modules (`koffi`, `pi-tui` prebuilds) that are ABI-bound
to the Node major it was built against, and `/opt/homebrew/bin` precedes the Nix profiles on
`PATH`, so a second Nix Node would only shadow the one Pi needs. Homebrew's `node` is the
single Node on this machine and serves the `~/.npm-global` CLIs too.

[Pi Launcher](https://github.com/kunchenguid/homebrew-tap) is also optional and installed from its owner, not declared by this config:

```sh
brew install --cask kunchenguid/tap/pi-launcher
```

Home Manager owns exactly two repository-authored Pi directories: `~/.pi/agent/themes` and `~/.pi/agent/extensions`. It also links `models.json` and `settings.json` as individual files. The local extension directory is for public, repository-authored extensions only - third-party package code never belongs there. Run `/reload` after editing a local extension or other Pi resources. The terminal-title extension shows a spinner while Pi is working, then a completion mark with the session name or current directory. The `rose-pine-moon` theme was authored clean-room from the public [Rosé Pine Moon palette](https://rosepinetheme.com/palette) and Pi's [public theme schema](https://raw.githubusercontent.com/earendil-works/pi/main/packages/coding-agent/src/modes/interactive/theme/theme-schema.json), not from a private or live theme file.

### Pi Calm

`home/.pi/agent/extensions/calm` is a standalone local Pi extension. Home Manager's existing global extensions-directory link makes Pi auto-load it without another declaration. `/calm` toggles a conversation-only presentation mode and is off by default. Its choice is stored locally in `~/.pi/agent/calm` (or the directory selected by `PI_CODING_AGENT_DIR`), not in this repository or Home Manager. Adapted from Firstmate under the bundled MIT license, Calm imports no Firstmate modules and has no Firstmate runtime dependency.

When enabled, Calm hides collapsed thinking and the call/result shells for Pi's seven built-in tools (`read`, `bash`, `edit`, `write`, `grep`, `find`, and `ls`) without leaving blank transcript rows. During an active run it replaces Pi's working row with a two-line animated blue-water, yellow-boat widget. `/calm` restores Pi's stock rendering and preserves the existing Ctrl+O tool-expansion choice.

Calm never changes prompts, tool execution, model context, session data, or ordering. `/share` and `/export` use the complete stock transcript. Generic custom tools, images, and unsupported Pi transcript classes deliberately remain visible because Pi has no safe general-purpose transcript filter. If a future Pi release no longer exports the exact collapsed-thinking rendering seam, Calm logs one diagnostic and leaves only that adapter disabled; all other behavior remains available.

Pi's package system declares two third-party sources in the linked global `settings.json`:

- `npm:@ryan_nookpi/pi-extension-codex-fast-mode@0.2.6` - the exact public npm release from `ryan_nookpi`.
- `git:github.com/algal/pi-openai-server-compaction@c6d593087709e9481223dc6c6c2269b371b5e055` - the exact public `algal` commit for experimental OpenAI server-side compaction.

The version and commit are immutable pins, so Pi does not move them during package updates. Deliberate updates require a new source and security audit, followed by an explicit pin change in `home/.pi/agent/settings.json`. On Pi 0.82.0, global settings declarations install missing pinned packages automatically at startup. No one-time install command is required. Pi keeps the downloaded npm and git package trees in its own unmanaged `~/.pi/agent/npm` and `~/.pi/agent/git` runtime directories, outside Home Manager and Git tracking.

Both packages execute with your full user permissions and must be trusted like any other executable code. The compaction package is experimental, sends the relevant OpenAI compaction and continuity data to OpenAI, and upstream declares the stale peer range `>=0.80.9 <0.81.0`; this exact immutable ref was locally proven to load and perform remote compaction on Pi 0.82.0. Do not treat that proof as a guarantee for a different Pi version or a different package ref.

Home Manager deliberately does not manage `~/.pi/agent` itself, or Pi authentication, sessions, trust decisions, caches, npm/git package trees, or any other runtime state. The model overrides contain no credentials or endpoint settings, do not choose a default model, and only take effect after you authenticate Pi yourself. This remains an additive post-video layer: it does not install Pi, a launcher, or package source code into this repository.

## Notes

Micro is the default `$EDITOR`; it reads its own config from `~/.config/micro` and is not symlinked from this repo.

## License

This repo is licensed under MIT No Attribution.
See `LICENSE`.
