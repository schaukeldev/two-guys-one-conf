{...}: {
  nixpkgs.hostPlatform = "aarch64-darwin";

  system.defaults.dock.persistent-apps = [
    "/System/Applications/Messages.app"
    "/Applications/Spark Desktop.app"
    "/System/Applications/Photos.app"
    "/System/Applications/Notes.app"
    "/System/Applications/FaceTime.app"
    "/System/Applications/Reminders.app"
    "/System/Applications/Home.app"
    "/System/Applications/System Settings.app"
    "/Applications/Brave Browser.app"
    "/Applications/Visual Studio Code.app"
    "/Applications/iTerm.app"
    "/Applications/Hoppscotch.app"
    "/Applications/Obsidian.app"
    "/Applications/WhatsApp.app"
    "/Applications/Telegram Desktop.app"
    "/Applications/Spotify.app"
    "/Applications/Xcode.app"
    "/Applications/UTM.app"
    "/Applications/BambuStudio.app"
  ];
}
