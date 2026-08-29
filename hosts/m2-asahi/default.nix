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
    inputs.apple-silicon.nixosModules.apple-silicon-support
  ];

  boot.loader.systemd-boot.enable = lib.mkForce true;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.kernelParams = ["appledrm.show_notch=1"];
  hardware.asahi.enable = true;
  networking.firewall.enable = lib.mkForce true;
  networking.networkmanager.wifi.backend = "iwd";

  services.mullvad-vpn.enable = true;
  services.gnome.gnome-keyring.enable = true;
  programs.firefox.enable = true;

  my.username = "paul";
  networking.hostName = "m2-asahi";

  environment.systemPackages = with pkgs; [
    asahi-audio
    bambu-studio
    git
    mullvad-vpn
    opencode
    python3
    telegram-desktop
    vesktop
    vscode
    wget
  ];

  system.stateVersion = "25.11";
}
