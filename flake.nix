{
  description = "rumpelsepp's nixos fleet";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
      };
      lib = import ./lib { inherit system pkgs; };

    in
    {
      nixosConfigurations = {
        selonia = lib.host.mkHost {
          hostname = "selonia";
          systempkgs = with pkgs; [
            wget
            curl
            tmux
            neovim
            htop
            fish
            git
            nftables
	    tree
          ];
          authorizedKeys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILBQwuGetGWeXO1BVSqW72GPZ9J4Rt6G6+nMgueXQlGi rumpelsepp@kronos"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJH55JYJ4pNSoP4va/ePLMlxF3huGH5lok6uaBMDmDIM rumpelsepp@alderaan"
          ];
          stateVersion = "22.05";
        };
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    };
}
