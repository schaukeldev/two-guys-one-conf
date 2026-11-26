# o's look and feel for every account on this box, including ones added later. only the
# desktop background differs per account, so you can tell sessions apart over remote desktop.
#
# nix-darwin only writes preferences for the primary user (o). a system agent runs at every
# login of every other account and applies:
# - all of o's macos preferences (system.defaults: dock, finder, keyboard, menu bar, ...),
#   by replaying the defaults script nix-darwin generates for o. so changing system.defaults
#   anywhere in this config changes it for everyone
# - a solid background colour per account
# - the generic dotfiles (shell, btop, croc, linearmouse), linked only where the account has
#   no file of its own yet. o's ssh config and ssh host names stay o's
{
  config,
  lib,
  pkgs,
  ...
}: let
  primaryUser = config.my.username;

  # - background -------------------------------------------------------------------------

  # o's is set by modules/darwin.nix (Stone)
  backgrounds = {
    ci = "Teal";
  };
  defaultBackground = "Space Gray";

  backgroundCases = lib.concatStrings (lib.mapAttrsToList (user: colour: ''
      ${lib.escapeShellArg user}) colour=${lib.escapeShellArg colour} ;;
    '')
    backgrounds);

  # - macos preferences ------------------------------------------------------------------

  # every command in nix-darwin's script runs as o through this prefix. drop it so they run
  # as whoever logs in, and point o's paths (dock folders, ByHost prefs) at their home
  oDefaults = config.system.activationScripts.userDefaults.text;
  oPrefix = ''launchctl asuser "$(id -u -- ${primaryUser})" sudo --user=${primaryUser} -- '';
  userDefaults = pkgs.writeText "user-defaults.sh" (builtins.replaceStrings
    [oPrefix "~${primaryUser}/" "/Users/${primaryUser}/" "killall -qu ${primaryUser} Dock"]
    ["" "@HOME@/" "@HOME@/" "killall Dock"]
    oDefaults);

  # - dotfiles ---------------------------------------------------------------------------

  dotfiles = "${config.environment.variables.TUCKR_HOME}/Configs";

  # o's .zshrc only adds o's ssh hosts before sourcing the shared one
  zshrc = pkgs.writeText "zshrc" ''
    source "$HOME/.zshrc_shared"
  '';

  # home path -> source
  links = {
    ".zshenv" = "${dotfiles}/zsh_shared/.zshenv";
    ".zshrc" = "${zshrc}";
    ".zshrc_shared" = "${dotfiles}/zsh_shared/.zshrc_shared";
    ".zshrc_darwin" = "${dotfiles}/zsh_shared/.zshrc_darwin";
    ".zshrc_nixos" = "${dotfiles}/zsh_shared/.zshrc_nixos";
    ".p10k.zsh" = "${dotfiles}/zsh_shared/.p10k.zsh";
    ".config/btop/btop.conf" = "${dotfiles}/btop/.config/btop/btop.conf";
    ".config/croc/receive.json" = "${dotfiles}/croc/.config/croc/receive.json";
    ".config/linearmouse/linearmouse.json" = "${dotfiles}/linearmouse_#oskar/.config/linearmouse/linearmouse.json";
  };

  linkCommands = lib.concatStrings (lib.mapAttrsToList (path: source: ''
      link ${lib.escapeShellArg path} ${lib.escapeShellArg source}
    '')
    links);

  # - login script -----------------------------------------------------------------------

  applySettings = pkgs.writeShellScript "m4-mini-user-settings" ''
    set -euo pipefail

    # o gets all of this from nix-darwin itself
    [ "$(id -un)" = ${lib.escapeShellArg primaryUser} ] && exit 0

    exec >>"$HOME/Library/Logs/m4-mini-user-settings.log" 2>&1
    echo "--- $(date)"

    # macos preferences
    sed "s|@HOME@|$HOME|g" ${userDefaults} | ${pkgs.bash}/bin/bash

    # dotfiles
    link() {
      local target="$HOME/$1"
      if [ -e "$target" ] || [ -L "$target" ]; then return; fi
      mkdir -p "$(dirname "$target")"
      ln -s "$2" "$target"
    }
    ${linkCommands}

    # background, last: the first time macos asks whether this may control System Events,
    # and waits until someone answers
    colour=${lib.escapeShellArg defaultBackground}
    case "$(id -un)" in
      ${backgroundCases}
    esac
    /usr/bin/osascript -e "tell application \"System Events\" to tell every desktop to set picture to \"/System/Library/Desktop Pictures/Solid Colors/$colour.png\" as POSIX file" || true
  '';
in {
  assertions = [
    {
      assertion = lib.hasInfix oPrefix oDefaults;
      message = "all-users.nix: nix-darwin's user defaults script changed format, update oPrefix";
    }
  ];

  # o's dock, through nix-darwin, and through the script above everyone else's
  system.defaults.dock = {
    persistent-apps = [
      "/System/Applications/Apps.app"
      "/System/Applications/System Settings.app"
      "/Applications/Helium.app"
      "/Applications/iTerm.app"
      "/Applications/Xcode.app"
      "/Applications/Docker.app"
    ];
    # modules/darwin.nix auto-hides the dock everywhere, a pain over remote desktop
    autohide = lib.mkForce false;
  };

  # command (not ProgramArguments) makes nix-darwin wait for /nix/store, which may not be
  # mounted yet right after boot, when ci auto-logs in
  launchd.agents.m4-mini-user-settings.command = "${applySettings}";
  launchd.agents.m4-mini-user-settings.serviceConfig = {
    LimitLoadToSessionType = "Aqua";
    RunAtLoad = true;
  };
}
