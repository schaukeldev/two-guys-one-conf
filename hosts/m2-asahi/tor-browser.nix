{ pkgs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      tor-browser-nightly = prev.tor-browser.overrideAttrs (
        finalAttrs: previousAttrs: {
          pname = "tor-browser-nightly";
          version = "2026.08.31";

          src = prev.fetchurl {
            url =
              "https://nightlies.tbb.torproject.org/nightly-builds/tor-browser-builds/"
              + "tbb-nightly.${finalAttrs.version}/nightly-linux-aarch64/"
              + "tor-browser-linux-aarch64-tbb-nightly.${finalAttrs.version}.tar.xz";

            hash = "sha256-1JQLanqyw57RKDJpbf3brfMMnOIBfuV+vWiO5KmV0VU=";
          };

          meta = previousAttrs.meta // {
            platforms = [ "aarch64-linux" ];
          };

          buildPhase =
            builtins.replaceStrings
              [ "TorBrowser/Data/Tor/torrc-defaults" ]
              [ "TorBrowser/Tor/torrc-defaults" ]
              previousAttrs.buildPhase;
        }
      );
    })
  ];

  environment.systemPackages = [
    pkgs.tor-browser-nightly
  ];
}
