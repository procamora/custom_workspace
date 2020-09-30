#!/bin/bash
# Author: Pablo Rocamora (aka procamora)

#set -ex


export DEBIAN_FRONTEND=noninteractive

DNF="sudo dnf -yq"
GIT="git -q"
WGET="wget -q"
RM="/bin/rm"

MY_PATH=$(pwd)
MY_USER=$USER
OS_NAME=$(cat /etc/os-release | egrep "^NAME=" | tr -d \" | awk -F = '{print $NF}' | awk -F " " '{print $1}')
OS_ID=$(cat /etc/os-release | grep VERSION_ID | cut -d= -f2 | tr -d \")


#####################################################
################### basic utils #####################
#####################################################

function setup_utils() {
    INSTALL="unzip wget git gcc make cmake vim"
    echo -e "${GREEN}Installing basic utilities $INSTALL ${NC}"

    dnf --version > /dev/null 2>&1 && $DNF install $INSTALL @development-tools
    pacman --version > /dev/null 2>&1 && sudo pacman -Sy $INSTALL 2>&1
    apt --version > /dev/null 2>&1 && sudo apt update && sudo apt install -y $INSTALL
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

function dunst() {
    dnf --version > /dev/null 2>&1 && $DNF install dbus-devel libX11-devel libXrandr-devel glib2-devel pango-devel \
     gtk2-devel libxdg-basedir-devel libXScrnSaver-devel libnotify-devel
    apt --version > /dev/null 2>&1 && sudo apt install -y libdbus-1-dev libx11-dev libxinerama-dev libxrandr-dev libxss-dev \
     libglib2.0-dev libpango1.0-dev libgtk-3-dev libxdg-basedir-dev libnotify-dev

    # clone the repository
    test -d dunst_comp/ && $RM -rf dunst_comp/
    $GIT clone https://github.com/dunst-project/dunst.git dunst_comp/
    cd dunst_comp/
    # compile and install
    make > /dev/null 2>&1
    sudo make install
    #sudo cp -f {dunst,dunstify} /usr/local/bin/
    cd -
    test -d dunst_comp/ && $RM -rf dunst_comp/
    cp -fu $MY_PATH/dunst/dunstrc ~/.config/dunst/dunstrc
}


function setup_bspwm() {
    INSTALL="bspwm sxhkd compton feh konsole rofi ksysguard dolphin dolphin-plugins numlockx plasma-integration"
    echo -e "${GREEN}Installing $INSTALL ${NC}"

    dnf --version > /dev/null 2>&1 && $DNF install $INSTALL libXinerama libXinerama-devel libxcb xcb-util \
     xcb-util-devel xcb-util-keysyms-devel xcb-util-wm-devel alsa-lib-devel dmenu rxvt-unicode terminus-fonts \
     xcb-util-wm xcb-util-keysyms
    pacman --version > /dev/null 2>&1 && sudo pacman -Sy $INSTALL libxcb xcb-util xcb-util-wm xcb-util-keysyms
    apt --version > /dev/null 2>&1 && sudo apt install -y $INSTALL libxcb-xinerama0-dev libxcb-icccm4-dev \
     libxcb-randr0-dev libxcb-util0-dev libxcb-ewmh-dev libxcb-keysyms1-dev libxcb-shape0-dev


    mkdir -p ~/.config/{bspwm/{scripts,},sxhkd,compton,rofi,icons,dunst}
    cp -ru $MY_PATH/bspwm/* ~/.config/bspwm/
    cp -ru $MY_PATH/sxhkd/* ~/.config/sxhkd/
    cp -fu $MY_PATH/rofi/* ~/.config/rofi/
    cp -fu $MY_PATH/icons/* ~/.config/icons/
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

    dunst

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
    sudo unzip -o /usr/local/share/fonts/Hack.zip -d /usr/local/share/fonts/ > /dev/null
    sudo $RM /usr/local/share/fonts/Hack.zip

    # test -f /etc/vconsole.conf && sudo sed -i.back -re "s/FONT=\".*\"/FONT=\"$MY_FONT\"/g" /etc/vconsole.conf
    # ! test -f /etc/vconsole.conf && sudo cp resources/vconsole.conf /etc/

    # basic language and time init calander monday
    echo 'LANG="en_US.UTF-8"
LC_TIME="en_GB.UTF-8"
LC_PAPER="en_GB.UTF-8"
LC_MEASUREMENT="en_GB.UTF-8"' | sudo tee /etc/locale.conf
    echo -e "${GREEN}Finishing Installing Hack Nerd Font${NC}"


    echo -e "${GREEN}Installing papirus theme${NC}"
    $WGET -qO- https://git.io/papirus-icon-theme-install | sh

    locate kwriteconfig5
    if [ "$?" -eq 0 ]; then
        kwriteconfig5 --file kdeglobals --group MainToolbarIcons --key Size "22"
        kwriteconfig5 --file kdeglobals --group ToolbarIcons --key Size "22"

        kwriteconfig5 --file kdeglobals --group Icons --key Theme "Papirus"

        kwriteconfig5 --file "$HOME/.directory" --group "Dolphin" --key "PreviewsShown" "false"
        kwriteconfig5 --file "$HOME/.directory" --group "Dolphin" --key "SortOrder" "1"
        kwriteconfig5 --file "$HOME/.directory" --group "Dolphin" --key "SortRole" "modificationtime"
        kwriteconfig5 --file "$HOME/.directory" --group "Dolphin" --key "Timestamp" "2020,8,27,17,53,2"
        kwriteconfig5 --file "$HOME/.directory" --group "Dolphin" --key "Version" "4"
        kwriteconfig5 --file "$HOME/.directory" --group "Settings" --key "HiddenFilesShown" "true"

        kwriteconfig5 --file "$HOME/Documents/.directory" --group "Desktop Entry" --key "Icon" "folder-documents"
        kwriteconfig5 --file "$HOME/Downloads/.directory" --group "Desktop Entry" --key "Icon" "folder-downloads"
        kwriteconfig5 --file "$HOME/Public/.directory" --group "Desktop Entry" --key "Icon" "folder-public"
        kwriteconfig5 --file "$HOME/Pictures/.directory" --group "Desktop Entry" --key "Icon" "folder-pictures"
        kwriteconfig5 --file "$HOME/Videos/.directory" --group "Desktop Entry" --key "Icon" "folder-videos"
        kwriteconfig5 --file "$HOME/Templates/.directory" --group "Desktop Entry" --key "Icon" "folder-templates"
        kwriteconfig5 --file "$HOME/Music/.directory" --group "Desktop Entry" --key "Icon" "folder-music"
        kwriteconfig5 --file "$HOME/Desktop/.directory" --group "Desktop Entry" --key "Icon" "desktop"
        kwriteconfig5 --file "$HOME/scripts/.directory" --group "Desktop Entry" --key "Icon" "folder-script"
    fi

    #sed -i.back 's/Theme=[[:alpha:]]\+/Theme=Papirus/g' $HOME/.config/kdeglobals
    #sed -i.back 's/Theme=[[:alpha:]]\+/Theme=Papirus/g' $HOME/.kde/share/config/kdeglobals

    #dnf --version > /dev/null 2>&1 && sudo dnf install -y kde-runtime
    #git -q clone https://github.com/jsmitar/dolphin-folder-color /tmp/dolphin-folder-color
    #cd /tmp/dolphin-folder-color
    #bash install.sh
    #cd -
    #rm -rf /tmp/dolphin-folder-color
}



#####################################################
#################### polybar ########################
#####################################################
# https://github.com/polybar/polybar
# https://github.com/polybar/polybar-scripts/tree/master/polybar-scripts

function polybar_debian(){
    sudo cp resources/polybar-3.4.2.tar /opt/
    sudo tar xvf /opt/polybar-3.4.2.tar -C /opt/
    sudo $RM /opt/polybar-3.4.2.tar
    mkdir -p /opt/polybar/build
    cd /opt/polybar/build
    cmake ..
    make -j$(nproc)
    sudo make install
    cd $Y_PATH
}


function setup_polybar() {
    echo -e "${GREEN}Installing polybar and dependencies${NC}"

    dnf --version > /dev/null 2>&1 && $DNF install gcc-c++ clang git cmake @development-tools python3-sphinx \
     cairo-devel xcb-util-devel libxcb-devel xcb-proto xcb-util-image-devel xcb-util-wm-devel polybar

    # FIXME FALTA POR PONER LAS LIBRERIAS PARA PACMAN
    #pacman --version > /dev/null 2>&1 && sudo

    apt --version > /dev/null 2>&1 && sudo apt install -y cmake cmake-data libcairo2-dev libxcb1-dev libxcb-ewmh-dev \
     libxcb-icccm4-dev libxcb-image0-dev libxcb-randr0-dev libxcb-util0-dev libxcb-xkb-dev pkg-config python3-xcbgen \
     xcb-proto libxcb-xrm-dev i3-wm libasound2-dev libmpdclient-dev libiw-dev libcurl4-openssl-dev libpulse-dev \
     build-essential libxcb-composite0 libxcb-shape0-dev libxcb-xfixes0-dev libxcb-composite0-dev xcb \
     && polybar_debian


    mkdir -p ~/.config/polybar/{bin,scripts}

    cp $MY_PATH/polybar/launch.sh ~/.config/polybar/
    chmod u+x ~/.config/polybar/launch.sh

    cp $MY_PATH/polybar/config ~/.config/polybar/

    cp $MY_PATH/polybar/bin/* ~/.config/polybar/bin/
    cp $MY_PATH/polybar/scripts/* ~/.config/polybar/scripts/
    chmod u+x ~/.config/polybar/bin/*.sh
    chmod u+x ~/.config/polybar/scripts/*.sh

    $WGET -O ~/.config/polybar/scripts/networkmanager_dmenu.py https://raw.githubusercontent.com/firecat53/networkmanager-dmenu/master/networkmanager_dmenu

    find ~/.config/polybar/ -name "*.sh" -exec chmod u+x {} \;
    find ~/.config/polybar/ -name "*.py" -exec chmod u+x {} \;

    # install libreries scripts FIXME falta apt pacman y otro
    dnf --version > /dev/null 2>&1 && $DNF install python3-pip redshift xdotool yad light jq blueberry udiskie

    cp $MY_PATH/redshift.conf ~/.config/redshift.conf

    test -d ~/.config/polybar/scripts/gmail/ && $RM -rf ~/.config/polybar/scripts/gmail/
    $GIT clone https://github.com/vyachkonovalov/polybar-gmail.git ~/.config/polybar/scripts/gmail/
    pip3 install --upgrade google-api-python-client google-auth-httplib2 google-auth-oauthlib --user

    # laptop backlight
    if [ -f  /sys/class/backlight/intel_backlight/brightness ]; then
        sudo usermod -aG video $MY_USER
        sudo chown root:video /sys/class/backlight/intel_backlight/brightness
        sudo chmod 664 /sys/class/backlight/intel_backlight/brightness
    fi

    echo -e "${GREEN}Finishing Installing polybar${NC}"
}

#####################################################
#################### i3-lock ########################
#####################################################

function setup_i3lock() {
    echo -e "${GREEN}Finish Installing i3lock and ImageMagick ${NC}"
    dnf --version > /dev/null 2>&1 && $DNF install ImageMagick i3lock xautolock
    pacman --version > /dev/null 2>&1 && sudo pacman -Sy ImageMagick i3lock xautolock
    apt --version > /dev/null 2>&1 && sudo apt install -y imagemagick i3lock xautolock

    # TODO delete i3lock-fancy by use i3lock alone
    #test -d /opt/i3lock-fancy/ && sudo $RM -rf /opt/i3lock-fancy/
    #sudo git -q clone https://github.com/meskarune/i3lock-fancy.git /opt/i3lock-fancy/
    #cd /opt/i3lock-fancy
    #sudo make install

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
    test -d /opt/vim_runtime && sudo $RM -rf /opt/vim_runtime
    sudo $GIT clone --depth=1 https://github.com/amix/vimrc.git /opt/vim_runtime

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
    $DNF install $INSTALL
    $DNF install lsd bat ripgrep
}


function zsh_debian() {
    INSTALL=$1
    #LIST_REPOS="zsh-autosuggestions zsh-completions zsh-history-substring-search zsh-syntax-highlighting antigen"
    #repositories=( $LIST_REPOS )

    #for r in "${repositories[@]}"; do
    #    REPO="deb http://download.opensuse.org/repositories/shells:/zsh-users:/$r/Debian_$OS_ID/ /"
    #    sudo sh -c "echo \"$REPO\" > /etc/apt/sources.list.d/shells:zsh-users:$r.list"
    #    $WGET -nv https://download.opensuse.org/repositories/shells:zsh-users:$r/Debian_$OS_ID/Release.key -O Release.key
    #    sudo apt-key add - < Release.key
    #    $RM Release.key
    #done
    sudo apt install -y $INSTALL
    sudo apt install -y ripgrep  # maybe not store in repositories
    sudo dpkg -i $MY_PATH/resources/lsd_0.16.0_amd64.deb
    sudo dpkg -i $MY_PATH/resources/bat_0.13.0_amd64.deb
}


function zsh_raspbian() {
    INSTALL=$1
    sudo apt install -y $INSTALL
    sudo apt install -y ripgrep  # maybe not store in repositories
    sudo cp $MY_PATH/resources/lsd-0.17.0-arm /usr/local/bin/lsd
    sudo cp $MY_PATH/resources/bat-0.13.0-arm /usr/local/bin/bat
}


function setup_zsh() {
    INSTALL="zsh scrub fzf"
    echo -e "${GREEN}Installing zsh $INSTALL lsd bat ripgrep${NC}"

    apt --version > /dev/null 2>&1 && test $OS_NAME != "Raspbian" && zsh_debian "$INSTALL"
    test $OS_NAME = "Raspbian" && zsh_raspbian "$INSTALL"
    dnf --version > /dev/null 2>&1 && zsh_fedora "$INSTALL"

    zypper --version > /dev/null 2>&1 && sudo zypper install -y $INSTALL lsd bat
    pacman --version > /dev/null 2>&1 && sudo pacman -Sy $INSTALL lsd bat

    unzip -o resources/bat-extras-20200401.zip -d resources/ > /dev/null
    sudo mv resources/bat-extras/bin/batgrep /usr/local/bin/
    sudo mv resources/bat-extras/bin/prettybat /usr/local/bin/
    $RM -rf resources/bat-extras

    #[ -f ~/.fzf.sh ] && source ~/.fzf.sh
    test -f ~/.fzf.sh && source ~/.fzf.sh

    # If exsits remove back files and dir
    test -f ~/.zshrc && $RM -r ~/.zshrc
    test -f ~/.p10k.zsh && $RM -f ~/.p10k.zsh
    test -d ~/.oh-my-zsh && $RM -rf ~/.oh-my-zsh

    # Download and configuration oh my zsh
    timeout 20 sh -c "$(wget -q -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    sudo chsh -s $(which zsh) $MY_USER
    sudo chsh -s $(which zsh) root

    # Download theme oh my zsh
    ZSH_CUSTOM=$HOME/.oh-my-zsh/custom/themes
    $GIT clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
    cp $MY_PATH/zsh/zshrc ~/.zshrc
    cp $MY_PATH/zsh/p10k.zsh ~/.p10k.zsh

    # plugins zsh
    $GIT clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
    $GIT clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
    $GIT clone https://github.com/zsh-users/zsh-completions.git $ZSH_CUSTOM/plugins/zsh-completions
    $GIT clone https://github.com/zsh-users/zsh-history-substring-search.git $ZSH_CUSTOM/plugins/zsh-history-substring-search
    $GIT clone https://github.com/zsh-users/zsh-docker.git $ZSH_CUSTOM/plugins/zsh-docker

    # Create link to user root (insegure but comfortable)
    sudo ln -sf ~/.zshrc /root/.zshrc
    sudo ln -sf ~/.p10k.zsh /root/.p10k.zsh
    sudo ln -sf ~/.oh-my-zsh/ /root/

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

    dnf --version > /dev/null 2>&1 && $DNF install $INSTALL
    pacman --version > /dev/null 2>&1 && sudo pacman -Sy $INSTALL 2>&1
    apt --version > /dev/null 2>&1 && sudo apt install -y $INSTALL

    test -d ~/.tmux && $RM -rf ~/.tmux
    test -f ~/.tmux.conf && $RM -f ~/.tmux.conf
    test -L ~/.tmux.conf && unlink ~/.tmux.conf
    test -f ~/.tmux.conf.local && $RM -f ~/.tmux.conf.local

    $GIT clone https://github.com/gpakosz/.tmux.git ~/.tmux
    ln -sf ~/.tmux/.tmux.conf ~/.tmux.conf
    cp ~/.tmux/.tmux.conf.local ~/.tmux.conf.local
    echo -e "${GREEN}Finishing Installing $INSTALL ${NC}"
}


function main() {
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

    #kill -9 -1
}



function ctrl_c(){
    print_format "Exiting..."
    #echo -e "\n${RED}Exiting...${NC}"
    tput cnorm
    exit 0
}


#trap 'exit 130' INT #Exit if trap Ctrl+C
trap ctrl_c INT


#Colours
declare -r BLACK_COLOUR='\e[0;30m'
declare -r RED_COLOUR='\e[0;31m'
declare -r GREEN_COLOUR='\e[0;32m'
declare -r ORANGE_COLOUR='\e[0;33m'
declare -r BLUE_COLOUR='\e[0;34m'
declare -r PURPLE_COLOUR='\e[0;35m'
declare -r CYAN_COLOUR='\e[0;36m'
declare -r WHITE_COLOUR='\e[0;37m'
declare -r RESET_COLOUR='\e[0m'


main "$@"

