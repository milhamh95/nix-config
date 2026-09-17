{ den, ... }:
{
  den.aspects.milhamh95 = {
    includes = [
      den.batteries.define-user          # users.users.<n>.home + name + HM username
      den.batteries.primary-user         # darwin: system.primaryUser
      (den.batteries.user-shell "fish")  # shell + programs.fish + environment.shells
      den.aspects.common
    ];

    # nix-darwin needs these; no battery covers them.
    # ref: https://github.com/LnL7/nix-darwin/issues/1237#issuecomment-2562242340
    darwin.users.knownUsers = [ "milhamh95" ];
    darwin.users.users.milhamh95.uid = 501;
  };
}
