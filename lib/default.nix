{ system
, pkgs
, lib
}:

{
  host = import ./host.nix { inherit system pkgs lib; };
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
    ripgrep
  ];
  authorized_keys_root = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILBQwuGetGWeXO1BVSqW72GPZ9J4Rt6G6+nMgueXQlGi rumpelsepp@kronos"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJH55JYJ4pNSoP4va/ePLMlxF3huGH5lok6uaBMDmDIM rumpelsepp@alderaan"
  ];
}
