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

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.efiSupport = false;
  boot.loader.grub.device = "/dev/nvme0n1"; # or "nodev" for efi only
  boot.tmpOnTmpfs = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking = {
    hostName = "kronos";
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
      firewallBackend = "nftables";
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    #   font = "Lat2-Terminus16";
    #   keyMap = "us";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
  ]) ++ (with pkgs.gnome; [
    cheese # webcam tool
    gnome-music
    gnome-software
    gnome-terminal
    epiphany # web browser
    geary # email reader
    totem # video player
  ]);

  programs = {
    neovim = {
      enable = true;
      vimAlias = true;
      viAlias = true;
      defaultEditor = true;
    };

    wireshark.enable = true;
    git.enable = true;
    htop.enable = true;
    iotop.enable = true;
    iftop.enable = true;

    evolution = {
      enable = true;
      plugins = [ pkgs.evolution-ews ];
    };

    fish = {
      enable = true;
      shellInit = "set fish_greeting";
    };

    tmux = {
      enable = true;
      escapeTime = 50;
      keyMode = "vi";
      terminal = "tmux-256color";
      clock24 = true;
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
        bind-key "c" new-window -c "#{pane_current_path}"
        bind-key '"' split-window -c "#{pane_current_path}"
        bind-key "%" split-window -h -c "#{pane_current_path}"
        bind-key "/" copy-mode \; send-key /'';
    };
  };

  fonts = {
    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
      jetbrains-mono
      nerdfonts
    ];
    fontconfig = {
      defaultFonts = {
        serif = [ "Noto" "Serif" ];
        sansSerif = [ "Noto" "Sans" ];
        monospace = [ "Jetbrains Mono" ];
      };
    };
  };

  environment.sessionVariables = rec {
    XDG_CACHE_HOME = "\${HOME}/.cache";
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XDG_BIN_HOME = "\${HOME}/.local/bin";
    XDG_DATA_HOME = "\${HOME}/.local/share";

    PATH = [
      "\${XDG_BIN_HOME}"
    ];
  };

  security.rtkit.enable = true;
  hardware.pulseaudio.enable = false;
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.steff = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "wireshark" ];
    packages = with pkgs; [
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    curl
    firefox
    man-pages
    man-pages-posix
    nftables
    ripgrep
    fd
    lsd
    texlive.combined.scheme-full
    tree
    wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  services = {
    resolved = {
      enable = true;
      dnssec = "false";
    };

    printing.enable = true;

    xserver = {
      enable = true;
      layout = "de";
      xkbVariant = "neo";
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

    flatpak.enable = true;

    # Enable the GNOME Desktop Environment.
    gnome.gnome-keyring.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };

  # xdg = {
  #   portal.gtkUsePortal = true;
  # };



  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}