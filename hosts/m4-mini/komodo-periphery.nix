# komodo periphery agent, connects outbound to komodo core. self-contained so it can be
# removed by deleting this file and its import in default.nix.
#
# first connect: create an onboarding key in core (server settings), then on this box
#   mkdir -p ~/.config/komodo && pbpaste > ~/.config/komodo/onboarding.key
#   launchctl kickstart -k gui/$(id -u)/org.nixos.komodo-periphery
# once the server exists in core, the key file can be deleted. docker desktop has to be
# running for container management.
{
  config,
  lib,
  pkgs,
  ...
}: let
  userHome = "/Users/${config.my.username}";
  logDir = "${userHome}/Library/Logs";
  rootDir = "${userHome}/komodo";
  dockerData = "${userHome}/container/data";
  onboardingKeyFile = "${userHome}/.config/komodo/onboarding.key";

  # official release binary instead of nixpkgs, whose komodo lags behind and makes core show
  # a version mismatch. keep this in sync with the core version on lserver
  peripheryVersion = "2.3.4";
  # flat fetch so the hash is the sha256 github lists for the release asset
  peripherySrc = pkgs.fetchurl {
    url = "https://github.com/moghtech/komodo/releases/download/v${peripheryVersion}/periphery-apple";
    sha256 = "20f66f9ac8302878f44843068ce3e32f60ea40fa8430b80a24d3e7c4b9b69a90";
  };
  periphery = pkgs.runCommand "komodo-periphery-${peripheryVersion}" {} ''
    install -Dm755 ${peripherySrc} $out/bin/periphery
  '';

  peripheryConfig = (pkgs.formats.toml {}).generate "periphery.config.toml" {
    root_directory = rootDir;
    core_address = "https://komodo.zuhause.einkacken.net";
    connect_as = "m4-mini";
    default_terminal_command = "zsh";
  };

  # the onboarding key is a secret, so it's only read from a local file when present
  peripheryWithKey = pkgs.writeShellScript "komodo-periphery" ''
    set -euo pipefail

    mkdir -p "${rootDir}" "${dockerData}"
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
  # runs as the user (not root) so it can reach docker desktop's per-user socket
  launchd.user.agents.komodo-periphery.serviceConfig = {
    ProgramArguments = ["${peripheryWithKey}"];
    EnvironmentVariables = {
      PATH = servicePath;
      # docker desktop's per-user socket, /var/run/docker.sock isn't linked on this box
      DOCKER_HOST = "unix://${userHome}/.docker/run/docker.sock";
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
