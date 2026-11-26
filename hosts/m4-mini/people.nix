# personal accounts besides o: standard (non-admin) users with their own private home, remote
# desktop (screen sharing / novnc), ssh and xcode debugging. no docker access (that's the
# docker-access group in ci.nix). their look comes from all-users.nix, except the background
# colour, which is set here.
#
# manual steps after adding someone: sudo passwd <name>
{
  lib,
  pkgs,
  ...
}: let
  people = {
    paul = {
      uid = 503;
      description = "Paul";
      background = "Blue Violet";
      sshKeys = import ../../guys/paul/ssh-keys.nix;
    };
    rayan = {
      uid = 504;
      description = "Rayan";
      background = "Cyan";
      sshKeys = [];
    };
    stephan = {
      uid = 505;
      description = "Stephan";
      background = "Dusty Rose";
      sshKeys = [];
    };
  };

  # macos' remote access groups only hold admins otherwise
  accessGroups = [
    "com.apple.access_screensharing"
    "com.apple.access_ssh"
    "_developer"
  ];
in {
  users.knownUsers = lib.attrNames people;

  my.backgrounds = lib.mapAttrs (_: person: person.background) people;

  users.users =
    lib.mapAttrs (name: person: {
      inherit (person) uid description;
      gid = 20; # staff
      home = "/Users/${name}";
      createHome = true;
      shell = pkgs.zsh;
      # nix-darwin hides new users by default, these should show at the login window
      isHidden = false;
      openssh.authorizedKeys.keys = person.sshKeys;
    })
    people;

  system.activationScripts.postActivation.text = lib.mkAfter (lib.concatStrings (lib.mapAttrsToList (name: _:
    ''
      # ${name}: private home (everyone is in staff), remote access, xcode debugging
      chmod 700 /Users/${name}
    ''
    + lib.concatMapStrings (group: ''
      dseditgroup -o edit -a ${name} -t user ${group}
    '')
    accessGroups)
  people));
}
