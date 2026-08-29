{
  inputs,
  pkgs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
  pkgs-hyprland = inputs.hyprland.inputs.nixpkgs.legacyPackages.${system};
in {
  services.displayManager.gdm.enable = true;

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${system}.hyprland;
    portalPackage = inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland;
  };

  hardware.graphics = {
    enable = true;
    package = pkgs-hyprland.mesa;
  };

  security.polkit.enable = true;

  environment.systemPackages = with pkgs; [
    alacritty
    bibata-cursors
    brightnessctl
    hyprcursor
    hyprpolkitagent
    inputs.noctalia.packages.${system}.default
    mesa
  ];
}
