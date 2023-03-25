{ pkgs-master, helix }:
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
      SDL_VIDEODRIVER = "wayland";
      QT_QPA_PLATFORM = "wayland";
      EDITOR = "hx";
      LIBVA_DRIVER_NAME = "iHD";

      # https://github.com/NixOS/nixpkgs/issues/195936#issuecomment-1278954466
      GST_PLUGIN_SYSTEM_PATH_1_0 = pkgs.lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (with pkgs.gst_all_1; [
        gst-plugins-good
        gst-plugins-bad
        gst-plugins-ugly
        gst-libav
      ]);
    };

  home.packages = with pkgs; [
    _7zz
    asciiquarium
    can-utils
    chromium
    cifs-utils
    curl
    dconf
    delta
    difftastic
    dnsmasq
    dos2unix
    fd
    ffmpeg
    file
    gimp
    gitoxide
    gnumake
    # gnupg
    # gopass
    gopro
    gst_all_1.gst-vaapi
    hexyl
    hyperfine
    imagemagick
    inkscape
    intel-gpu-tools
    just
    keyutils
    killall
    libinput
    libmediainfo
    libreoffice
    libva-utils
    lsp-plugins
    man-pages
    man-pages-posix
    ncdu_2
    netcat-openbsd
    networkmanagerapplet
    nftables
    nmap
    openssl_3
    pandoc
    pavucontrol
    pdftk
    pinentry-gnome
    # pitivi
    pwgen
    pwntools
    python310
    python310Packages.ipython
    python310Packages.pygments
    qemu_full
    qjackctl
    qpwgraph
    qrencode
    rclone
    restic
    ripgrep
    sequoia
    shfmt
    socat
    taskwarrior
    texlive.combined.scheme-full
    tlp
    tokei
    tree
    tuxguitar
    unzip
    usbutils
    vlc
    websocat
    wget
    # wine
    wineWowPackages.waylandFull
    wireshark-qt
    wl-clipboard
    xplr
    yabridge
    yabridgectl
    yt-dlp
    zam-plugins
    zip
    kooha
    video-trimmer
    # gnome-decoder
    signal-desktop
    gopass
    musescore
    alsa-scarlett-gui
    oscclip
  ] ++ (with pkgs-master; [
    gallia
    kdenlive
    reaper
    # davinci-resolve
    # openshot-qt
    fractal-next
  ]);

  home.file = {
    ".local/bin/tmux-osc7.sh" = {
      text = ''
        #!${pkgs.bash}/bin/bash

        tmux display-message -p -F "#{pane_path}" | sed "s|file://$(hostname)||"
      '';
      executable = true;
    };
    ".local/bin/echoh" = {
      source = ../../scripts/echoh.py;
      executable = true;
    };
    ".local/bin/trimws" = {
      source = ../../scripts/trimws.sed;
      executable = true;
    };
    ".local/bin/bookmark-add" = {
      source = ../../scripts/bookmark-add.py;
      executable = true;
    };
    ".local/bin/backup" = {
      source = ../../scripts/backup-kronos.sh;
      executable = true;
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

  services = {
    pulseeffects.enable = false;
  };

  programs = {
    atuin = {
      enable = true;
      enableFishIntegration = true;
      flags = [ "--disable-up-arrow" "--disable-ctrl-r" ];
    };
    alacritty = {
      enable = true;
      settings = {
        font.size = 10;
        shell.program = "${pkgs.fish}/bin/fish";
        colors = {
          # https://gitlab.gnome.org/GNOME/console/-/blob/main/src/kgx-terminal.c#L141
          # Default colors
          primary = {
            background = "0x1e1e1e";
            foreground = "0xffffff";
          };
          # Normal colors
          normal = {
            black = "0x241f31";
            red = "0xc01c28";
            green = "0x2ec27e";
            yellow = "0xf5c211";
            blue = "0x1e78e4";
            magenta = "0x9841bb";
            cyan = "0x0ab9dc";
            white = "0xc0bfbc";
          };
          # Bright colors
          bright = {
            black = "0x5e5c64";
            red = "0xed333b";
            green = "0x57e389";
            yellow = "0xf8e45c";
            blue = "0x51a1ff";
            magenta = "0xc061cb";
            cyan = "0x4fd2fd";
            white = "0xf6f5f4";
          };
        };
      };
    };
    foot = {
      enable = true;
      # https://gitlab.gnome.org/GNOME/console/-/blob/main/src/kgx-terminal.c#L141
      settings = {
        main ={
          shell = "${pkgs.fish}/bin/fish";
          font = "monospace:size=10";
        };
        colors = {
          background = "000000";
          foreground = "ffffff";
          regular0 = "241f31";
          regular1 = "c01c28";
          regular2 = "2ec27e";
          regular3 = "f5c211";
          regular4 = "1e78e4";
          regular5 = "9841bb";
          regular6 = "0ab9dc";
          regular7 = "c0bfbc";
          bright0 = "5e5c64";
          bright1 = "ed333b";
          bright2 = "57e389";
          bright3 = "f8e45c";
          bright4 = "51a1ff";
          bright5 = "c061cb";
          bright6 = "4fd2fd";
          bright7 = "f6f5f4";
        };
      };
    };
    kitty = {
      enable = true;
    };
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

        # Hack because tmux is not supported for osc7.
        # It is checked if this function already exists.
        # XXX: Report this upstream.
        if test "$TERM_PROGRAM" = tmux && ! functions -a | string match "__update_cwd_osc" > /dev/null
          function __update_cwd_osc --on-variable PWD --description 'Notify capable terminals when $PWD changes'
              if status --is-command-substitution || set -q INSIDE_EMACS
                  return
              end
              printf \e\]7\;file://%s%s\a $hostname (string escape --style=url $PWD)
          end
          __update_cwd_osc # Run once because we might have already inherited a PWD from an old tab
        end

        set fish_greeting
        set fish_command_not_found

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
          SecurityDevices = {
            # Use a proxy module rather than `nixpkgs.config.firefox.smartcardSupport = true`
            # "PKCS#11 Proxy Module" = "${pkgs.p11-kit}/lib/p11-kit-proxy.so";
          };
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
        set-option -as terminal-features ",xterm-256color:RGB"
        set-option -as terminal-features ",alacritty:RGB"
        set-option -as terminal-features ",foot:RGB"

        bind-key "c" run-shell 'tmux new-window -c "$(tmux-osc7.sh)"'
        bind-key '"' run-shell 'tmux split-window -c "$(tmux-osc7.sh)"'
        bind-key "%" run-shell 'tmux split-window -h -c "$(tmux-osc7.sh)"'
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
          editor = "hx";
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
      package = helix.packages."x86_64-linux".default;
      settings = {
        keys.normal = {
          m.l = [ "extend_to_line_bounds" "trim_selections" ];
          D = [ "extend_to_line_end" "delete_selection" ];
          L = [ "extend_to_line_bounds" "delete_selection_noyank" "open_above" ];
          # Swap x and X: https://github.com/helix-editor/helix/discussions/835
          # X = [ "extend_line_below" ];
          # x = [ "extend_to_line_bounds" ]; 
        };
        theme = "dark_plus";
        editor = {
          color-modes = true;
          true-color = true;
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
          # auto-save = true;
          # bufferline = "multiple";
          indent-guides = {
            render = true;
            character = "╎";
          };
          soft-wrap.enable = true;
          lsp = {
            auto-signature-help = false;
            display-inlay-hints = true;
          };
        };
      };
      languages = [
        {
          name = "go";
          formatter = { command = "goimports"; };
          auto-format = true;
        }
        {
          name = "bash";
          indent = { tab-width = 4; unit = "\t"; };
          formatter = { command = "shfmt"; };
        }
      ];
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
    mpv = {
      enable = true;
      scripts = [ pkgs.mpvScripts.mpris ];
    };
    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        obs-pipewire-audio-capture
        obs-gstreamer
      ];
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
        "pin-storage" = {
          hostname = "storage.pin.aisec.fraunhofer.de";
          user = "steff";
          identityFile = "~/.ssh/id_ed25519.pub";
        };
      };
    };
    vscode = {
      enable = true;
    };
    # texlive.enable = true;
    home-manager.enable = true;
    zellij.enable = true;
  };
}
