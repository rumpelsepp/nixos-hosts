{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "steff";
  home.homeDirectory = "/home/steff";

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
          # pager = "delta --diff-highlight";
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
    home-manager.enable = true;
  };
}
