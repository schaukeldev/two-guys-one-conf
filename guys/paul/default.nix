{
  lib,
  isDarwin,
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
      ssh.authorizedKeys = import ./ssh-keys.nix;
    }
    // lib.optionalAttrs isDarwin {
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
