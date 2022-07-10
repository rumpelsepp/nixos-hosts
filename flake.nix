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

    in
    {
      nixosConfigurations = {
        inherit system;
        selonia = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/selonia/configuration.nix
          ];
        };
      };
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    };
}
