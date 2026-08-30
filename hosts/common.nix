# Shared base for every host. Per-machine packages live in hosts/<name>.nix;
# homebrew.brews/casks and home-manager package lists merge across modules.
{ lib, user, fleetHosts, ... }:

{
  # /etc/hosts is generated from the fleet map in ~/dotfiles-private/hosts.nix
  # (flake input `dotfiles-private`), so every machine resolves the same names
  # the ssh config uses. knownSha256Hashes lets activation replace a known
  # pre-nix file (stock macOS, and the Macbook's last hand-edited copy); on a
  # host with other content, activation aborts and asks you to run
  # `sudo mv /etc/hosts{,.before-nix-darwin}` first.
  environment.etc."hosts" = {
    text = ''
      ##
      # Host Database
      #
      # localhost is used to configure the loopback interface
      # when the system is booting.  Do not change this entry.
      ##
      127.0.0.1 localhost
      255.255.255.255 broadcasthost
      ::1 localhost

    '' + lib.concatStrings (lib.mapAttrsToList (name: ip: "${ip} ${name}\n") fleetHosts);
    knownSha256Hashes = [
      "c7dd0e2ed261ce76d76f852596c5b54026b9a894fa481381ffd399b556c0e2da" # stock macOS
      "6c43f7b8368f2e7f361777c1ac271787202d326f85ab92bf1a9ec5d711b2c7de" # macbook, hand-edited pre-nix
    ];
  };

  # Determinate already manages the Nix daemon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin"; # use x86_64-darwin for Intel CPU

  system.primaryUser = user;
  users.users.${user} = {
    home = "/Users/${user}";
  };
  system.stateVersion = 6;
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat
      _HIHideMenuBar = true;  # auto-hide the menu bar
      AppleShowAllExtensions = true;
    };
    dock.autohide = true;
    finder.FXPreferredViewStyle = "Nlsv";  # list view by default
    finder.CreateDesktop = false;          # clean desktop
    trackpad.Clicking = true;              # tap to click
  };
  nix-homebrew = {
    enable = true;
    inherit user;
    autoMigrate = true;
  };
  homebrew = {
    enable = true;
    taps = [
      {
        name = "automic-vault/isotopes";
        trusted = true;
      }
      {
        name = "my-monkeys/tap";
        trusted = true;
      }
    ];
    onActivation.cleanup = "uninstall";  # remove anything not declared here
    onActivation.autoUpdate = true;
    # Every rebuild also upgrades all installed brews/casks to current. Deliberate
    # tradeoff: rebuilds are no longer no-ops, and an unrelated rebuild can bump
    # node (Pi's native modules are ABI-bound to it - reinstall Pi if it breaks).
    onActivation.upgrade = true;
    onActivation.extraFlags = [ "--force" ];
    brews = [
      "age"
      "automic-vault/isotopes/gh-cli"
      "node"             # the machine's only node; agent tooling binds to it
      "pi-coding-agent"  # homebrew-core; tracks Pi releases, unlike nixpkgs 26.05
      "docker"           # CLI client only; OrbStack (cask below) is the engine
      "ollama"
      "llama.cpp"
    ];
    casks = [
      "automic-vault"
      "wezterm"
      "orbstack"         # container + Linux VM runtime, replaces Docker Desktop
      "claude-code"
      "codex"
      "my-monkeys/tap/opensuperwhisper"
      "obsidian"
      "zed"
      "veracrypt"
      "macfuse"
      # Adopted from manual installs: these were already in /Applications but
      # Homebrew had never seen them, so bootstrap.sh could not restore them.
      "1password"
      "cleanshot"
      "mullvad-vpn"
      "trezor-suite"
      "discord"
      "spotify"
      "brave-browser"
      "google-chrome"
      "github"           # GitHub Desktop
      "syncthing-app"    # renamed upstream from "syncthing"
      "moonlight"        # game/desktop streaming client
    ];
  };
}
