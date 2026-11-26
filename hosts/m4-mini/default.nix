# mac mini build server (gitlab runner for ios) + general purpose box. has no guy, so
# everything a guy would set lives here.
#
# the ci account (auto-login, gitlab runner, docker) lives in ci.nix, komodo in
# komodo-periphery.nix. both have their own manual steps.
#
# manual steps after the first switch:
# - turn off filevault, auto-login needs it off
# - system settings > general > sharing: enable screen sharing (needed for novnc too)
# - xcodes install --latest && xcodes runtimes install "iOS <version>" (needs an apple id login,
#   or download the .xip elsewhere and use xcodes install --path <file>.xip), then
#   ln -s /Applications/Xcode-<version>.app /Applications/Xcode.app for the dock
{
  config,
  host,
  lib,
  pkgs,
  ...
}: let
  userHome = "/Users/${config.my.username}";
  logDir = "${userHome}/Library/Logs";

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
    ./all-users.nix
    ./ci.nix
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
  # so plain http only works from localhost or behind that proxy.
  # a daemon running as o rather than o's agent, so it's up from boot whoever is logged in
  # (ci auto-logs in, o usually isn't). it only relays to screen sharing, no gui needed
  # command (not ProgramArguments) makes nix-darwin wait for /nix/store, which isn't mounted
  # yet when launchd starts daemons at boot
  launchd.daemons.novnc.command = "${novncWithCert}";
  launchd.daemons.novnc.serviceConfig = {
    UserName = config.my.username;
    WorkingDirectory = userHome;
    RunAtLoad = true;
    KeepAlive = true;
    StandardOutPath = "${logDir}/novnc.out.log";
    StandardErrorPath = "${logDir}/novnc.err.log";
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
