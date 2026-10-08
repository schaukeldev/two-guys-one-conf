{config, ...}: {
  nixpkgs.hostPlatform = "aarch64-darwin";

  my.username = "o";

  networking = {
    hostName = "LMDT001849997";
    computerName = "LMDT001849997";
    localHostName = "LMDT001849997";
  };

  my.homebrew.casks = [
    "lm-studio"
  ];

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
    "/System/Applications/Messages.app"
    "/Applications/Spark Desktop.app"
    "/System/Applications/Photos.app"
    "/System/Applications/Notes.app"
    "/System/Applications/FaceTime.app"
    "/System/Applications/Reminders.app"
    "/System/Applications/Home.app"
    "/System/Applications/System Settings.app"
    "/Applications/Microsoft Teams.app"
    "/Applications/Microsoft Outlook.app"
    "/Applications/Google Chrome.app"
    "/Applications/Brave Browser.app"
    "/Applications/Visual Studio Code.app"
    "/Applications/iTerm.app"
    "/Applications/Bruno.app"
    "/Applications/Obsidian.app"
    "/Users/${config.my.username}/Applications/Brave Browser Apps.localized/WhatsApp Web.app"
    "/Applications/Telegram Desktop.app"
    "/System/Applications/Music.app"
    "/Applications/Xcode.app"
    "/Applications/UTM.app"
    "/Applications/BambuStudio.app"
  ];
}
