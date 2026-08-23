{
  description = "dotfiles";

  inputs = {
    # Use `github:NixOS/nixpkgs/nixpkgs-26.05-darwin` to use Nixpkgs 26.05.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    # Use `github:nix-darwin/nix-darwin/nix-darwin-26.05` to use Nixpkgs 26.05.
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hermes-agent.url = "github:NousResearch/hermes-agent";

    treehouse.url = "github:kunchenguid/treehouse";
    treehouse.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    # Private fleet data (hostname -> IP map in hosts.nix). Kept out of this
    # public repo on purpose; requires ~/dotfiles-private to be cloned. After
    # editing it, run `nix flake update dotfiles-private` to pick up the change.
    dotfiles-private = {
      url = "git+file:///Users/matth/dotfiles-private";
      flake = false;
    };
  };

  outputs = inputs@{ self, dotfiles-private, hermes-agent, nix-darwin, nix-homebrew, home-manager, nixpkgs, treehouse }:
    let
      # The one username line to change if this isn't your machine.
      # bootstrap.sh offers to rewrite this for you if your macOS username differs.
      user = "matth";

      # Fleet hostname -> IP map from the private repo; rendered into
      # /etc/hosts by hosts/common.nix so both machines resolve the same names.
      fleetHosts = import "${dotfiles-private}/hosts.nix";

      # Every host shares the same base; hosts/<name>.nix holds the differences.
      # rebuild.sh and bootstrap.sh pick the host from the machine's hostname.
      mkHost = hostModule: nix-darwin.lib.darwinSystem {
        specialArgs = { inherit user fleetHosts; };
        modules = [
          ./hosts/common.nix
          hostModule
          nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # If a file home-manager wants to manage already exists (e.g. the
            # hand-edited ~/.ssh/config on first activation), move it aside
            # instead of aborting.
            home-manager.backupFileExtension = "before-home-manager";
            home-manager.extraSpecialArgs = { inherit hermes-agent treehouse user; };
            home-manager.users.${user} = import ./home.nix;
          }
        ];
      };
    in
    {
      darwinConfigurations."macbook" = mkHost ./hosts/macbook.nix;
      darwinConfigurations."studio" = mkHost ./hosts/studio.nix;
    };
}
