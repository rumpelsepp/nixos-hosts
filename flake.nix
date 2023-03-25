{
  inputs = {
    # nixpkgs.url = "nixpkgs/nixos-22.11";
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    # Pin this for virtualbox…
    nixpkgs-master.url = "github:NixOS/nixpkgs";
    # nixpkgs.url = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    helix.url = "github:helix-editor/helix";

    home-manager = {
      # url = "github:nix-community/home-manager/release-22.11";
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-master, home-manager, nixos-hardware, helix, ... }:
    let
      inherit (nixpkgs) lib;
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
      };
      pkgs-master = import nixpkgs-master {
        inherit system;
        config = { allowUnfree = true; };
      };
      util = import ./lib { inherit system pkgs lib; };
      kronos-config = import ./hosts/kronos/configuration.nix;
    in
    {
      nixosConfigurations = {
        kronos = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            kronos-config
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.steff = import ./hosts/kronos/home.nix { inherit pkgs-master helix; };
            }
            nixos-hardware.nixosModules.lenovo-thinkpad-t470s
          ];
        };
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
