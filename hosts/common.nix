# Shared base for every host. Per-machine packages live in hosts/<name>.nix;
# homebrew.brews/casks and home-manager package lists merge across modules.
{ user, ... }:

{
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
    onActivation.extraFlags = [ "--force" ];
    brews = [
      "age"
      "automic-vault/isotopes/gh-cli"
      "node"             # the machine's only node; agent tooling binds to it
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
      "veracrypt"
      "macfuse"
      # Adopted from manual installs: these were already in /Applications but
      # Homebrew had never seen them, so bootstrap.sh could not restore them.
      "1password"
      "cleanshot"
      "discord"
      "spotify"
      "brave-browser"
      "google-chrome"
      "github"           # GitHub Desktop
      "syncthing-app"    # renamed upstream from "syncthing"
    ];
  };
}
