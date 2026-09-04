{lib, ...}: {
  services.keyd.enable = true;
  systemd.services.keyd.restartTriggers = [./keyd.conf];
  environment.etc."keyd/default.conf".source = ./keyd.conf;

  # Keep palm rejection working when input comes through keyd's virtual keyboard.
  environment.etc."libinput/local-overrides.quirks".text = ''
    [keyd virtual keyboard]
    MatchUdevType=keyboard
    MatchName=keyd virtual keyboard
    AttrKeyboardIntegration=internal
  '';

  services.xserver.xkb.variant = lib.mkForce "mac";
}
