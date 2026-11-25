# mac mini build server (gitlab runner for ios) + general purpose box. has no guy, so
# everything a guy would set lives here.
#
# manual steps after the first switch:
# - turn off filevault, then enable auto-login for the user (system settings > users & groups)
#   so the per-user services below come back after a reboot / power failure
# - system settings > general > sharing: enable screen sharing (needed for novnc too)
# - grant rustdesk screen recording + accessibility, enable "start on login" in docker desktop
# - xcodes install --latest && xcodes runtimes install "iOS <version>" (needs an apple id login,
#   or download the .xip elsewhere and use xcodes install --path <file>.xip), then
#   ln -s /Applications/Xcode-<version>.app /Applications/Xcode.app for the dock
# - gitlab-runner register --executor shell (writes ~/.gitlab-runner/config.toml, not in repo)
{
  config,
  host,
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

  # novnc reads its default settings from defaults.json in the web root
  novncDefaults = (pkgs.formats.json {}).generate "novnc-defaults.json" {
    show_dot = true; # show dot when no cursor
  };
  novncWeb = pkgs.runCommand "novnc-web" {} ''
    cp -r ${pkgs.novnc}/share/webapps/novnc $out
    chmod u+w $out
    cp ${novncDefaults} $out/defaults.json
  '';

  # creates a self-signed cert on first start. without --ssl-only, websockify detects tls
  # per connection, so the same port still answers plain http
  # no spaces: the novnc launcher passes the cert path to websockify unquoted
  novncCertDir = "${userHome}/.local/share/novnc";
  novncWithCert = pkgs.writeShellScript "novnc-with-cert" ''
    set -euo pipefail

    cert="${novncCertDir}/cert.pem"
    key="${novncCertDir}/key.pem"

    if [ ! -s "$cert" ] || [ ! -s "$key" ]; then
      mkdir -p "${novncCertDir}"
      ${pkgs.openssl}/bin/openssl req -x509 -newkey rsa:2048 -nodes -days 3650 \
        -keyout "$key" -out "$cert" -subj "/CN=${host}" \
        -addext "subjectAltName=DNS:${host},DNS:${host}.local,DNS:localhost,IP:127.0.0.1"
      chmod 600 "$key"
    fi

    exec ${pkgs.novnc}/bin/novnc --listen 6080 --vnc localhost:5900 \
      --cert "$cert" --key "$key" --web ${novncWeb}
  '';
in {
  imports = [
    ./komodo-periphery.nix
  ];

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

    # with _HIHideMenuBar below: "automatically hide and show the menu bar" = never
    AppleMenuBarVisibleInFullscreen = true;
  };

  # auto-hiding menu bar is a pain over remote desktop
  system.defaults.NSGlobalDomain._HIHideMenuBar = false;

  # m2-air's dock, limited to apps installed here, helium instead of brave
  system.defaults.dock.persistent-apps = [
    "/System/Applications/System Settings.app"
    "/Applications/Helium.app"
    "/Applications/iTerm.app"
    "/Applications/Xcode.app"
    "/Applications/Docker.app"
  ];

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

  # browser remote desktop, proxies macos screen sharing. port 6080 serves both:
  # - https://<host>:6080/vnc.html with a self-signed cert (accept the warning once)
  # - http://<host>:6080/vnc.html for a reverse proxy that terminates tls itself
  # screen sharing's login needs browser crypto, which only exists on https or localhost,
  # so plain http only works from localhost or behind that proxy
  launchd.user.agents.novnc.serviceConfig = {
    ProgramArguments = ["${novncWithCert}"];
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
