{
  lib,
  pkgs,
  ...
}: {
  environment.variables = {
    TUCKR_CUSTOM_TARGETS = "paul";
  };

  # system.defaults.screencapture.target = lib.mkForce "clipboard";

  my =
    {
      git = {
        userName = "Snoilt";
        userEmail = "paul@oellers.net";
      };
      ssh.authorizedKeys = [
        #m4-pro
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKwq7BEz4SXNwz5gAt9mtmNz6zGV/lJ8b9CUtxS/X7yb paul@oellers.net"

        #m2-air
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAANYKheY8aMzH8VDM2TbInbXgnAKU71TncoAFor0vwE paul@oellers.net"

        #m2-air-asahi
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM6wn+iWK/JyFd6t5RICT2G7jPF5WnknGBcK5JKXYvUT paul@oellers.net"
      ];
    }

    // lib.optionalAttrs (pkgs.stdenv.hostPlatform.isDarwin) {
      homebrew = {
        taps = [
          "mhaeuser/mhaeuser" # battery toolkit
          "nikitabobko/tap" # aerospace app
          "tinygo-org/tools"
        ];
        brews = [
          "cmake"
          "dfu-util"
          "esptool"
          "opensc"
          "go-task"
          "gotestsum"
          "poppler"
          "ollama"
          "anomalyco/tap/opencode"
        ];
        casks = [
          "nikitabobko/tap/aerospace"
          "android-platform-tools"
          "audacity"
          "bambu-studio"
          "basictex"
          "battery-toolkit"
          "betterdisplay"
          "blender"
          "bruno"
          "codex"
          "codex-app"
          "dbeaver-community"
          "discord"
          "displaylink"
          "docker-desktop"
          "finicky"
          "google-chrome"
          "iterm2"
          "jordanbaird-ice@beta"
          "keepingyouawake"
          "leader-key"
          "mullvad-vpn"
          "miniconda"
          "obs"
          "obsidian"
          "openlogi"
          "prismlauncher"
          "raspberry-pi-imager"
          "raycast"
          "readdle-spark"
          "spotify"
          "stats"
          "steam"
          "telegram-desktop"
          "the-unarchiver"
          "utm"
          "visual-studio-code"
          "vlc"
          "zed"
          "zen"
        ];
      };
    };
}
