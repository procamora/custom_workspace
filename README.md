# custom_workspace

custom_workspace is a script to install and configure a complete workspace in a fully automated way. The utilities to be installed and configured are the following:

- [bspwm][bspwm]: It is a mosaic type window manager that works with shortcuts and that will be put as a desktop environment.
- [sxhkd][sxhkd]: This is a shortcuts manager that we will use to control bspwm.
- [compton][compton]: This is the transparency manager that we will use to put transparencies to the windows.
- [dunst][dunst]: notification daemon
- [feh][feh]: This is a lightweight, configurable and versatile image viewer that allows us to set up wallpapers.
- [rofi][rofi]: it is a program launcher in the form of an interactive list.
- [Hack Nerd Font][nerd]: These are the fonts we're going to use for the zsh Powerlevel10k theme.
- [polybar][polybar]: It's a highly configurable taskbar builder.
- [i3-lock][i3lock]: It's a simple screen locker.
- vim: Is the default text editor, it will put an advanced configuration with a series of plugins using the [amix][vimrc] configuration.
- zsh: It will put this shell by default, using the configuration of [_Oh My Zsh_][ohmyzsh] and the theme [Powerlevel10k][powerlevel10k].



[bspwm]: https://github.com/baskerville/bspwm
[sxhkd]: https://github.com/baskerville/sxhkd
[compton]: https://github.com/chjj/compton
[dunst]: https://github.com/dunst-project/dunst/wiki/Installation
[feh]: https://github.com/derf/feh
[rofi]: https://github.com/davatorium/rofi
[nerd]: https://github.com/ryanoasis/nerd-fonts
[polybar]: https://github.com/polybar/polybar
[i3lock]: https://github.com/i3/i3lock
[vimrc]: https://github.com/amix/vimrc
[ohmyzsh]: https://github.com/ohmyzsh/ohmyzsh
[powerlevel10k]: https://github.com/romkatv/powerlevel10k


![workspace][screnshot]

[screnshot]: workspace.png



## Getting Started


### Requirements

Execute the script with a user with permissions to execute the sudo command and execute the script from __bash__ to avoid problems when installing or reinstalling zsh



#### Recommendation:

- Execute the script from a console other than konsole, so that the profile with the specific configuration of konsole can be applied correctly.

- If it is done from konsole, later it can be executed from another console so that the profile is applied in the following way:

- It is important to run the script with the user who is going to use the system. The script executes the commands with sudo when
 necessary so you should not execute the script with sudo.

```bash
./custom_workspace.sh _konsole
```

### Basic Installation


To install the workspace it is necessary to download the project and run the script, which takes care of downloading and configuring all the tools:



```bash
git clone https://github.com/procamora/custom_workspace.git
cd custom_workspace/
chmod u+x custom_workspace.sh
./custom_workspace.sh all > output.log
```





Running the script again regenerates the default settings. You can also leave some parts as default:



```bash
./custom_workspace.sh all       # all packages
./custom_workspace.sh bspwm     # bspqm + polybar + i3lock
./custom_workspace.sh vim       # vim
./custom_workspace.sh zsh       # zsh
./custom_workspace.sh _polybar  # polybar
```



![help][help]

[help]: help.png



## Compatibility

This script has been tested on the following Operating Systems

### Tested Operating Systems

- [x] Fedora (31)
- [x] Ubuntu (19.04)
- [x] Debian (10)
- [x] Raspbian 10

### Pending Operating Systems

- [ ] Arch
- [ ] OpenSUSE
- [ ] Kali





## Program requirements

- Dolphin
- Konsole
- ksysguard
- [bat][bat]: alias to cat
- [lsd][lsd]: alias to ls




[bat]: https://github.com/sharkdp/bat/releases
[lsd]: https://github.com/Peltoche/lsd/releases




## Customization


The configuration files and/or directories of the different programs are as follows:

- bspwm: _~/.config/bspwm/_
- sxhkd: _~/.config/sxhkd/_
- compton: _~/.config/compton/_
- polybar: _~/.config/polybar/_
- i3-lock: __
- vim: _/opt/vim_runtime/_
- zsh: _~/.zshrc_ y _~/.p10k.zsh_



### Shortcut

In case we don't know the name of the key we want to assign a shortcut to with sxhkd, we can use the xev utility to get the name of that key, we can see below an example for the _PrtScn_ key:

```bash
sudo dnf install -y XBindKeys

# url: https://unix.stackexchange.com/questions/120199/how-to-detect-global-key-presses
xev | /bin/grep -A2 --line-buffered '^KeyRelease' \
    | sed -n '/keycode /s/^.*keycode \([0-9]*\).* (.*, \(.*\)).*$/\1 \2/p'
```


Getting the next output:


```
107 Print
```


So now we only need to indicate the shortcut in sxhkd so that when we press the _PrtScn_ key we will have the desired screenshot utility:

```
Print
    spectacle
```




### Backgroud

Replace image 

```bash
~/.config/wallpaper.png
```




## Debug mode



We can activate the uncommented debeg mode the third line (_set -ex_) of the script custom_workspace.sh or executing it with the command bash -x

```bash
bash -x  custom_workspace.sh
```



The output of the package download commands is redirected to a log file, we can see them with the command:


```bash
tail -f dnf.log
tail -f apt.log
```





The basic configuration used has been taken from the s4vitar video: [Cómo configurar un buen entorno de trabajo en Linux][s4vitar].


[s4vitar]: https://www.youtube.com/watch?v=MF4qRSedmEs

