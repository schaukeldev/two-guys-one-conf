# dock and menu bar for every account on this box, including ones added later.
#
# nix-darwin only writes these preferences for the primary user (o), so a system agent sets
# them at each login for everyone else. the dock's apps are only set once per account, so
# people can rearrange their dock afterwards. bump dockVersion to push a changed list again.
{
  config,
  lib,
  pkgs,
  ...
}: let
  dockApps = [
    "/System/Applications/Apps.app"
    "/System/Applications/System Settings.app"
    "/Applications/Helium.app"
    "/Applications/iTerm.app"
    "/Applications/Xcode.app"
    "/Applications/Docker.app"
  ];
  dockVersion = "1";

  dockutil = "${pkgs.dockutil}/bin/dockutil";

  applySettings = pkgs.writeShellScript "m4-mini-user-settings" ''
    set -euo pipefail

    # o's preferences are managed by nix-darwin itself
    [ "$(id -un)" = "${config.my.username}" ] && exit 0

    # menu bar never hides, on the desktop and in full screen
    defaults write -g _HIHideMenuBar -bool false
    defaults write -g AppleMenuBarVisibleInFullscreen -bool true

    defaults write com.apple.dock autohide -bool false

    marker="$HOME/Library/Preferences/m4-mini-dock-v${dockVersion}"
    if [ ! -e "$marker" ]; then
      ${dockutil} --remove all --no-restart
      for app in ${lib.escapeShellArgs dockApps}; do
        if [ -e "$app" ]; then
          ${dockutil} --add "$app" --no-restart
        fi
      done
      touch "$marker"
    fi

    killall Dock || true
  '';
in {
  # o's dock, through nix-darwin
  system.defaults.dock = {
    persistent-apps = dockApps;
    # modules/darwin.nix auto-hides the dock everywhere, a pain over remote desktop
    autohide = lib.mkForce false;
  };

  # everyone else's, at each login
  launchd.agents.m4-mini-user-settings.serviceConfig = {
    ProgramArguments = ["${applySettings}"];
    LimitLoadToSessionType = "Aqua";
    RunAtLoad = true;
  };
}
