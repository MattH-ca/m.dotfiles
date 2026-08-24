{ config, hermes-agent, pkgs, treehouse, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    # cli i use constantly
    bat       # cat with syntax highlighting
    doggo     # dns lookups - dig, but readable
    fd        # fast find
    ffmpeg    # audio/video transcode, trim, extract
    fzf       # fuzzy finder
    git       # primary git (moved off homebrew)
    hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default
    htop      # process viewer
    jq        # json on the command line
    just      # task runner; see the justfile at the repo root
    lazygit
    micro
    # node comes from homebrew (hosts/common.nix); pi-coding-agent too (hosts/macbook.nix).
    # nixpkgs 26.05 freezes Pi at 0.75.4 and Pi ships releases far faster; the
    # formula's native modules are ABI-bound to homebrew's node, and /opt/homebrew
    # precedes the nix profiles on PATH, so a nix nodejs here would only shadow it.
    opencode
    ripgrep   # rg - fast grep
    rsync     # newer than macOS's built-in
    shellcheck # shell script linter
    tmux      # hosts firstmate crew sessions
    tree
    treehouse.packages.${pkgs.stdenv.hostPlatform.system}.default  # worktree pool for agents
    typescript # tsc - typechecks the Pi Calm extension in tests/pi-calm.test.sh
    uv        # python package + version manager
    wget
    # the font everything renders in
    nerd-fonts.hack
  ];
  fonts.fontconfig.enable = true;
  home.sessionPath = [
    "/Applications/Automic Vault.app/Contents/MacOS"
    "${config.home.homeDirectory}/.npm-global/bin"
    "${config.home.homeDirectory}/.no-mistakes/bin"
  ];
  home.sessionVariables.EDITOR = "micro";
  # nix's npm prefix is the read-only store; give globals a writable home
  home.sessionVariables.NPM_CONFIG_PREFIX = "${config.home.homeDirectory}/.npm-global";

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    initContent = ''
      bindkey '^f' autosuggest-accept
    '';
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      push = "git push";
      pull = "git pull";
      m = "git switch main";
      # Blessed av script (see bin/cc): hands Claude its GitHub token, so
      # agent gh calls don't stop for an approval prompt on every exec
      cc = "${dotfiles}/bin/cc";
      co = "codex --sandbox workspace-write --ask-for-approval never";
      # Blessed av script (see bin/oc): injects ANTHROPIC_API_KEY so opencode
      # authenticates without a plaintext auth.json on disk
      oc = "${dotfiles}/bin/oc";
      # Blessed av script (see bin/dsh): injects GH_TOKEN for DeepSeek Harness.
      # The alias shadows the raw npm binary, so launches go through the vault.
      dsh = "${dotfiles}/bin/dsh";
      # no-mistakes itself needs no alias: ~/.no-mistakes/bin is on the PATH above.
      # Its daemon runs in the foreground from a herdr pane via nms
      # (bin/no-mistakes-daemon), never from launchd or `daemon start`.
      # nms, not nm: nm is binutils' symbol lister.
      nms = "${dotfiles}/bin/no-mistakes-daemon";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      cmd_duration.format = "[$duration]($style) ";
    };
  };

  # `z <fragment>` jumps to a frecency-ranked directory, `zi` opens an fzf
  # picker over the same history. Plain `cd` is deliberately left alone - see
  # the --cmd option if that ever changes.
  programs.zoxide.enable = true;

  # ~/.ssh/config lives in the private repo (usernames/ports stay off GitHub)
  # and is linked live, so edits there apply without a rebuild. IPs are not in
  # it: /etc/hosts (hosts/common.nix, from the same repo's hosts.nix) resolves
  # the names.
  home.file.".ssh/config".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles-private/ssh/config";

  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
  home.file.".config/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";
  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/settings.json";

  # Keep Pi's credential and runtime state local by linking only authored files and directories.
  home.file.".pi/agent/themes".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/themes";
  home.file.".pi/agent/extensions".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/extensions";
  home.file.".pi/agent/models.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/models.json";
  home.file.".pi/agent/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/settings.json";

  # OrbStack is the container engine, but the `docker` CLI comes from Homebrew
  # and only ships the client - no subcommand plugins. Point the CLI's plugin
  # lookup at the compose and buildx binaries inside the OrbStack app, so
  # `docker compose` works without relying on OrbStack's GUI onboarding step
  # (which is what creates ~/.orbstack/bin, and never runs on a headless setup).
  home.file.".docker/cli-plugins/docker-compose".source =
    config.lib.file.mkOutOfStoreSymlink
      "/Applications/OrbStack.app/Contents/MacOS/xbin/docker-compose";
  home.file.".docker/cli-plugins/docker-buildx".source =
    config.lib.file.mkOutOfStoreSymlink
      "/Applications/OrbStack.app/Contents/MacOS/xbin/docker-buildx";

  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".config/opencode/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";

  # Hand-authored skills, linked per harness so one file serves all three.
  # ~/.agents/skills is the shared skills root (where the skills CLI installs
  # from GitHub, tracked in its .skill-lock.json); only skills authored here
  # are linked, so the CLI keeps managing the rest. Claude Code reads
  # ~/.claude/skills and Codex reads ~/.codex/skills; opencode needs no link
  # of its own because it also auto-scans ~/.agents/skills and ~/.claude/skills
  # (confirm with `opencode debug skill`).
  home.file.".agents/skills/bro".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/skills/bro";
  home.file.".claude/skills/bro".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/skills/bro";
  home.file.".codex/skills/bro".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/skills/bro";
  home.file.".agents/skills/eli5".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/skills/eli5";
  home.file.".claude/skills/eli5".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/skills/eli5";
  home.file.".codex/skills/eli5".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/skills/eli5";
}
