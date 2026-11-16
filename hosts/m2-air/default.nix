{config, ...}: {
  nixpkgs.hostPlatform = "aarch64-darwin";

  system.defaults.dock.persistent-apps = [
    "/System/Applications/Messages.app"
    "/Applications/Spark Desktop.app"
    "/System/Applications/Photos.app"
    "/System/Applications/System Settings.app"
    "/Applications/Brave Browser.app"
    "/Applications/Visual Studio Code.app"
    "/Applications/iTerm.app"
    "/Applications/Obsidian.app"
    "/Users/${config.my.username}/Applications/Brave Browser Apps.localized/WhatsApp Web.app"
    "/Applications/Telegram Desktop.app"
    "/Applications/Spotify.app"
    "/Applications/Xcode.app"
    "/Applications/BambuStudio.app"
  ];
}
