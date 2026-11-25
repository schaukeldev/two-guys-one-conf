let
  raid0 = ''
    DEVICE partitions
    ARRAY /dev/md0 metadata=1.2 name=lserver:0 UUID=fdb4cf1b:984be78b:5b545c50:3231a157
    MAILADDR somebody@example.com
  '';
in {
  boot.swraid = {
    enable = true;
    mdadmConf = raid0;
  };

  # mdadm >= 4.5 runs `modprobe md_mod` itself and bails out if that fails. udev's
  # PATH has no modprobe on NixOS, so the module has to be loaded before the disks
  # show up or the array is never assembled.
  boot.initrd.kernelModules = ["md_mod" "raid0"];

  # the mount is nofail, so nothing else makes docker wait for it. without this,
  # containers can bind mount the empty directory underneath.
  systemd.services.docker.after = ["media-raids.mount"];
}
