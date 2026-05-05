{ config, pkgs, ... }:

{
  services.restic.backups.server-to-qnap = {
    initialize = true;

    repository = "sftp:qnap-restic:/share/mini7"; #had to create /root/.ssh/config ssh config for this
    passwordFile = "/etc/restic-password"; #something will happen here someday

    paths = [
      "/etc/nixos"
      "/home"
      "/srv"
      "/var/lib"
    ];

    exclude = [
      "/tmp"
      "/var/tmp"
      "/var/cache"
      "/var/log"
      "/var/lib/docker/overlay2"
      "/var/lib/containers/storage/overlay"
    ];


    timerConfig = {
      OnCalendar = "03:00";
      Persistent = true;
    };

    pruneOpts = [
      "--keep-daily 14"
      "--keep-weekly 8"
      "--keep-monthly 6"
    ];
  };

}