# Studio-only packages, on top of hosts/common.nix.
# Decisions from the 2026-08 onboarding triage: node/python/terminal converge on
# the shared config (no nvm/pyenv/iTerm2 here); everything Studio-specific that
# nixpkgs carries comes from Nix, not Homebrew.
{ pkgs, user, ... }:

{
  homebrew.brews = [
    # Kept on brew deliberately: live database, service run via `brew services`.
    # Upgrade off 14 (EOL Nov 2026) and Nix migration are tracked in the private
    # companion notes (studio-postgres-todo.md).
    "postgresql@14"
  ];
  homebrew.casks = [
    "1password-cli"
    "moonlight"        # game/desktop streaming client
    "openmtp"          # Android file transfer
    "seafile-client"
  ];
  home-manager.users.${user}.home.packages = with pkgs; [
    gnupg
    macmon    # sudoless Apple Silicon performance monitor
    mpv
    pandoc
    # fonts the Studio's terminals were configured with (brew casks before)
    nerd-fonts.fira-code
    nerd-fonts.meslo-lg
  ];
}
