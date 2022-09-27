{
  description = "rumpelsepp's nixos fleet";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
  };

  outputs = { self, nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
      };
      util = import ./lib { inherit system pkgs lib; };
    in
    {
      nixosConfigurations = {
        selonia = util.host.mkHost {
          bootDevice = "/dev/sda";
          hardwareConfig = ./hosts/selonia/hardware-configuration.nix;
          networkConfig = {
            "ens3" = {
              enable = true;
              name = "ens3";
              DHCP = "yes";
              gateway = [ "fe80::1" ];
              address = [ "2a01:4f8:1c0c:4a29::1/64" ];
            };
            "ens10" = {
              name = "ens10";
              DHCP = "yes";
            };
          };
          hostname = "selonia";
          systempkgs = util.systempkgs;
          authorizedKeys = util.authorized_keys_root;
          stateVersion = "22.05";
        };
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    };
}
