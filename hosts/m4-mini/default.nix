# mac mini build server (gitlab runner for ios) + general purpose box. has no guy, so
# everything a guy would set lives here.
#
# manual steps after the first switch:
# - turn off filevault, then enable auto-login for the user (system settings > users & groups)
#   so the per-user services below come back after a reboot / power failure
# - system settings > general > sharing: enable screen sharing (needed for novnc too)
# - grant rustdesk screen recording + accessibility, enable "start on login" in docker desktop
# - xcodes install --latest && xcodes runtimes install "iOS <version>" (needs an apple id login,
#   or download the .xip elsewhere and use xcodes install --path <file>.xip)
# - gitlab-runner register --executor shell (writes ~/.gitlab-runner/config.toml, not in repo)
{
  config,
  lib,
  pkgs,
  ...
}: let
  userHome = "/Users/${config.my.username}";
  logDir = "${userHome}/Library/Logs";

  # launchd agents don't get the login shell PATH, so ci jobs would miss nix/brew tools
  servicePath = lib.concatStringsSep ":" [
    "${config.homebrew.prefix}/bin"
    "${config.homebrew.prefix}/sbin"
    "/etc/profiles/per-user/${config.my.username}/bin"
    "/run/current-system/sw/bin"
    "/nix/var/nix/profiles/default/bin"
    "/usr/local/bin"
    "/usr/bin"
    "/bin"
    "/usr/sbin"
    "/sbin"
  ];
in {
  nixpkgs.hostPlatform = "aarch64-darwin";

  environment.variables = {
    TUCKR_CUSTOM_TARGETS = "oskar";
  };

  environment.systemPackages = [
    pkgs.gitlab-runner
  ];

  my = {
    # no git identity: commits made on this box are unsigned
    ssh.authorizedKeys = import ../../guys/oskar/ssh-keys.nix;

    homebrew = {
      brews = [
        "cocoapods"
        "fastlane"
        "mole" # Mac cleaner
        "xcodes" # Xcode versions + simulator runtimes
      ];
      casks = [
        "bruno"
        "dbeaver-community"
        "docker-desktop"
        "helium-browser"
        "iina" # video player
        "iterm2"
        "linearmouse"
        "macpacker"
        "raycast"
        "rustdesk"
        "stats"
        "zed"
      ];
    };
  };

  # no app store sign-in on this box, xcode comes from xcodes instead
  homebrew.masApps = lib.mkForce {};

  system.defaults.CustomUserPreferences."NSGlobalDomain" = {
    NSColorSimulateHardwareAccent = null;
    NSColorSimulatedHardwareEnclosureNumber = null;
    AppleAccentColor = 6;
  };

  # - power ------------------------------------------------------------------------------

  power = {
    sleep = {
      computer = "never";
      harddisk = "never";
    };
    restartAfterPowerFailure = true;
    restartAfterFreeze = true;
  };

  networking.wakeOnLan.enable = true;

  # - remote access ----------------------------------------------------------------------

  services.openssh.enable = true;

  # browser remote desktop on http://<host>:6080/vnc.html, proxies macos screen sharing.
  # plain http: keep it on the lan / behind a vpn
  launchd.user.agents.novnc.serviceConfig = {
    ProgramArguments = [
      "${pkgs.novnc}/bin/novnc"
      "--listen"
      "6080"
      "--vnc"
      "localhost:5900"
    ];
    WorkingDirectory = userHome;
    RunAtLoad = true;
    KeepAlive = true;
    StandardOutPath = "${logDir}/novnc.out.log";
    StandardErrorPath = "${logDir}/novnc.err.log";
  };

  # - gitlab runner ----------------------------------------------------------------------

  # runs as the logged-in user (not nix-darwin's services.gitlab-runner daemon) because ios
  # builds need a gui session for code signing keychains and simulators
  launchd.user.agents.gitlab-runner.serviceConfig = {
    ProgramArguments = [
      "${pkgs.gitlab-runner}/bin/gitlab-runner"
      "run"
      "--working-directory"
      userHome
      "--config"
      "${userHome}/.gitlab-runner/config.toml"
    ];
    EnvironmentVariables.PATH = servicePath;
    WorkingDirectory = userHome;
    RunAtLoad = true;
    KeepAlive = true;
    ProcessType = "Interactive";
    StandardOutPath = "${logDir}/gitlab-runner.out.log";
    StandardErrorPath = "${logDir}/gitlab-runner.err.log";
  };

  # - nix store --------------------------------------------------------------------------

  nix.gc = {
    automatic = true;
    interval = {
      Weekday = 0;
      Hour = 4;
      Minute = 0;
    };
    options = "--delete-older-than 14d";
  };
  nix.optimise.automatic = true;
}
