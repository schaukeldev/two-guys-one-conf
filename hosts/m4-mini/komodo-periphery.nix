# komodo periphery agent, connects outbound to komodo core. self-contained so it can be
# removed by deleting this file and its import in default.nix.
#
# first connect: create an onboarding key in core (server settings), then on this box
#   mkdir -p ~/.config/komodo && pbpaste > ~/.config/komodo/onboarding.key
#   launchctl kickstart -k gui/$(id -u)/org.nixos.komodo-periphery
# once the server exists in core, the key file can be deleted. docker desktop has to be
# running in ci's session for container management (see ci.nix).
#
# periphery runs as o, so its keys stay in o's private home. stacks and their volumes live
# in /Users/Shared/komodo instead, because docker runs as ci and can only mount what ci can
# read. that folder belongs to the docker-access group.
{
  config,
  lib,
  pkgs,
  ...
}: let
  userHome = "/Users/${config.my.username}";
  logDir = "${userHome}/Library/Logs";
  keyDir = "${userHome}/komodo/keys";
  rootDir = "/Users/Shared/komodo";
  dockerData = "${rootDir}/data";
  onboardingKeyFile = "${userHome}/.config/komodo/onboarding.key";

  # nixpkgs' komodo, which can lag behind core, so core may show a version mismatch. that's
  # only a warning. the official periphery-apple release isn't a drop-in alternative: it
  # links homebrew's openssl and reports itself as v0.0.0
  periphery = pkgs.komodo;

  peripheryConfig = (pkgs.formats.toml {}).generate "periphery.config.toml" {
    root_directory = rootDir;
    # both default to ${rootDir}/keys, which ci could read
    private_key = "file:${keyDir}/periphery.key";
    core_public_keys = ["file:${keyDir}/core.pub"];
    core_address = "https://komodo.wein.lol";
    connect_as = "m4-mini";
    default_terminal_command = "zsh";
  };

  # the onboarding key is a secret, so it's only read from a local file when present
  peripheryWithKey = pkgs.writeShellScript "komodo-periphery" ''
    set -euo pipefail

    if [ -s "${onboardingKeyFile}" ]; then
      export PERIPHERY_ONBOARDING_KEY_FILE="${onboardingKeyFile}"
    fi

    exec ${periphery}/bin/periphery --config-path ${peripheryConfig}
  '';

  # periphery runs git, docker and build tools, which aren't on launchd's default PATH
  servicePath = lib.concatStringsSep ":" [
    "${config.homebrew.prefix}/bin"
    "/etc/profiles/per-user/${config.my.username}/bin"
    "/run/current-system/sw/bin"
    "/usr/local/bin"
    "/usr/bin"
    "/bin"
    "/usr/sbin"
    "/sbin"
  ];
in {
  # setgid, so files periphery creates keep the docker-access group and ci's docker can
  # read them
  system.activationScripts.postActivation.text = lib.mkAfter ''
    mkdir -p ${dockerData}
    chown ${config.my.username}:docker-access ${rootDir} ${dockerData}
    chmod 2770 ${rootDir} ${dockerData}
  '';

  launchd.user.agents.komodo-periphery.serviceConfig = {
    ProgramArguments = ["${peripheryWithKey}"];
    EnvironmentVariables = {
      PATH = servicePath;
      # ci's docker desktop, through the relay in ci.nix
      DOCKER_HOST = "unix:///Users/Shared/docker/docker.sock";
      # stacks use $DOCKER_DATA for volume paths, same as on lserver
      DOCKER_DATA = dockerData;
    };
    WorkingDirectory = userHome;
    RunAtLoad = true;
    KeepAlive = true;
    StandardOutPath = "${logDir}/komodo-periphery.out.log";
    StandardErrorPath = "${logDir}/komodo-periphery.err.log";
  };
}
