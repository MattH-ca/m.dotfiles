# Macbook-only packages, on top of hosts/common.nix.
{ ... }:

{
  homebrew.brews = [
    "herdr"            # agent terminal runtime; hosts the no-mistakes daemon pane
  ];
  homebrew.casks = [
    "codexbar"         # menu bar usage monitor for Codex and Claude
    "mos"
    # Adopting this crossed 0.5.14 -> 1.4.4, a major version. If Buzz's
    # models or settings do not survive that, drop this line and reinstall
    # the 0.x build by hand rather than pinning the cask.
    "buzz"
  ];
}
