{
  inputs,
  pkgs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
  pkgs-hyprland = inputs.hyprland.inputs.nixpkgs.legacyPackages.${system};
in {
  imports = [inputs.noctalia-greeter.nixosModules.default];

  programs.noctalia-greeter = {
    enable = true;
    settings.session.default = "Hyprland (uwsm-managed)";
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    package = inputs.hyprland.packages.${system}.hyprland;
    portalPackage = inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland;
  };

  hardware.graphics = {
    enable = true;
    package = pkgs-hyprland.mesa;
  };
  hardware.bluetooth.enable = true;

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  security.polkit.enable = true;
  environment.sessionVariables = {
    TERMINAL = "alacritty";
    HYPRCURSOR_THEME = "Bibata-Modern-Classic";
    HYPRCURSOR_SIZE = "24";
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";

    # Hardware GPU first, then EVDI devices.
    AQ_DRM_DEVICES = "/dev/dri/card1:/dev/dri/card2:/dev/dri/card0:/dev/dri/card3";
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
    EVDI_LATENCY = "1";
  };

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
