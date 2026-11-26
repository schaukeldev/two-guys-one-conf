# ci account: standard (non-admin) user that auto-logs in and runs the gitlab runner and
# docker desktop. docker is shared with the docker-access group through a socket relay, so
# o (and komodo periphery) can use it while everyone else can't.
#
# manual steps after the first switch:
# - sudo passwd ci, then system settings > users & groups: auto-login as ci
# - sudo /Applications/Docker.app/Contents/MacOS/install --user=ci
# - log in as ci once: start docker desktop, keep "start when you sign in" on
# - in o's session: quit docker desktop and turn off its "start when you sign in"
# - sudo -iu ci gitlab-runner register --executor shell
{
  config,
  lib,
  pkgs,
  ...
}: let
  ciUser = "ci";
  ciHome = "/Users/${ciUser}";

  dockerGroup = "docker-access";
  sharedDockerDir = "/Users/Shared/docker";

  # launchd agents don't get the login shell PATH, so ci jobs would miss nix/brew tools
  servicePath = lib.concatStringsSep ":" [
    "${config.homebrew.prefix}/bin"
    "${config.homebrew.prefix}/sbin"
    "/etc/profiles/per-user/${ciUser}/bin"
    "/run/current-system/sw/bin"
    "/nix/var/nix/profiles/default/bin"
    "/usr/local/bin"
    "/usr/bin"
    "/bin"
    "/usr/sbin"
    "/sbin"
  ];

  # system agents load in every gui session. these only do something in ci's: elsewhere they
  # exit 0 right away, and KeepAlive.SuccessfulExit = false stops launchd restarting them.
  # logs go to the user's own Library/Logs, since another user can't open ci's
  ciOnlyAgent = name: command: {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.writeShellScript name ''
          set -euo pipefail
          [ "$(id -un)" = "${ciUser}" ] || exit 0

          exec >>"$HOME/Library/Logs/${name}.log" 2>&1
          cd "$HOME"
          exec ${command}
        ''}"
      ];
      EnvironmentVariables.PATH = servicePath;
      LimitLoadToSessionType = "Aqua";
      RunAtLoad = true;
      KeepAlive.SuccessfulExit = false;
      ProcessType = "Interactive";
    };
  };
in {
  # - account ----------------------------------------------------------------------------

  users.knownUsers = [ciUser];
  users.users.${ciUser} = {
    uid = 502;
    gid = 20; # staff
    description = "CI";
    home = ciHome;
    createHome = true;
    shell = pkgs.zsh;
    # nix-darwin hides new users by default, and hidden ones may not be offered for auto-login
    isHidden = false;
  };

  users.knownGroups = [dockerGroup];
  users.groups.${dockerGroup} = {
    gid = 600;
    description = "Access to ci's Docker";
    members = [ciUser config.my.username];
  };

  # - folders and permissions ------------------------------------------------------------

  system.activationScripts.postActivation.text = lib.mkAfter ''
    # docker relay socket lives here, only the docker-access group can reach it
    mkdir -p ${sharedDockerDir}
    chown ${ciUser}:${dockerGroup} ${sharedDockerDir}
    chmod 770 ${sharedDockerDir}

    # other accounts are in staff too, so keep o's home private
    chmod 700 /Users/${config.my.username}

    # xcode ui tests and debugging without an admin prompt, for ci
    DevToolsSecurity -enable > /dev/null
    dseditgroup -o edit -a ${ciUser} -t user _developer
  '';

  # - services ---------------------------------------------------------------------------

  # runs in ci's gui session (not nix-darwin's services.gitlab-runner daemon) because ios
  # builds need it for code signing keychains and simulators
  launchd.agents.ci-gitlab-runner = ciOnlyAgent "ci-gitlab-runner" (lib.escapeShellArgs [
    "${pkgs.gitlab-runner}/bin/gitlab-runner"
    "run"
    "--working-directory"
    ciHome
    "--config"
    "${ciHome}/.gitlab-runner/config.toml"
  ]);

  # relays docker desktop's per-user socket to one the docker-access group can use
  launchd.agents.ci-docker-relay = ciOnlyAgent "ci-docker-relay" (lib.escapeShellArgs [
    "${pkgs.socat}/bin/socat"
    "UNIX-LISTEN:${sharedDockerDir}/docker.sock,fork,unlink-early,mode=660,group=${dockerGroup}"
    "UNIX-CONNECT:${ciHome}/.docker/run/docker.sock"
  ]);
}
