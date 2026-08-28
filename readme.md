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

```sh
xcode-select --install
softwareupdate --install-rosetta --agree-to-license
```

```sh
curl -sSf -L https://install.lix.systems/lix | sh -s -- install
```

```sh
sudo mkdir -p /etc/nix-darwin
sudo chown -R $(id -nu):$(id -ng) /etc/nix-darwin
cd /etc/nix-darwin

nix flake init -t nix-darwin/master
sudo nix run nix-darwin/master#darwin-rebuild -- switch
```

```sh
sudo darwin-rebuild switch --flake github:fentsoft/two-guys-one-conf#m2-air
```

```sh
sudo rm -fr /etc/nix-darwin/*
sudo git clone https://github.com/fentsoft/two-guys-one-conf /etc/nix-darwin
sudo chown -R $(id -nu):$(id -ng) /etc/nix-darwin
cd /etc/nix-darwin

tuckr add --only-files -fy \*

./plist/apply.sh
defaultbrowser finicky # i have an activation script for this but last time it didn't work
```

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
