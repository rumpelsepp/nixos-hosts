{ system
, pkgs
}:

{
  mkHost =
    { hostname
    , timezone ? "Europe/Berlin"
    , systempkgs
    , authorizedKeys
    , stateVersion
    }:

    {
      pgks.lib.nixosSystem = {
        inherit system;
        modules = [
          {
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

            programs.neovim.defaultEditor = true;

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
    };
}
