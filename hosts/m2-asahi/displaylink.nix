{
  config,
  pkgs,
  ...
}: {
  boot.extraModulePackages = [config.boot.kernelPackages.evdi];
  boot.initrd.kernelModules = ["evdi"];
  
  environment.systemPackages = [pkgs.displaylink];

  systemd.services.displaylink-server = {
    enable = true;
    requires = ["systemd-udevd.service"];
    after = ["systemd-udevd.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.displaylink}/bin/DisplayLinkManager";
      User = "root";
      Group = "root";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
