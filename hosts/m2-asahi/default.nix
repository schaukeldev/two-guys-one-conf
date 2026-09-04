{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  asahiPkgs = config.hardware.asahi.pkgs;
  fairydustVersion = "7.1.12";
  fairydustKernel = asahiPkgs.buildLinux {
    inherit lib;
    inherit (asahiPkgs) stdenv;
    pname = "linux-asahi-fairydust";
    version = fairydustVersion;
    modDirVersion = fairydustVersion;
    extraMeta.branch = "7.1";
    src = asahiPkgs.fetchFromGitHub {
      owner = "AsahiLinux";
      repo = "linux";
      rev = "b8810ad6442699f610984f3eceea2e3234a50b77";
      hash = "sha256-FTns+uaqYbCYSsH0y7ypTHUzZs3GAM08vRwHGy2Tozc=";
    };
    kernelPatches = [
      {
        name = "Asahi config";
        patch = null;
        structuredExtraConfig = with lib.kernel; {
          ARM64_16K_PAGES = yes;
          ARM64_MEMORY_MODEL_CONTROL = yes;
          ARM64_ACTLR_STATE = yes;
          APPLE_WATCHDOG = yes;
          APPLE_M1_CPU_PMU = yes;
          HID_APPLE = module;
          APPLE_PMGR_MISC = yes;
          APPLE_PMGR_PWRSTATE = yes;
        };
        features.rust = true;
      }
    ] ++ config.boot.kernelPatches;
  };
in {
  imports = [
    ./desktop.nix
    ./displaylink.nix
    ./hardware-configuration.nix
    ./keyboard.nix
    ./tor-browser.nix
    ./zen-browser.nix
    inputs.apple-silicon.nixosModules.apple-silicon-support
  ];

  boot.loader.systemd-boot.enable = lib.mkForce true;
  boot.loader.systemd-boot.configurationLimit = 7;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.kernelParams = ["appledrm.show_notch=1"];
  # Asahi's fairydust branch provides experimental USB-C DisplayPort support.
  boot.kernelPackages = lib.mkForce (asahiPkgs.linuxPackagesFor fairydustKernel);
  boot.kernelModules = ["typec_displayport"];
  hardware.asahi.enable = true;
  networking.firewall.enable = lib.mkForce true;
  networking.networkmanager.wifi.backend = "iwd";

  services.mullvad-vpn.enable = true;
  services.gnome.gnome-keyring.enable = true;
  programs.firefox.enable = true;
 
  nix.settings.cores = 8;
  
  my.username = "paul";
  networking.hostName = "m2-asahi";

  environment.systemPackages = with pkgs; [
    asahi-audio
    # doesnt build anymore :(
    # bambu-studio
    git
    mullvad-vpn
    opencode
    python3
    go-task
    ungoogled-chromium
    telegram-desktop
    texlive.combined.scheme-medium
    texlivePackages.latexmk
    vesktop
    vscode
    wget
  ];

  system.stateVersion = "26.11";
}
