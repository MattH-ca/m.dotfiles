# Macbook-only packages, on top of hosts/common.nix.
{ ... }:

{
  homebrew.brews = [
    "herdr"            # agent terminal runtime; hosts the no-mistakes daemon pane
  ];
  homebrew.casks = [
    "codexbar"         # menu bar usage monitor for Codex and Claude
    "mos"
    # Block's Buzz messenger (github.com/block/buzz). NOT the cask named
    # "buzz" - that is chidiwilliams' transcription app, and adopting it once
    # overwrote the messenger at /Applications/Buzz.app (the "0.5.14 -> 1.4.4
    # major version" jump was actually a product swap).
    "block-buzz"
  ];
}
