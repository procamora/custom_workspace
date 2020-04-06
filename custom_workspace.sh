#!/bin/bash

set -ex

trap 'exit 130' INT #Exit if trap Ctrl+C

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color


MY_PATH=$(pwd)
MY_USER=$USER

echo $MY_PATH
echo $MY_USER

#####################################################
################### basic utils #####################
#####################################################

echo -e "${GREEN}Installing basic utilities${NC}"

INSTALL="unzip wget git gcc make cmake vim"

dnf --version > /dev/null 2>&1 && sudo sudo dnf install -y $INSTALL @development-tools
pacman --version > /dev/null 2>&1 && sudo sudo pacman -S -y $INSTALL
apt --version > /dev/null 2>&1 && sudo apt update && sudo apt install -y $INSTALL



#####################################################
###################### bspwm ########################
#####################################################
# https://github.com/baskerville/bspwm/wiki
# https://github.com/chjj/compton

# bspwm -> Entorno de escritorio
# sxhkd -> Gestor de shortcut
# compton -> gestion de transparencias
# feh -> configurar fondo de pantalla
# rofi -> lanzador de programas en forma de lista interactica

echo -e "${GREEN}Installing bspwm, sxhkd, compton and feh${NC}"


INSTALL="bspwm compton feh konsole rofi"

dnf --version > /dev/null 2>&1 && sudo sudo dnf install -y $INSTALL libXinerama libXinerama-devel libxcb xcb-util \
 xcb-util-devel xcb-util-keysyms-devel xcb-util-wm-devel alsa-lib-devel dmenu rxvt-unicode terminus-fonts \
 xcb-util-wm xcb-util-keysyms
pacman --version > /dev/null 2>&1 && sudo sudo pacman -y $INSTALL libxcb xcb-util xcb-util-wm xcb-util-keysyms
apt --version > /dev/null 2>&1 && sudo apt install -y $INSTALL libxcb-xinerama0-dev libxcb-icccm4-dev \
 libxcb-randr0-dev libxcb-util0-dev libxcb-ewmh-dev libxcb-keysyms1-dev libxcb-shape0-dev


#git clone https://github.com/baskerville/bspwm.git
#git clone https://github.com/baskerville/sxhkd.git
#cd bspwm && make && sudo make install
#cd ../sxhkd && make && sudo make install


# FIXME ESTA PARTE HAY QUE MODIFICARLA poniendo mis ficheros de configuracion
mkdir -p ~/.config/{bspwm/{scripts,},sxhkd,compton}
#cp /usr/local/share/doc/bspwm/examples/bspwmrc ~/.config/bspwm/
cp $MY_PATH/bspwm/bspwmrc ~/.config/bspwm/
#cp /usr/local/share/doc/bspwm/examples/sxhkdrc ~/.config/sxhkd/
cp $MY_PATH/sxhkd/sxhkdrc ~/.config/sxhkd/
chmod u+x ~/.config/bspwm/bspwmrc


echo "sxhkd &
exec bspwm" >> ~/.xinitrc 


#echo '#!/bin/sh
#
#if bspc query -N -n focused.floating > /dev/null; then
#    step=20
#else
#    step=100
#fi
#
#case "$1" in
#    west) dir=right; falldir=left; x="-$step"; y=0;;
#    east) dir=right; falldir=left; x="$step"; y=0;;
#    north) dir=top; falldir=bottom; x=0; y="-$step";;
#    south) dir=top; falldir=bottom; x=0; y="$step";;
#esac
#
#bspc node -z "$dir" "$x" "$y" || bspc node -z "$falldir" "$x" "$y"' > ~/.config/bspwm/scripts/resize

cp $MY_PATH/bspwm/scripts/resize ~/.config/bspwm/scripts/

chmod u+x  ~/.config/bspwm/scripts/resize


# \x27 == '
#echo -e '''active-opacity = 0.95;
#inactive-opacity = 0.80;
#frame-opacity = 0.80;
#
#backend="glx";      # Comentar si hay problemas de rendimiento
#
#opacity-rule = [
#    "50:class_g = \x27Bspwm\x27 && class_i = \x27presel_feedback\x27",
#    "80:class_g = \x27Rofi\x27",
#    "80:class_g = \x27Caja\x27",
#    "80:class_g = \x27Google-chrome\x27",
#    "80:class_g = \x27Firefox\x27",
#]
#
#blur-background = true; # Comentar si hay problemas de rendimiento
#''' > ~/.config/compton/compton.conf 

cp $MY_PATH/compton/compton.conf ~/.config/compton/


wget -O ~/.config/wallpaper.png https://procamora.github.io/images/wallpaper.png

#cd ~



#####################################################
###################### fonts ########################
#####################################################
# https://github.com/ryanoasis/nerd-fonts/

echo -e "${GREEN}Installing Hack Nerd Font${NC}"

# Set custom fonts
sudo mkdir -p /usr/local/share/fonts
#sudo wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Hack.zip -O /usr/local/share/fonts/Hack.zip
sudo cp resources/Hack.zip /usr/local/share/fonts/
sudo unzip /usr/local/share/fonts/Hack.zip -d /usr/local/share/fonts/
sudo rm /usr/local/share/fonts/Hack.zip


MY_FONT="Hack Nerd Font"

# TODO check that it works correctly
# if exists modifiy, else create file
ls /etc/vconsole.conf > /dev/null 2>&1 && sudo sed -i.back -re "s/FONT=\".*\"/FONT=\"$MY_FONT\"/g" /etc/vconsole.conf

! ls /etc/vconsole.conf > /dev/null 2>&1 && sudo echo -e 'KEYMAP="us"
FONT="Hack Nerd Font"' > /etc/vconsole.conf



#####################################################
#################### polybar ########################
#####################################################
# https://github.com/polybar/polybar

echo -e "${GREEN}Installing polybar${NC}"


polybar_debian(){
    #sudo wget -O /opt/polybar-3.4.2.tar https://github.com/polybar/polybar/releases/download/3.4.2/polybar-3.4.2.tar
    sudo cp resources/polybar-3.4.2.tar /opt/
    sudo tar xvf /opt/polybar-3.4.2.tar -C /opt/ 
    sudo rm /opt/polybar-3.4.2.tar
    mkdir /opt/polybar/build
    cd /opt/polybar/build
    cmake ..
    make -j$(nproc)
    sudo make install
    cd -
}


dnf --version > /dev/null 2>&1 && sudo dnf install -y gcc-c++ clang git cmake @development-tools python3-sphinx \
 cairo-devel xcb-util-devel libxcb-devel xcb-proto xcb-util-image-devel xcb-util-wm-devel polybar

# FIXME FALTA POR PONER LAS LIBRERIAS PARA PACMAN
#pacman --version > /dev/null 2>&1 && sudo 

apt --version > /dev/null 2>&1 && sudo apt install -y cmake cmake-data libcairo2-dev libxcb1-dev libxcb-ewmh-dev \
 libxcb-icccm4-dev libxcb-image0-dev libxcb-randr0-dev libxcb-util0-dev libxcb-xkb-dev pkg-config python-xcbgen \
 xcb-proto libxcb-xrm-dev i3-wm libasound2-dev libmpdclient-dev libiw-dev libcurl4-openssl-dev libpulse-dev \
 build-essential libxcb-composite0 libxcb-shape0-dev libxcb-xfixes0-dev libxcb-composite0-dev xcb && polybar_debian


##
## FIXME COMPROBAR EL PAQUETE POLYBAR EN UBUNTU
##


#sudo wget -O /opt/polybar-3.4.2.tar https://github.com/polybar/polybar/releases/download/3.4.2/polybar-3.4.2.tar
#cd /opt/ && sudo tar xvf polybar-3.4.2.tar && cd polybar
#mkdir build
#cd build
#cmake ..
#make -j$(nproc)
#sudo make install



mkdir -p ~/.config/polybar/bin


#echo '#!/bin/sh
#killall -1 polybar
#
#while pgrep -u $UID -x polybar > /dev/null; do sleep 1; done
#
#polybar example &
#' > ~/.config/polybar/launch.sh

cp $MY_PATH/polybar/launch.sh ~/.config/polybar/

chmod u+x ~/.config/polybar/launch.sh



# FIXME CAMBIAR POR MI FICHERO LOCAL YA QUE NO COMPILO EL CODIGO
cp $MY_PATH/polybar/config ~/.config/polybar/
#sudo cp /opt/polybar/config ~/.config/polybar/

# FIXME PONER USUARIO GENERICO
#sudo chown $MY_USER:$MY_USER ~/.config/polybar/config


#echo -e '#!/bin/sh
#
#IFACE=$(/usr/sbin/ip address | grep "enp0s3:" | awk \x27{print $2}\x27 | tr -d ":")
#
#if [ "$IFACE" = "enp0s3" ]; then
#    echo "%{F#2495e7} %{F#e2ee6a}$(/usr/sbin/ip address show enp0s3 | grep "inet " | awk \x27{print $2}\x27 | cut -d/ -f1)%{u-}"
#
#else
#    echo "%{F#2495e7}%{u-}%{F-}"
#fi
#' > ~/.config/polybar/bin/status_ethernet.sh

cp $MY_PATH/polybar/bin/status_ethernet.sh ~/.config/polybar/bin/

chmod u+x ~/.config/polybar/bin/status_ethernet.sh



#echo -e '#!/bin/sh
#
#IFACE=$(/usr/sbin/ip address | grep "tun0:" | awk \x27{print $2}\x27 | tr -d ":")
#
#if [ "$IFACE" = "tun0" ]; then
#    echo "%{F#1bbf3e} %{F#e2ee6a}$(/usr/sbin/ip address show tun0 | grep "inet " | awk \x27{print $2}\x27 | cut -d/ -f1)%{u-}"
#
#else
#    echo "%{F#1bbf3e}%{u-}%{F-}"
#fi
#' > ~/.config/polybar/bin/status_htb.sh

cp $MY_PATH/polybar/bin/status_htb.sh ~/.config/polybar/bin/

chmod u+x ~/.config/polybar/bin/status_htb.sh



#####################################################
#################### i3-lock ########################
#####################################################

dnf --version > /dev/null 2>&1 && sudo sudo dnf install -y ImageMagick i3lock
pacman --version > /dev/null 2>&1 && sudo sudo pacman -y ImageMagick i3lock
apt --version > /dev/null 2>&1 && sudo apt install -y imagemagick i3lock

sudo git clone https://github.com/meskarune/i3lock-fancy.git /opt/i3lock-fancy/
cd /opt/i3lock-fancy
sudo make install

cd $MY_PATH






exit 2







#####################################################
######################## zsh ########################
#####################################################



# Ejecutar con usuario sin privilegios pero que tenga permiso de sudo

INSTALL="scrub lsd bat ripgrep fzf zsh-autosuggestions zsh-autosuggestions docker-zsh-completion zsh-syntax-highlighting.noarch"


os_fedora(){
    sudo dnf config-manager --add-repo https://download.opensuse.org/repositories/shells:zsh-users:zsh-autosuggestions/Fedora_30/shells:zsh-users:zsh-autosuggestions.repo
    sudo sudo dnf install -y $INSTALL
    sudo dnf install -y libxcb xcb-util xcb-util-wm xcb-util-keysyms # bspwm
}


os_debian(){
    sudo echo 'deb http://download.opensuse.org/repositories/shells:/zsh-users:/zsh-autosuggestions/Debian_9.0/ /' > /etc/apt/sources.list.d/shells:zsh-users:zsh-autosuggestions.list
    wget -nv https://download.opensuse.org/repositories/shells:zsh-users:zsh-autosuggestions/Debian_9.0/Release.key -O Release.key
    sudo apt-key add - < Release.key
    sudo apt update && sudo apt install -y $INSTALL
    sudo apt install -y libxcb-xinerama0-dev libxcb-icccm4-dev libxcb-randr0-dev libxcb-util0-dev libxcb-ewmh-dev libxcb-keysyms1-dev libxcb-shape0-dev
}





INSTALL="scrub lsd bat ripgrep fzf zsh-autosuggestions zsh-autosuggestions docker-zsh-completion \
 zsh-syntax-highlighting"

dnf --version > /dev/null 2>&1 && sudo sudo dnf install -y $INSTALL
pacman --version > /dev/null 2>&1 && sudo sudo pacman -y $INSTALL
apt --version > /dev/null 2>&1 && sudo apt update && sudo apt install -y $INSTALL



git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k

WHOAMI=$(whoami) # my user non root
sudo chsh -s $(which zsh) $WHOAMI
sudo chsh -s $(which zsh) root


git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc




y y y 3 1 2 1 2 2 1 2 
2 many icons
2 fluent
n
1 off


.zshrc
~/.p10k.zsh



sudo ln -s -f /home/procamora/.zshrc /root/.zshrc










wget https://github.com/eth-p/bat-extras/releases/download/v20200401/bat-extras-20200401.zip -O bat-extras.zip
unzip bat-extras.zip


sudo mv Users/Ethan/Projects/github.com/bat-extras/bin/batgrep /usr/local/bin/
sudo mv Users/Ethan/Projects/github.com/bat-extras/bin/prettybat /usr/local/bin/
rm -rf bat-extras.zip Users/




chown procamora:root /usr/share/zsh-autosuggestions/ -R
chown procamora:root /usr/share/zsh-syntax-highlighting/ -R





[ -f ~/.fzf.sh ] && source ~/.fzf.sh





#####################################################
######################## vim ########################
#####################################################







