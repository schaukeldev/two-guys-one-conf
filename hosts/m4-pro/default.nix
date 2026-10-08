{...}: {
  nixpkgs.hostPlatform = "aarch64-darwin";

  my.username = "A200266873";

  networking = {
    hostName = "LMDT0024f8a63";
    computerName = "LMDT0024f8a63";
    localHostName = "LMDT0024f8a63";
  };

  my.homebrew.masApps = {
    MicrosoftExcel = 462058435;
    MicrosoftOneNote = 784801555;
    MicrosoftOutlook = 985367838;
    MicrosoftPowerPoint = 462062816;
    MicrosoftWord = 462054704;
    OneDrive = 823766827;
    UniversalPrint = 6450432292;
  };

  system.defaults.CustomUserPreferences."NSGlobalDomain" = {
    NSColorSimulateHardwareAccent = null;
    NSColorSimulatedHardwareEnclosureNumber = null;
    AppleAccentColor = 6;
  };

  system.defaults.dock.persistent-apps = [
    "/Applications/Spark Desktop.app"
    "/Applications/Microsoft Teams.app"
    "/Applications/Microsoft Outlook.app"
    "/Applications/Visual Studio Code.app"
    "/Applications/iTerm.app"
    "/Applications/Obsidian.app"
    "/Applications/Telegram Desktop.app"
    "/Applications/Spotify.app"
    "/Applications/BambuStudio.app"
    "/Applications/Zen.app"
  ];
}
