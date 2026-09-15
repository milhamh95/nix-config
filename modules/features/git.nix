{ self, ... }:
{
  den.aspects.git = {
    darwin.homebrew.brews = [ "gh" ];

    homeManager = {
      home.file = {
        ".gitignore" = self.lib.dotfile {
          path = "git/.gitignore";
          label = "Git ignore";
        };
        ".config/git/catppuccin-delta.gitconfig" = self.lib.dotfile {
          path = "git/catppuccin-delta.gitconfig";
          label = "Catppuccin delta theme";
        };
      };

      programs.git = {
        enable = true;

        settings = {
          user = {
            name = "Muhammmad Ilham Hidayat";
            email = "m.ilham.hidayat.95@gmail.com";
          };
          init.defaultBranch = "main";
          pull.rebase = true;
          core = {
            excludesfile = "~/.gitignore";
            editor = "code --wait";
          };
          merge.conflictstyle = "diff3";
          diff.colorMoved = "default";
          filter.lfs = {
            clean = "git-lfs clean -- %f";
            smudge = "git-lfs smudge -- %f";
            process = "git-lfs filter-process";
            required = true;
          };
          url."git@github.com:".insteadOf = "https://github.com/";
        };

        includes = [
          { path = "~/.config/git/catppuccin-delta.gitconfig"; }
        ];
      };

      programs.delta = {
        enable = true;
        options = {
          features = "catppuccin-mocha";
          navigate = true;
          line-numbers = true;
          side-by-side = false;
        };
      };
    };
  };
}
