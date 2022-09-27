# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.efiSupport = false;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  networking.hostName = "selonia"; # Define your hostname.
  services.resolved.enable = true;

  networking = {
    useDHCP = false;
    useNetworkd = true;
  };

  systemd.network.networks = {
    "ens3" = {
      enable = true;
      name = "ens3";
      DHCP = "yes";
      gateway = [ "fe80::1" ];
      address = [ "2a01:4f8:1c0c:4a29::/64" ];
    };
    "ens10" = {
      name = "ens10";
      DHCP = "yes";
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  nix.extraOptions = ''experimental-features = nix-command flakes'';

  # Define a user account. Don't forget to set a password with ‘passwd’.                                                                                                                                                         
  users.users.steff = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILBQwuGetGWeXO1BVSqW72GPZ9J4Rt6G6+nMgueXQlGi rumpelsepp@kronos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJH55JYJ4pNSoP4va/ePLMlxF3huGH5lok6uaBMDmDIM rumpelsepp@alderaan"
    ];
    #  packages = with pkgs; [                                                                                                                                                                                                     
    #    firefox                                                                                                                                                                                                                   
    #    thunderbird                                                                                                                                                                                                               
    #  ];                                                                                                                                                                                                                          
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILBQwuGetGWeXO1BVSqW72GPZ9J4Rt6G6+nMgueXQlGi rumpelsepp@kronos"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJH55JYJ4pNSoP4va/ePLMlxF3huGH5lok6uaBMDmDIM rumpelsepp@alderaan"
  ];

  # List packages installed in system profile. To search, run:                                                                                                                                                                   
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    curl
    tmux
    neovim
    htop
    fish
    git
    nftables
  ];

  programs.neovim.defaultEditor = true;
  programs.tmux = {
    enable = true;
    escapeTime = 50;
    keyMode = "vi";
    terminal = "tmux-256color";
    clock24 = true;
    historyLimit = 999999;
    secureSocket = false;
    extraConfig = ''
      set-option -g default-shell /run/current-system/sw/bin/fish
      set-option -g set-titles on
      set-option -g set-titles-string "tmux [#H]: #S:#W"
      set-option -g set-clipboard on
      set-option -g renumber-windows on
      set-option -g status-right ""

      set-option -g mouse on
      set-option -g focus-events on

      # Enable true color stuff
      set-option -sa terminal-overrides ',alacritty:RGB'
      set-option -sa terminal-overrides ',foot:RGB'

      # Enable undercurl shit
      set-option -sa terminal-overrides ',*:Smulx=\E[4::%p1%dm'  # undercurl support
      set-option -sa terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m' 

      bind-key "c" new-window -c "#{pane_current_path}"
      bind-key '"' split-window -c "#{pane_current_path}"
      bind-key "%" split-window -h -c "#{pane_current_path}"
      bind-key "/" copy-mode \; send-key /'';
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}

