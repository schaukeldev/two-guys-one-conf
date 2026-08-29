{
  config,
  inputs,
  ...
}: {
  home-manager.users.${config.my.username} = {
    imports = [inputs.zen-browser.homeModules.beta];
    home.file."${config.users.users.${config.my.username}.home}/.config/zen/profiles.ini".force = true;

    programs.zen-browser = {
      enable = true;
      policies.ExtensionSettings = {
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          installation_mode = "force_installed";
        };
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
      };

      profiles.default = {
        name = "Default Profile";
        path = "ijjbl3fy.Default Profile";
        search = {
          force = true;
          engines.kleinanzeigen = {
            name = "Kleinanzeigen";
            urls = [
              {template = "https://www.kleinanzeigen.de/s-{searchTerms}/k0";}
            ];
            definedAliases = ["!kl"];
          };
        };
      };
    };
  };
}
