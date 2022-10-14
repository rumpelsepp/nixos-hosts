{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "steff";
  home.homeDirectory = "/home/steff";
  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_DBUS_REMOTE = "1";
    BAT_THEME = "1337";
    PAGER = "less";
    MANWIDTH = "80";
    MANOPT = "--nj --nh";
    MANPAGER = "nvim +Man!";
    NIXPKGS_ALLOW_UNFREE = "1";
    NIXOS_OZONE_WL = "1";
  };
  home.packages = [
    pkgs.python310Packages.ipython
    pkgs.signal-desktop
  ];

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
