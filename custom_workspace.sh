#!/bin/bash

#set -ex

#trap 'exit 130' INT #Exit if trap Ctrl+C
trap ctrl_c INT


RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

function ctrl_c(){
    echo -e "\n${RED}Exiting...${NC}"
    exit 0
}

export DEBIAN_FRONTEND=noninteractive

MY_PATH=$(pwd)
MY_USER=$USER
OS_NAME=$(cat /etc/os-release | grep NAME | cut -d \" -f2 | cut -d " " -f1 | head -n1)
OS_ID=$(cat /etc/os-release | grep VERSION_ID | cut -d= -f2 | tr -d \")


#####################################################
################### basic utils #####################
#####################################################

function setup_utils() {
    INSTALL="unzip wget git gcc make cmake vim"
    echo -e "${GREEN}Installing basic utilities $INSTALL ${NC}"

    dnf --version > /dev/null 2>&1 && sudo sudo dnf install -y $INSTALL @development-tools >> dnf.log 2>&1
    pacman --version > /dev/null 2>&1 && sudo pacman -Sy $INSTALL 2>&1
    apt --version > /dev/null 2>&1 && sudo apt update >> apt.log && sudo apt install -y $INSTALL >> apt.log 2>&1
    echo -e "${GREEN}Finishing Installing  basic utilities${NC}"
}



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

function setup_bspwm() {
    INSTALL="bspwm sxhkd compton feh konsole rofi ksysguard dolphin dolphin-plugins numlockx"
    echo -e "${GREEN}Installing $INSTALL ${NC}"

    dnf --version > /dev/null 2>&1 && sudo sudo dnf install -y $INSTALL libXinerama libXinerama-devel libxcb xcb-util \
     xcb-util-devel xcb-util-keysyms-devel xcb-util-wm-devel alsa-lib-devel dmenu rxvt-unicode terminus-fonts \
     xcb-util-wm xcb-util-keysyms >> dnf.log 2>&1
    pacman --version > /dev/null 2>&1 && sudo pacman -Sy $INSTALL libxcb xcb-util xcb-util-wm xcb-util-keysyms >> pacman.log 2>&1
    apt --version > /dev/null 2>&1 && sudo apt install -y $INSTALL libxcb-xinerama0-dev libxcb-icccm4-dev \
     libxcb-randr0-dev libxcb-util0-dev libxcb-ewmh-dev libxcb-keysyms1-dev libxcb-shape0-dev >> apt.log 2>&1


    mkdir -p ~/.config/{bspwm/{scripts,},sxhkd,compton}
    cp -r $MY_PATH/bspwm/* ~/.config/bspwm/
    cp -r $MY_PATH/sxhkd/* ~/.config/sxhkd/
    chmod u+x ~/.config/bspwm/bspwmrc

    echo "sxhkd &
exec bspwm" > ~/.xinitrc

    cp $MY_PATH/bspwm/scripts/resize ~/.config/bspwm/scripts/
    chmod u+x  ~/.config/bspwm/scripts/resize

    # set transparent
    cp $MY_PATH/compton/compton.conf ~/.config/compton/

    # set wallpaper
    #wget -O ~/.config/wallpaper.png https://procamora.github.io/images/wallpaper.png > wget.log
    cp $MY_PATH/resources/wallpaper.png ~/.config/wallpaper.png
    cp $MY_PATH/resources/lock.png ~/.config/lock.png

    echo -e "${GREEN}Finishing Installing bspwm, sxhkd, compton and feh${NC}"
}



#####################################################
###################### fonts ########################
#####################################################
# https://github.com/ryanoasis/nerd-fonts/

function setup_fonts() {
    echo -e "${GREEN}Installing Hack Nerd Font${NC}"

    MY_FONT="Hack Nerd Font"

    # Set custom fonts
    sudo mkdir -p /usr/local/share/fonts
    sudo cp resources/Hack.zip /usr/local/share/fonts/
    sudo unzip -o /usr/local/share/fonts/Hack.zip -d /usr/local/share/fonts/
    sudo /bin/rm /usr/local/share/fonts/Hack.zip

    test -f /etc/vconsole.conf && sudo sed -i.back -re "s/FONT=\".*\"/FONT=\"$MY_FONT\"/g" /etc/vconsole.conf
    ! test -f /etc/vconsole.conf && sudo cp resources/vconsole.conf /etc/

    echo -e "${GREEN}Finishing Installing Hack Nerd Font${NC}"
}



#####################################################
#################### polybar ########################
#####################################################
# https://github.com/polybar/polybar
# https://github.com/polybar/polybar-scripts/tree/master/polybar-scripts

function polybar_debian(){
    sudo cp resources/polybar-3.4.2.tar /opt/
    sudo tar xvf /opt/polybar-3.4.2.tar -C /opt/
    sudo /bin/rm /opt/polybar-3.4.2.tar
    mkdir -p /opt/polybar/build
    cd /opt/polybar/build
    cmake ..
    make -j$(nproc)
    sudo make install
    cd $Y_PATH
}


function setup_polybar() {
    echo -e "${GREEN}Installing polybar and dependencies${NC}"

    dnf --version > /dev/null 2>&1 && sudo dnf install -y gcc-c++ clang git cmake @development-tools python3-sphinx \
     cairo-devel xcb-util-devel libxcb-devel xcb-proto xcb-util-image-devel xcb-util-wm-devel polybar >> dnf.log 2>&1

    # FIXME FALTA POR PONER LAS LIBRERIAS PARA PACMAN
    #pacman --version > /dev/null 2>&1 && sudo

    apt --version > /dev/null 2>&1 && sudo apt install -y cmake cmake-data libcairo2-dev libxcb1-dev libxcb-ewmh-dev \
     libxcb-icccm4-dev libxcb-image0-dev libxcb-randr0-dev libxcb-util0-dev libxcb-xkb-dev pkg-config python-xcbgen \
     xcb-proto libxcb-xrm-dev i3-wm libasound2-dev libmpdclient-dev libiw-dev libcurl4-openssl-dev libpulse-dev \
     build-essential libxcb-composite0 libxcb-shape0-dev libxcb-xfixes0-dev libxcb-composite0-dev xcb >> apt.log 2>&1 \
     && polybar_debian


    mkdir -p ~/.config/polybar/bin

    cp $MY_PATH/polybar/launch.sh ~/.config/polybar/
    chmod u+x ~/.config/polybar/launch.sh

    cp $MY_PATH/polybar/config ~/.config/polybar/

    cp $MY_PATH/polybar/bin/* ~/.config/polybar/bin/
    chmod u+x ~/.config/polybar/bin/*.sh

    # plugins
    git clone https://github.com/polybar/polybar-scripts.git ~/.config/polybar/bin/scripts/

    # manage NetworkMaganer
    test -d ~/.config/polybar/bin/networkmanager-dmenu/ && /bin/rm -rf ~/.config/polybar/bin/networkmanager-dmenu/
    git clone https://github.com/firecat53/networkmanager-dmenu.git ~/.config/polybar/bin/networkmanager-dmenu/

    echo -e "${GREEN}Finishing Installing polybar${NC}"
}

#####################################################
#################### i3-lock ########################
#####################################################

function setup_i3lock() {
    echo -e "${GREEN}Finish Installing i3lock and ImageMagick ${NC}"
    dnf --version > /dev/null 2>&1 && sudo sudo dnf install -y ImageMagick i3lock xautolock >> dnf.log 2>&1
    pacman --version > /dev/null 2>&1 && sudo pacman -Sy ImageMagick i3lock xautolock >> pacman.log 2>&1
    apt --version > /dev/null 2>&1 && sudo apt install -y imagemagick i3lock xautolock >> apt.log 2>&1

    # TODO delete i3lock-fancy by use i3lock alone
    test -d /opt/i3lock-fancy/ && sudo /bin/rm -rf /opt/i3lock-fancy/
    sudo git clone https://github.com/meskarune/i3lock-fancy.git /opt/i3lock-fancy/
    cd /opt/i3lock-fancy
    sudo make install

    cd $MY_PATH
    echo -e "${GREEN}Finishing Installing i3lock${NC}"
}



#####################################################
######################## vim ########################
#####################################################

function setup_vim() {
    echo -e "${GREEN}Installing vim and plugins ${NC}"
    #USERS="root $MY_USER"
    # Clonamos repositorio
    test -d /opt/vim_runtime && sudo /bin/rm -rf /opt/vim_runtime
    sudo git clone --depth=1 https://github.com/amix/vimrc.git /opt/vim_runtime

    # Dar permiso a los ficheros para los usuarios no root
    sudo chmod 755 /opt/vim_runtime/ -R

    # to install for all users with home directories
    #sudo bash /opt/vim_runtime/install_awesome_parameterized.sh /opt/vim_runtime $USERS
    sudo bash /opt/vim_runtime/install_awesome_parameterized.sh /opt/vim_runtime --all

    test -f $MY_USER/.vimrc && sudo chown $MY_USER:$MY_USER $MY_USER/.vimrc -R
    echo -e "${GREEN}Finishing Installing vim${NC}"
}



#####################################################
######################## zsh ########################
#####################################################

# https://github.com/ohmyzsh/ohmyzsh/blob/master/tools/install.sh
# https://github.com/romkatv/powerlevel10k#oh-my-zsh

function zsh_fedora() {
    INSTALL=$1
    #LIST_REPOS="zsh-autosuggestions zsh-completions zsh-history-substring-search zsh-syntax-highlighting antigen"
    #repositories=( $LIST_REPOS )

    #for r in "${repositories[@]}"; do
    #    sudo dnf config-manager --add-repo https://download.opensuse.org/repositories/shells:zsh-users:$r/Fedora_$OS_ID/shells:zsh-users:$r.repo
    #done
    sudo sudo dnf install -y $INSTALL lsd bat >> dnf.log
}


function zsh_debian() {
    INSTALL=$1
    #LIST_REPOS="zsh-autosuggestions zsh-completions zsh-history-substring-search zsh-syntax-highlighting antigen"
    #repositories=( $LIST_REPOS )

    #for r in "${repositories[@]}"; do
    #    REPO="deb http://download.opensuse.org/repositories/shells:/zsh-users:/$r/Debian_$OS_ID/ /"
    #    sudo sh -c "echo \"$REPO\" > /etc/apt/sources.list.d/shells:zsh-users:$r.list"
    #    wget -nv https://download.opensuse.org/repositories/shells:zsh-users:$r/Debian_$OS_ID/Release.key -O Release.key
    #    sudo apt-key add - < Release.key
    #    /bin/rm Release.key
    #done
    sudo apt install -y $INSTALL >> apt.log
    sudo dpkg -i $MY_PATH/resources/lsd_0.16.0_amd64.deb
    sudo dpkg -i $MY_PATH/resources/bat_0.13.0_amd64.deb
}


function zsh_raspbian() {
    INSTALL=$1
    sudo apt install -y $INSTALL >> apt.log
    sudo cp $MY_PATH/resources/lsd-0.17.0-arm /usr/local/bin/lsd
    sudo cp $MY_PATH/resources/bat-0.13.0-arm /usr/local/bin/bat
}


function zsh_ubuntu() {
    INSTALL=$1
    sudo apt install -y $INSTALL >> apt.log
    sudo dpkg -i $MY_PATH/resources/lsd_0.16.0_amd64.deb
    sudo dpkg -i $MY_PATH/resources/bat_0.13.0_amd64.deb
}


function setup_zsh() {
    INSTALL="zsh scrub ripgrep fzf"
    echo -e "${GREEN}Installing zsh $INSTALL lsd bat${NC}"

    test $OS_NAME = "Ubuntu" && zsh_ubuntu "$INSTALL"
    test $OS_NAME = "Debian" && zsh_debian "$INSTALL"
    test $OS_NAME = "Raspbian" && zsh_raspbian "$INSTALL"
    dnf --version > /dev/null 2>&1 && zsh_fedora "$INSTALL"

    zypper --version > /dev/null 2>&1 && sudo zypper install -y $INSTALL lsd bat
    pacman --version > /dev/null 2>&1 && sudo pacman -Sy $INSTALL lsd bat

    unzip -o resources/bat-extras-20200401.zip -d resources/
    sudo mv resources/bat-extras/bin/batgrep /usr/local/bin/
    sudo mv resources/bat-extras/bin/prettybat /usr/local/bin/
    /bin/rm -rf resources/bat-extras

    #[ -f ~/.fzf.sh ] && source ~/.fzf.sh
    test -f ~/.fzf.sh && source ~/.fzf.sh

    # If exsits remove back files and dir
    test -f ~/.zshrc && /bin/rm -r ~/.zshrc
    test -f ~/.p10k.zsh && /bin/rm -f ~/.p10k.zsh
    test -d ~/.oh-my-zsh && /bin/rm -rf ~/.oh-my-zsh

    # Download and configuration oh my zsh
    sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    sudo chsh -s $(which zsh) $MY_USER
    sudo chsh -s $(which zsh) root

    # Download theme oh my zsh
    ZSH_CUSTOM=$HOME/.oh-my-zsh/custom/themes
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
    cp $MY_PATH/zsh/zshrc ~/.zshrc
    cp $MY_PATH/zsh/p10k.zsh ~/.p10k.zsh

    # plugins zsh
    git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-completions.git $ZSH_CUSTOM/plugins/zsh-completions
    git clone https://github.com/zsh-users/zsh-history-substring-search.git $ZSH_CUSTOM/plugins/zsh-history-substring-search
    git clone https://github.com/zsh-users/zsh-docker.git $ZSH_CUSTOM/plugins/zsh-docker

    # Create link to user root (insegure but comfortable)
    sudo ln -s -f ~/.zshrc /root/.zshrc
    sudo ln -s -f ~/.p10k.zsh /root/.p10k.zsh
    sudo ln -s ~/.oh-my-zsh/ /root/

    echo -e "${GREEN}Finishing Installing zsh${NC}"
}



function setup_konsole() {
    # set default profile konsole
    mkdir -p ~/.local/share/konsole/
    mkdir -p ~/.config/
    cp konsole/zsh.profile ~/.local/share/konsole/
    cp konsole/config_konsolerc ~/.config/konsolerc
}


function setup_tmux() {
    INSTALL="tmux"
    echo -e "${GREEN}Installing terminal $INSTALL ${NC}"

    dnf --version > /dev/null 2>&1 && sudo sudo dnf install -y $INSTALL >> dnf.log 2>&1
    pacman --version > /dev/null 2>&1 && sudo pacman -Sy $INSTALL 2>&1
    apt --version > /dev/null 2>&1 && sudo apt install -y $INSTALL >> apt.log 2>&1

    test -d ~/.tmux && /bin/rm -rf ~/.tmux
    test -f ~/.tmux.conf && /bin/rm -f ~/.tmux.conf
    test -L ~/.tmux.conf && unlink ~/.tmux.conf
    test -f ~/.tmux.conf.local && /bin/rm -f ~/.tmux.conf.local

    git clone https://github.com/gpakosz/.tmux.git ~/.tmux
    ln -s -f ~/.tmux/.tmux.conf ~/.tmux.conf
    cp ~/.tmux/.tmux.conf.local ~/.tmux.conf.local
    echo -e "${GREEN}Finishing Installing $INSTALL ${NC}"
}


function main() {
    test -f dnf.log && /bin/rm -r dnf.log
    test -f apt.log && /bin/rm -f apt.log

    test "$1" = "bspwm" && setup_utils && setup_bspwm && setup_fonts && setup_polybar && setup_i3lock
    test "$1" = "vim" && setup_utils && setup_vim
    test "$1" = "zsh" && setup_utils && setup_fonts && setup_zsh && setup_konsole && setup_tmux
    test "$1" = "all" && setup_utils && setup_bspwm && setup_fonts && setup_polybar && setup_i3lock && setup_vim && setup_zsh && setup_konsole && setup_tmux
    test "$1" = "" && setup_utils && setup_bspwm && setup_fonts && setup_polybar && setup_i3lock && setup_vim && setup_zsh && setup_konsole && setup_tmux


    test "$1" = "_utils" && setup_utils
    test "$1" = "_bspwm" && setup_bspwm
    test "$1" = "_fonts" && setup_fonts
    test "$1" = "_polybar" && setup_polybar
    test "$1" = "_i3lock" && setup_i3lock
    test "$1" = "_vim" && setup_vim
    test "$1" = "_zsh" && setup_zsh
    test "$1" = "_konsole" && setup_konsole
    test "$1" = "_tmux" && setup_tmux


    # BUSCAR DOLPHIN O CUALQUIER OTRO EXPLORADOR DE FICHEROS

    echo -e "${GREEN}Finishing Installing custom_workspace${NC}"
    echo -e "${GREEN}Set the Hack Nerd Font font on your console${NC}"

    #kill -9 -1
}


main "$@"

