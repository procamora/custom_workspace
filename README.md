# custom_workspace



Ubuntu 19.04
Debian 10
Fedora 31



Requisitos
dolphin
konsole





```bash
git clone https://github.com/procamora/custom_workspace.git


cd custom_workspace/

chmod u+x custom_workspace.sh

./custom_workspace.sh


# Important: when the zsh prompt is exited it is necessary to execute the exit command in order for the script to continue executing
```




https://github.com/polybar/polybar-scripts/tree/master/polybar-scripts


```bash

INSTALL="unzip wget git gcc make cmake vim"

dnf --version > /dev/null 2>&1 && sudo sudo dnf install -y $INSTALL @development-tools
pacman --version > /dev/null 2>&1 && sudo sudo pacman -S -y $INSTALL
apt --version > /dev/null 2>&1 && sudo apt update && sudo apt install -y $INSTALL





INSTALL="bspwm compton feh konsole rofi"

dnf --version > /dev/null 2>&1 && sudo sudo dnf install -y $INSTALL libXinerama libXinerama-devel libxcb xcb-util \
 xcb-util-devel xcb-util-keysyms-devel xcb-util-wm-devel alsa-lib-devel dmenu rxvt-unicode terminus-fonts \
 xcb-util-wm xcb-util-keysyms
pacman --version > /dev/null 2>&1 && sudo sudo pacman -y $INSTALL libxcb xcb-util xcb-util-wm xcb-util-keysyms
apt --version > /dev/null 2>&1 && sudo apt install -y $INSTALL libxcb-xinerama0-dev libxcb-icccm4-dev \
 libxcb-randr0-dev libxcb-util0-dev libxcb-ewmh-dev libxcb-keysyms1-dev libxcb-shape0-dev




dnf --version > /dev/null 2>&1 && sudo dnf install -y gcc-c++ clang git cmake @development-tools python3-sphinx \
 cairo-devel xcb-util-devel libxcb-devel xcb-proto xcb-util-image-devel xcb-util-wm-devel polybar

# FIXME FALTA POR PONER LAS LIBRERIAS PARA PACMAN
#pacman --version > /dev/null 2>&1 && sudo 

apt --version > /dev/null 2>&1 && sudo apt install -y cmake cmake-data libcairo2-dev libxcb1-dev libxcb-ewmh-dev \
 libxcb-icccm4-dev libxcb-image0-dev libxcb-randr0-dev libxcb-util0-dev libxcb-xkb-dev pkg-config python-xcbgen \
 xcb-proto libxcb-xrm-dev i3-wm libasound2-dev libmpdclient-dev libiw-dev libcurl4-openssl-dev libpulse-dev \
 build-essential libxcb-composite0 libxcb-shape0-dev libxcb-xfixes0-dev libxcb-composite0-dev xcb



dnf --version > /dev/null 2>&1 && sudo sudo dnf install -y ImageMagick i3lock
pacman --version > /dev/null 2>&1 && sudo sudo pacman -y ImageMagick i3lock
apt --version > /dev/null 2>&1 && sudo apt install -y imagemagick i3lock

```




Modo debug

descomentar set -ex

tail -f dnf.log
tail -f apt.log