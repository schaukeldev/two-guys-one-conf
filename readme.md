![NIX CONF](./manual-config/cover.png)
shared fentsoft nix config. _why didn't they just get another cup..._ 😔✊

### structure

- `modules/`: config "layers"
- `hosts/`: overrides for specific machines
- `dotfiles/`: used with [tuckr](https://github.com/RaphGL/Tuckr)
- `plist/`: 3rd party app configs that i couldn't figure out a nixy way to configure
- `manual-config/`: 3rd party app configs that i couldn't figure out an automated way to configure
- `guys/`: just some guys in a folder nothing weird

### setup

hosts are the attribute names in `flake.nix` (`m2-air`, `m3-pro`, `m4-mini`, ...).

1. command line tools (for git) and rosetta

   ```sh
   xcode-select --install
   softwareupdate --install-rosetta --agree-to-license
   ```

2. install lix, answer **yes** to enabling flakes, then open a new terminal

   ```sh
   curl -sSf -L https://install.lix.systems/lix | sh -s -- install
   ```

3. clone the config to `/etc/nix-darwin` (the directory must be empty, add `-b <branch>` for a branch)

   ```sh
   sudo mkdir -p /etc/nix-darwin
   sudo chown $(id -nu):$(id -ng) /etc/nix-darwin
   git clone https://github.com/fentsoft/two-guys-one-conf /etc/nix-darwin
   cd /etc/nix-darwin
   ```

4. desktop hosts only: sign in to the app store, xcode and wireguard are installed from there

5. first switch, `darwin-rebuild` isn't installed yet so it runs through `nix run`

   ```sh
   sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .#<host>
   ```

   if it aborts with "Unexpected files in /etc", rename each listed file and rerun, e.g.

   ```sh
   sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin
   ```

6. open a new terminal, link dotfiles and apply plists

   ```sh
   tuckr add --only-files -fy \*
   ./plist/apply.sh
   defaultbrowser finicky # desktop hosts, in case the activation script didn't do it
   ```

after that, rebuild with

```sh
sudo darwin-rebuild switch --flake /etc/nix-darwin#<host>
```

for server hosts, see the manual steps at the top of `guys/server/default.nix`.

### manual steps

- apply exports from `./manual-config`
- hide spotlight icon in menubar in `system settings > menu bar`
- in `system settings > lock screen`
  - turn display off 20 mins, 30 mins
  - require password immediately
  - disable show user name and photo
- turn off optimized charging and display dimming on battery `system settings > battery`

### if the keyboard is fucked

something something `ansi` layout instead of `iso`, `^` and `<` are swapped.
sometimes macos runs the keyboard setup for logitech mouse and then ignores the keychron keyboard.

try removing the keyboard type plist, reboot and run the setup again.

```sh
sudo rm -fr /Library/Preferences/com.apple.keyboardtype.plist
```

or set the correct type `41` instead of `43`, maybe [automate it in the config](https://github.com/pinnacol/macadmin/blob/609c8a21ac7558d896c59b5feaa75f11243ab4d1/scripts/DefineKeyboards/DefineKeyboards.sh) sometime.
