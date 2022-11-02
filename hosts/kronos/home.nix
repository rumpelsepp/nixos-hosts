{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "steff";
  home.homeDirectory = "/home/steff";
  home.sessionVariables =
    let
      makePluginPath = format:
        (pkgs.lib.strings.makeSearchPath format [
          "$HOME/.nix-profile/lib"
          "/run/current-system/sw/lib"
          "/etc/profiles/per-user/$USER/lib"
        ])
        + ":$HOME/.${format}";
    in
    {
      DSSI_PATH = makePluginPath "dssi";
      LADSPA_PATH = makePluginPath "ladspa";
      LV2_PATH = makePluginPath "lv2";
      LXVST_PATH = makePluginPath "lxvst";
      VST_PATH = makePluginPath "vst";
      VST3_PATH = makePluginPath "vst3";
      MOZ_DBUS_REMOTE = "1";
      PAGER = "less";
      MANWIDTH = "80";
      MANOPT = "--nj --nh";
      MANPAGER = "nvim +Man!";
      NIXPKGS_ALLOW_UNFREE = "1";
      NIXOS_OZONE_WL = "1";
    };

  home.packages = with pkgs; [
    # wine
    # gnupg
    alacritty
    chromium
    cifs-utils
    curl
    dconf
    delta
    fd
    file
    foot
    gnumake
    gopass
    hexyl
    inkscape
    keyutils
    killall
    libinput
    libreoffice
    lsp-plugins
    man-pages
    man-pages-posix
    musescore
    ncdu_2
    networkmanagerapplet
    nftables
    nmap
    openssl_3
    pavucontrol
    pwgen
    python310
    python310Packages.ipython
    qemu_full
    qpwgraph
    qrencode
    rclone
    restic
    ripgrep
    rustup
    sequoia
    signal-desktop
    tokei
    tree
    tuxguitar
    unzip
    usbutils
    vlc
    wget
    wineWowPackages.waylandFull
    wl-clipboard
    xplr
    yabridge
    yabridgectl
    yt-dlp
    zam-plugins
    zip
  ];

  xdg.desktopEntries = {
    signal-wayland = {
      name = "Signal Wayland";
      mimeType = [ "x-scheme-handler/sgnl" "x-scheme-handler/signalcaptcha" ];
      icon = "signal-desktop";
      categories = [ "Application" ];
      exec = "signal-desktop --enable-features=WaylandWindowDecorations --no-sandbox %U";
    };
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs = {
    bat = {
      enable = true;
      config.theme = "1337";
    };
    bash.enable = true;
    broot = {
      enable = true;
      enableFishIntegration = true;
    };
    chromium.enable = true;
    fish = {
      enable = true;
      shellAliases = {
        ip = "ip --color=auto";
        now = "date +%F_%T";
        now-raw = "date +%Y%m%d%H%M";
        today = "date +%F";
        hd = "hexdump -C";
        o = "gio open";
      };
      interactiveShellInit = ''
        complete -c hd -w hexdump
        complete -c o -w "gio open"

        set fish_greeting

        functions -c fish_prompt __old_fish_prompt

        function fish_prompt
            # Run the default prompt first.
            set -l prompt (__old_fish_prompt)

            if test -n "$IN_NIX_SHELL"
                printf '(nix shell) '
            end

            string join -- \n $prompt # handle multi-line prompts
        end

        function __fish_set_oldpwd --on-variable dirprev
            set -g OLDPWD $dirprev[-1]
        end

        function cd-root
            cd "$(git rev-parse --show-toplevel)"
        end'';
    };
    firefox = {
      enable = true;
      package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
        forceWayland = true;
        extraPolicies = {
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DisableTelemetry = true;
          FirefoxHome = {
            Pocket = false;
            Snippets = false;
          };
          UserMessaging = {
            ExtensionRecommendations = false;
            SkipOnboarding = true;
          };
          # SecurityDevices = {
          #   # Use a proxy module rather than `nixpkgs.config.firefox.smartcardSupport = true`
          #   "PKCS#11 Proxy Module" = "${pkgs.p11-kit}/lib/p11-kit-proxy.so";
          # };
        };
      };
    };
    tmux = {
      enable = true;
      escapeTime = 50;
      keyMode = "vi";
      terminal = "tmux-256color";
      clock24 = true;
      secureSocket = false;
      shell = "${pkgs.fish}/bin/fish";
      extraConfig = ''
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
        set-option -sa terminal-overrides ',xterm-256color:RGB'
        bind-key "c" new-window -c "#{pane_current_path}"
        bind-key '"' split-window -c "#{pane_current_path}"
        bind-key "%" split-window -h -c "#{pane_current_path}"
        bind-key "/" copy-mode \; send-key /'';
    };
    fzf = {
      enable = true;
      enableFishIntegration = true;
      defaultCommand = "fd --type f";
      tmux.enableShellIntegration = true;
    };
    gh.enable = true;
    git = {
      enable = true;
      aliases = {
        st = "status";
        sw = "switch";
        co = "checkout";
        ci = "commit";
        cm = "commit -m";
        br = "branch";
        ba = "branch -a -vv";
        rs = "restore";
        ri = "rebase --autosquash --autostash --interactive";
        cleanmerged = "!git branch --merged | grep -v master | xargs git branch -d";
        cleantracking = "!git branch --remote --merged | grep -v master | xargs git branch -r -d";
      };
      includes = [
        {
          contents = {
            user = {
              name = "Stefan Tatschner";
              email = "stefan@rumpelsepp.org";
            };
          };
        }
        {
          condition = "gitdir:~/Projects/work/";
          contents = {
            user = {
              name = "Stefan Tatschner";
              email = "stefan.tatschner@aisec.fraunhofer.de";
            };
          };
        }
      ];
      extraConfig = {
        core = {
          editor = "nvim +1";
          autocrlf = "input";
        };
        checkout.workers = 0;
        credential.helper = "cache";
        log.decorate = "short";
        pull.rebase = true;
        push.autoSetupRemote = true;
        rebase.autosquash = true;
        status.short = true;
      };
      delta = {
        enable = true;
        options = {
          navigate = true;
          light = false;
          line-numbers = true;
          diff-highlight = true;
        };
      };
    };
    helix = {
      enable = true;
      settings = {
        theme = "dark_plus";
        editor = {
          color-modes = true;
          true-color = true;
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
          indent-guides = {
            render = true;
            character = "╎";
          };
          lsp.auto-signature-help = false;
        };
      };
    };
    less.enable = true;
    jq.enable = true;
    lsd = {
      enable = true;
      enableAliases = true;
      settings = {
        date = "+%d. %b %y %H:%M";
        icons.when = "never";
      };
    };
    man = {
      enable = true;
      generateCaches = true;
    };
    obs-studio = {
      enable = true;
      plugins = [ pkgs.obs-studio-plugins.obs-pipewire-audio-capture ];
    };
    ssh = {
      enable = true;
      serverAliveInterval = 25;
      extraConfig = "AddKeysToAgent yes";
      matchBlocks = {
        "storagebox" = {
          hostname = "u160551.your-storagebox.de";
          port = 23;
          user = "u160551";
        };
        "aur" = {
          hostname = "aur.archlinux.org";
          identityFile = "~/.ssh/aur";
          user = "aur";
        };
        "pwner" = {
          hostname = "pin-rpi2.aisec.fraunhofer.de";
          user = "rumpelsepp";
        };
        "pin-storage" = {
          hostname = "storage.pin.aisec.fraunhofer.de";
          user = "steff";
          identityFile = "~/.ssh/id_ed25519.pub";
        };
      };
    };
    texlive.enable = true;
    home-manager.enable = true;
    nix-index = {
      enable = true;
      enableFishIntegration = true;
    };
    zellij.enable = true;
    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
