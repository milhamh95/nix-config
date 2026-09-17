{
  den.aspects.fish-abbr.homeManager.programs.fish.shellAbbrs = {
    # Editor shortcuts
    vc = "open $1 -a \"Visual Studio Code\"";

    # Git basics
    g = "git";
    ga = "git add";
    gaa = "git add --all";
    gs = "git status";
    gss = "git status -s";
    gco = "git checkout";
    gcob = "git checkout -b";
    gcmv = "git commit -v";
    gcmm = "git commit -m";
    gbd = "git branch -D";
    gbod = "git push origin -d";

    # Git push/pull
    gpo = "git push origin";
    gpof = "git push --force-with-lease origin";
    gpoc = "git push origin (current_branch)";
    gpofc = "git push --force-with-lease origin (current_branch)";
    gplro = "git pull --rebase origin (current_branch)";

    # Git log
    gl = "git log --color --pretty=format:'%Cred%h%Creset - %s %Cgreen(%ad) %C(bold blue)<%an - %C(yellow)%ae>% %Creset' --abbrev-commit --date=format:'%Y-%m-%d %H:%M:%S'";
    gls = "git log --color --all --date-order --decorate --dirstat=lines,cumulative --stat | sed 's/\\([0-9] file[s]\\? changed\\)/\\1\\n_______\\n-------/g' | less -R";

    # File listing (lsd)
    ls = "lsd --group-dirs=first -1";
    lsaf = "lsd -AF --group-dirs=first -1";
    lsla = "lsd -la";

    # Navigation
    prsl = "cd $HOME/personal";
    fdc = "fcd";
    fdh = "fcd $HOME";

    # Dev shells
    pgshell = "nix develop .#postgres --command fish";
    rdshell = "nix develop .#redis --command fish";

    # Mise — expands to a template; edit the placeholder before running
    mu = "mise use <package_name>@<version>"; # e.g. mise use python@3.12
    mug = "mise use --global <package_name>@<version>"; # e.g. mise use --global python@3.12

    # Misc
    pch = "echo 123";
    refish = "exec fish";
  };
}
