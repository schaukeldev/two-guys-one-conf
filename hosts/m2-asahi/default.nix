{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
  pkgs-hyprland = inputs.hyprland.inputs.nixpkgs.legacyPackages.${system};
in
{
  imports = [
    ./hardware-configuration.nix
    ./tor-browser.nix
    inputs.apple-silicon.nixosModules.apple-silicon-support
  ];

  boot.loader.systemd-boot.enable = lib.mkForce true;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.kernelParams = [ "appledrm.show_notch=1" ];

  boot.extraModulePackages = [ config.boot.kernelPackages.evdi ];
  boot.initrd.kernelModules = [ "evdi" ];

  networking.firewall.enable = lib.mkForce true;
  networking.networkmanager.wifi.backend = "iwd";

  services.xserver.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.videoDrivers = [ "displaylink" ];

programs.hyprland = {
  enable = true;
  package = inputs.hyprland.packages.${system}.hyprland;
  portalPackage = inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland;
};
  hardware.graphics = {
    enable = true;
    package = pkgs-hyprland.mesa;
  };

  services.displayManager.gdm.enable = true;
  services.mullvad-vpn.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  programs.firefox.enable = true;

  my.username = "paul";
  networking.hostName = "m2-asahi";
  hardware.asahi.enable = true;

  environment.systemPackages = with pkgs; [
    alacritty
    asahi-audio
    bambu-studio
    bibata-cursors
    brightnessctl
    displaylink
    git
    hyprcursor
    hyprpolkitagent
    inputs.noctalia.packages.${system}.default
    mesa
    mullvad-vpn
    opencode
    python3
    telegram-desktop
    vscode
    wget
  ];

  security.polkit.enable = true;

  hardware.asahi = {
    setupAsahiSound = true;
  };

  systemd.services.displaylink-server = {
    enable = true;
    requires = [ "systemd-udevd.service" ];
    after = [ "systemd-udevd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.displaylink}/bin/DisplayLinkManager";
      User = "root";
      Group = "root";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };


  system.stateVersion = "25.11";
}