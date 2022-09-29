{ system
, pkgs
, lib
}:

{
  mkHost =
    { bootDevice
    , hardwareConfig
    , networkConfig
    , hostname
    , timezone ? "Europe/Berlin"
    , systempkgs
    , authorizedKeys
    , stateVersion
    }:

    lib.nixosSystem {
      inherit system;
      modules = [
        {
          # Use the GRUB 2 boot loader.
          boot.loader.grub.enable = true;
          boot.loader.grub.version = 2;
          boot.loader.grub.efiSupport = false;
          boot.loader.grub.device = bootDevice;

          imports =
            [
              hardwareConfig
            ];


          networking.hostName = hostname;
          time.timeZone = timezone;
          nix.extraOptions = ''experimental-features = nix-command flakes'';

          networking = {
            useDHCP = false;
            useNetworkd = true;
          };

          services.openssh.enable = true;
          users.users.root.openssh.authorizedKeys.keys = authorizedKeys;

          environment.systemPackages = systempkgs;

          systemd.network.networks = networkConfig;

          programs.neovim.defaultEditor = true;
          programs.fish.enable = true;

          programs.tmux = {
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

          system.stateVersion = stateVersion;
        }
      ];
    };
}
