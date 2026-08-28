{lib, ...}: {
  nixpkgs.overlays = [
    (final: prev: {
      tuckr = final.rustPlatform.buildRustPackage rec {
        pname = "tuckr";
        version = "0.13.0";

        src = final.fetchFromGitHub {
          owner = "RaphGL";
          repo = "Tuckr";
          rev = "1dc29419a6475d616a5c3075057498686bb3019c";
          hash = "sha256-sWpjCoLFwuNiDN3ZxI1Ec3WqOWU/Nbly8XvZCzYc+8g=";
        };

        cargoHash = "sha256-NXIrjX73lg7706VAJqr/xv7N46ZdscAtXwzJywuAwro=";

        doCheck = false;

        meta = with lib; {
          description = "Super powered replacement for GNU Stow";
          homepage = "https://github.com/RaphGL/Tuckr";
          changelog = "https://github.com/RaphGL/Tuckr/releases/tag/${version}";
          license = licenses.gpl3Plus;
          maintainers = with maintainers; [mimame];
          mainProgram = "tuckr";
        };
      };
    })
  ];
}
