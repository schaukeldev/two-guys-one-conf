{
  config,
  lib,
  ...
}: {
  options.my.homebrew = {
    taps = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Homebrew taps to install.";
      default = [];
    };
    brews = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Homebrew packages to install.";
      default = [];
    };
    casks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Homebrew casks to install.";
      default = [];
    };
    masApps = lib.mkOption {
      type = lib.types.attrsOf lib.types.int;
      description = "Apps from the Mac App Store to install.";
      default = {};
    };
  };

  config = {
    nix-homebrew = {
      enable = true;
      user = config.my.username;
      enableRosetta = true;
      autoMigrate = true;
    };

    homebrew = {
      enable = true;
      # caskArgs.no_quarantine = true;
      global = {
        autoUpdate = false;
      };
      onActivation = {
        cleanup = "zap";
        upgrade = false;
      };
      brews = lib.mkBefore (["mas"] ++ config.my.homebrew.brews);
      taps = config.my.homebrew.taps;
      casks = config.my.homebrew.casks;
      masApps = lib.mkMerge [
        {
          Xcode = 497799835;
          WireGuard = 1451685025;
        }
        config.my.homebrew.masApps
      ];
    };
  };
}
