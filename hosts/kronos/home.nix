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
    BAT_THEME = "1337";
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
    bat
    chromium
    cifs-utils
    curl
    dconf
    delta
    fd
    file
    foot
    fzf
    gnumake
    gopass
    hexyl
    inkscape
    jq
    keyutils
    killall
    libinput
    libreoffice
    lsd
    lsp-plugins
    man-pages
    man-pages-posix
    musescore
    ncdu_2
    networkmanagerapplet
    nftables
    nmap
    obs-studio
    obs-studio-plugins.obs-pipewire-audio-capture
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
    texlive.combined.scheme-full
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
    bat.enable = true;
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
        ls = "lsd";
        now = "date +%F_%T";
        now-raw = "date +%Y%m%d%H%M";
        today = "date +%F";
        hd = "hexdump -C";
        o = "gio open";
      };
      interactiveShellInit = ''
        complete -c hd -w hexdump
        complete -c o -w "gio open"
        complete -c ls -w "lsd"

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
    home-manager.enable = true;
  };
}
