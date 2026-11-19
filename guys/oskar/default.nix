{
  lib,
  pkgs,
  config,
  isDarwin,
  ...
}:
{
  environment.variables = {
    TUCKR_CUSTOM_TARGETS = "oskar";
  };

  home-manager = lib.optionalAttrs isDarwin {
    users.${config.my.username}.services.syncthing.enable = true;
  };

  environment.systemPackages = with pkgs; [
    imagemagick
  ];

  my =
    {
      git = {
        userName = "vaaski";
        userEmail = "admin@vaa.ski";
      };

      ssh.authorizedKeys = import ./ssh-keys.nix;
    }
    // lib.optionalAttrs isDarwin {
      homebrew = {
        taps = [
          "tinygo-org/tools"
        ];
        brews = [
          "anomalyco/tap/opencode-v2"
          "cmake"
          "dfu-util" # USB programmer
          "esptool" # ESP8266 and ESP32 serial bootloader utility
          "mole" # Mac cleaner
          "opensc" # Tools and libraries for smart cards
        ];
        casks = [
          "android-platform-tools"
          "android-studio"
          "audacity"
          "bambu-studio"
          "betterdisplay"
          "bettertouchtool"
          "blender"
          "brave-browser"
          "bruno"
          "claude"
          "claude-code"
          "connectmenow"
          "dbeaver-community"
          "discord"
          "displaylink"
          "docker-desktop"
          "finicky"
          "handy"
          "home-assistant"
          "iina" # video player
          "iterm2"
          "linearmouse"
          "macpacker"
          "mullvad-vpn"
          "naps2"
          "obs"
          "obsidian"
          "opencode-desktop"
          "prismlauncher"
          "raspberry-pi-imager"
          "raycast"
          "readdle-spark"
          "rectangle-pro"
          "saffsanity/sill/sill"
          "spotify"
          "stats"
          "steam"
          "telegram-desktop"
          "thaw@beta"
          "utm"
          "visual-studio-code"
          "vorssaint"
          "zed"
        ];
      };
    };
}
// lib.optionalAttrs isDarwin {
  launchd.user.agents.opencode.serviceConfig = {
    ProgramArguments = [
      "${config.homebrew.prefix}/bin/opencode"
      "service"
      "start"
    ];
    RunAtLoad = true;
    StandardOutPath = "/Users/${config.my.username}/Library/Logs/opencode-launchagent.out.log";
    StandardErrorPath = "/Users/${config.my.username}/Library/Logs/opencode-launchagent.err.log";
  };
}
