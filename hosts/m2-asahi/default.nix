{
  inputs,
  lib,
  pkgs,
  ...
}: {
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
  hardware.asahi.enable = true;
  networking.firewall.enable = lib.mkForce true;
  networking.networkmanager.wifi.backend = "iwd";

  services.mullvad-vpn.enable = true;
  services.gnome.gnome-keyring.enable = true;
  programs.firefox.enable = true;
 

  nix.settings.cores = 4;
  
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
