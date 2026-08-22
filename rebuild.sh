#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# Pick the flake host from the machine name, or take it as the first argument.
# LocalHostName, not `hostname`: the latter follows DHCP/DNS and changes with
# the network, while LocalHostName is the stable name set in Sharing settings.
HOST="${1:-}"
if [ -z "$HOST" ]; then
  case "$(scutil --get LocalHostName | tr '[:upper:]' '[:lower:]')" in
    *book*)   HOST=macbook ;;
    *studio*) HOST=studio ;;
    *)
      echo "Unrecognized hostname '$(hostname -s)'." >&2
      echo "Run: $0 <host>   (hosts: macbook, studio - see flake.nix)" >&2
      exit 1
      ;;
  esac
fi

ln -sfn "$DIR" ~/.dotfiles
exec sudo /run/current-system/sw/bin/darwin-rebuild switch --flake ~/.dotfiles#"$HOST"
