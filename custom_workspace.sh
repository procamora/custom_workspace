#!/bin/bash

set -ex

trap 'exit 130' INT #Exit if trap Ctrl+C

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color


MY_PATH=$(pwd)
MY_USER=$USER
OS_NAME=$(cat /etc/os-release | grep NAME | cut -d \" -f2 | cut -d " " -f1 | head -n1)
OS_ID=$(cat /etc/os-release | grep VERSION_ID | cut -d= -f2 | tr -d \")

echo $MY_PATH
echo $MY_USER

#####################################################
################### basic utils #####################
#####################################################

setup_utils() {
    echo -e "${GREEN}Installing basic utilities${NC}"

    INSTALL="unzip wget git gcc make cmake vim"

    dnf --version > /dev/null 2>&1 && sudo sudo dnf install -y $INSTALL @development-tools >> dnf.log
    pacman --version > /dev/null 2>&1 && sudo pacman -Sy $INSTALL
    apt --version > /dev/null 2>&1 && sudo apt update >> apt.log && sudo apt install -y $INSTALL >> apt.log
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

setup_bspwm() {
    echo -e "${GREEN}Installing bspwm, sxhkd, compton and feh${NC}"

    INSTALL="bspwm compton feh konsole rofi"

    dnf --version > /dev/null 2>&1 && sudo sudo dnf install -y $INSTALL libXinerama libXinerama-devel libxcb xcb-util \
     xcb-util-devel xcb-util-keysyms-devel xcb-util-wm-devel alsa-lib-devel dmenu rxvt-unicode terminus-fonts \
     xcb-util-wm xcb-util-keysyms >> dnf.log
    pacman --version > /dev/null 2>&1 && sudo pacman -Sy $INSTALL libxcb xcb-util xcb-util-wm xcb-util-keysyms
    apt --version > /dev/null 2>&1 && sudo apt install -y $INSTALL libxcb-xinerama0-dev libxcb-icccm4-dev \
     libxcb-randr0-dev libxcb-util0-dev libxcb-ewmh-dev libxcb-keysyms1-dev libxcb-shape0-dev >> apt.log


    mkdir -p ~/.config/{bspwm/{scripts,},sxhkd,compton}
    cp $MY_PATH/bspwm/bspwmrc ~/.config/bspwm/
    cp $MY_PATH/sxhkd/sxhkdrc ~/.config/sxhkd/
    chmod u+x ~/.config/bspwm/bspwmrc

    echo "sxhkd &
    exec bspwm" >> ~/.xinitrc 

    cp $MY_PATH/bspwm/scripts/resize ~/.config/bspwm/scripts/
    chmod u+x  ~/.config/bspwm/scripts/resize

    # set transparent
    cp $MY_PATH/compton/compton.conf ~/.config/compton/

    # set wallpaper
    wget -O ~/.config/wallpaper.png https://procamora.github.io/images/wallpaper.png

    echo -e "${GREEN}Finishing Installing bspwm, sxhkd, compton and feh${NC}"
}



#####################################################
###################### fonts ########################
#####################################################
# https://github.com/ryanoasis/nerd-fonts/

setup_fonts() {
    echo -e "${GREEN}Installing Hack Nerd Font${NC}"

    MY_FONT="Hack Nerd Font"

    # Set custom fonts
    sudo mkdir -p /usr/local/share/fonts
    sudo cp resources/Hack.zip /usr/local/share/fonts/
    sudo unzip -o /usr/local/share/fonts/Hack.zip -d /usr/local/share/fonts/
    sudo rm /usr/local/share/fonts/Hack.zip

    test -f /etc/vconsole.conf && sudo sed -i.back -re "s/FONT=\".*\"/FONT=\"$MY_FONT\"/g" /etc/vconsole.conf
    ! test -f /etc/vconsole.conf && sudo cp resources/vconsole.conf /etc/

    echo -e "${GREEN}Finishing Installing Hack Nerd Font${NC}"
}



#####################################################
#################### polybar ########################
#####################################################
# https://github.com/polybar/polybar
# https://github.com/polybar/polybar-scripts/tree/master/polybar-scripts

polybar_debian(){
    sudo cp resources/polybar-3.4.2.tar /opt/
    sudo tar xvf /opt/polybar-3.4.2.tar -C /opt/ 
    sudo rm /opt/polybar-3.4.2.tar
    mkdir -p /opt/polybar/build
    cd /opt/polybar/build
    cmake ..
    make -j$(nproc)
    sudo make install
    cd -
}


setup_polybar() { 
    echo -e "${GREEN}Installing polybar${NC}"

    dnf --version > /dev/null 2>&1 && sudo dnf install -y gcc-c++ clang git cmake @development-tools python3-sphinx \
     cairo-devel xcb-util-devel libxcb-devel xcb-proto xcb-util-image-devel xcb-util-wm-devel polybar >> dnf.log

    # FIXME FALTA POR PONER LAS LIBRERIAS PARA PACMAN
    #pacman --version > /dev/null 2>&1 && sudo 

    apt --version > /dev/null 2>&1 && sudo apt install -y cmake cmake-data libcairo2-dev libxcb1-dev libxcb-ewmh-dev \
     libxcb-icccm4-dev libxcb-image0-dev libxcb-randr0-dev libxcb-util0-dev libxcb-xkb-dev pkg-config python-xcbgen \
     xcb-proto libxcb-xrm-dev i3-wm libasound2-dev libmpdclient-dev libiw-dev libcurl4-openssl-dev libpulse-dev \
     build-essential libxcb-composite0 libxcb-shape0-dev libxcb-xfixes0-dev libxcb-composite0-dev xcb >> apt.log \
     && polybar_debian


    mkdir -p ~/.config/polybar/bin

    cp $MY_PATH/polybar/launch.sh ~/.config/polybar/
    chmod u+x ~/.config/polybar/launch.sh

    cp $MY_PATH/polybar/config ~/.config/polybar/

    cp $MY_PATH/polybar/bin/status_ethernet.sh ~/.config/polybar/bin/
    chmod u+x ~/.config/polybar/bin/status_ethernet.sh

    cp $MY_PATH/polybar/bin/status_htb.sh ~/.config/polybar/bin/
    chmod u+x ~/.config/polybar/bin/status_htb.sh

    echo -e "${GREEN}Finishing Installing polybar${NC}"
}

    #####################################################
    #################### i3-lock ########################
    #####################################################

setup_i3lock() {
    echo -e "${GREEN}Finish Installing i3lock${NC}"
    dnf --version > /dev/null 2>&1 && sudo sudo dnf install -y ImageMagick i3lock >> dnf.log
    pacman --version > /dev/null 2>&1 && sudo pacman -Sy ImageMagick i3lock
    apt --version > /dev/null 2>&1 && sudo apt install -y imagemagick i3lock >> apt.log

    test -d /opt/i3lock-fancy/ && sudo rm -rf /opt/i3lock-fancy/
    sudo git clone https://github.com/meskarune/i3lock-fancy.git /opt/i3lock-fancy/
    cd /opt/i3lock-fancy
    sudo make install

    cd $MY_PATH
    echo -e "${GREEN}Finishing Installing i3lock${NC}"
}



#####################################################
######################## vim ########################
#####################################################

setup_vim() {
    echo -e "${GREEN}Installing vim${NC}"
    #USERS="root $MY_USER"
    # Clonamos repositorio
    test -d /opt/vim_runtime && sudo rm -rf /opt/vim_runtime
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

zsh_fedora() {
    INSTALL=$1
    LIST_REPOS="zsh-autosuggestions zsh-completions zsh-history-substring-search zsh-syntax-highlighting antigen"
    repositories=( $LIST_REPOS )

    for r in "${repositories[@]}"; do
        sudo dnf config-manager --add-repo https://download.opensuse.org/repositories/shells:zsh-users:$r/Fedora_$OS_ID/shells:zsh-users:$r.repo
    done

    sudo sudo dnf install -y $INSTALL lsd bat >> dnf.log
}


zsh_debian() {
    INSTALL=$1
    LIST_REPOS="zsh-autosuggestions zsh-completions zsh-history-substring-search zsh-syntax-highlighting antigen"
    repositories=( $LIST_REPOS )

    for r in "${repositories[@]}"; do
        REPO="deb http://download.opensuse.org/repositories/shells:/zsh-users:/$r/Debian_$OS_ID/ /"
        sudo sh -c "echo \"$REPO\" > /etc/apt/sources.list.d/shells:zsh-users:$r.list"
        wget -nv https://download.opensuse.org/repositories/shells:zsh-users:$r/Debian_$OS_ID/Release.key -O Release.key
        sudo apt-key add - < Release.key
        rm Release.key
    done

    sudo apt update >> apt.log && sudo apt install -y $LIST_REPOS $INSTALL >> apt.log
    sudo dpkg -i $MY_PATH/resources/lsd_0.16.0_amd64.deb
    sudo dpkg -i $MY_PATH/resources/bat_0.13.0_amd64.deb
}


zsh_ubuntu() {
    INSTALL=$1
    LIST_REPOS="zsh-autosuggestions zsh-completions zsh-history-substring-search zsh-syntax-highlighting antigen"
    repositories=( $LIST_REPOS )

    for r in "${repositories[@]}"; do
        REPO="deb http://download.opensuse.org/repositories/shells:/zsh-users:/$r/xUbuntu_$OS_ID/ /"
        sudo sh -c "echo \"$REPO\" > /etc/apt/sources.list.d/shells:zsh-users:$r.list"
        wget -nv https://download.opensuse.org/repositories/shells:zsh-users:$r/xUbuntu_$OS_ID/Release.key -O Release.key
        sudo apt-key add - < Release.key
        rm Release.key
    done

    sudo apt update >> apt.log && sudo apt install -y $LIST_REPOS $INSTALL >> apt.log
    sudo dpkg -i $MY_PATH/resources/lsd_0.16.0_amd64.deb
    sudo dpkg -i $MY_PATH/resources/bat_0.13.0_amd64.deb
}


setup_zsh() {
    echo -e "${GREEN}Installing zsh${NC}"
    INSTALL="scrub ripgrep fzf"


    test $OS_NAME = "Ubuntu" && zsh_ubuntu $INSTALL
    test $OS_NAME = "Debian" && zsh_debian $INSTALL

    dnf --version > /dev/null 2>&1 && zsh_fedora
    zypper --version > /dev/null 2>&1 && sudo zypper install -y $INSTALL lsd bat
    pacman --version > /dev/null 2>&1 && sudo pacman -Sy $INSTALL lsd bat

    unzip -o resources/bat-extras-20200401.zip -d resources/
    sudo mv resources/bat-extras/bin/batgrep /usr/local/bin/
    sudo mv resources/bat-extras/bin/prettybat /usr/local/bin/
    rm -rf resources/bat-extras

    #[ -f ~/.fzf.sh ] && source ~/.fzf.sh
    #test -f ~/.fzf.sh && source ~/.fzf.sh

    # If exsits remove back files and dir
    test -f ~/.zshrc && rm -r ~/.zshrc
    test -f ~/.p10k.zsh && rm -f ~/.p10k.zsh
    test -d ~/.oh-my-zsh && rm -rf ~/.oh-my-zsh

    # Download and configuration oh my zsh
    sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    sudo chsh -s $(which zsh) $MY_USER
    sudo chsh -s $(which zsh) root

    # Download theme oh my zsh
    ZSH_CUSTOM=$HOME/.oh-my-zsh/custom/themes
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
    cp $MY_PATH/zsh/zshrc ~/.zshrc
    cp $MY_PATH/zsh/p10k.zsh ~/.p10k.zsh

    # Create link to user root (insegure but comfortable)
    sudo ln -s -f /home/procamora/.zshrc /root/.zshrc

    sudo chmod 755 /usr/share/zsh-* -R
    #sudo chown $MY_USER:root /usr/share/zsh-autosuggestions/ -R
    echo -e "${GREEN}Finishing Installing zsh${NC}"
}



main() {
    test -f dnf.log && rm -r dnf.log
    test -f apt.log && rm -f apt.log

    test $1 = "bspwm" && setup_utils && setup_bspwm && setup_fonts && setup_polybar && setup_i3lock
    test $1 = "vim" && setup_utils && setup_vim
    test $1 = "zsh" && setup_utils && setup_fonts && setup_zsh
    test $1 = "all" && setup_utils && setup_bspwm && setup_fonts && setup_polybar && setup_i3lock && setup_vim && setup_zsh
    test $1 = "" && setup_utils && setup_bspwm && setup_fonts && setup_polybar && setup_i3lock && setup_vim && setup_zsh

    # BUSCAR DOLPHIN O CUALQUIER OTRO EXPLORADOR DE FICHEROS

    echo -e "${GREEN}Finishing Installing custom_workspace${NC}"
    echo -e "${GREEN}Set the Hack Nerd Font font on your console${NC}"
    
    #kill -9 -1
}


main "$@"

