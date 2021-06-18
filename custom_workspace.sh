#!/bin/bash
# Author: Pablo Rocamora (aka procamora)

# Exit script if you try to use an uninitialized variable.
#set -o nounset

# Exit script if a statement returns a non-true return value.
#set -o errexit

# Use the error status of the first failure, rather than that of the last item in a pipeline.
set -o pipefail

export DEBIAN_FRONTEND=noninteractive

if grep -i 'PRETTY_NAME' /etc/os-release | grep -q 'Fedora'; then
    OS_SYSTEM='fedora'
elif grep -i 'PRETTY_NAME' /etc/os-release | grep -q 'CentOS'; then
    OS_SYSTEM='centos'
elif grep -i 'PRETTY_NAME' /etc/os-release | grep -q 'Debian'; then
    OS_SYSTEM='debian'
elif grep -i 'PRETTY_NAME' /etc/os-release | grep -q 'Ubuntu'; then
    OS_SYSTEM='ubuntu'
fi



DNF="sudo dnf -yq"
WGET="wget -q"
RM="/bin/rm"

LOG="install.log"


MY_PATH=$(pwd)
MY_USER=$USER
OS_NAME=$(< /etc/os-release grep -E "^NAME=" | tr -d \" | awk -F = '{print $NF}' | awk -F " " '{print $1}')
#OS_ID=$(< /etc/os-release grep VERSION_ID | cut -d= -f2 | tr -d \")


function print_format() {
    echo -e "${GREEN_COLOUR}$1${RESET_COLOUR}" # print stdout
    >&2 echo -e "${RED_COLOUR}$1${RESET_COLOUR}" # print stderr
}


function ctrl_c(){
    print_format "Exiting..."
    #print_format "\n${RED}Exiting...${RESET_COLOUR}"
    tput cnorm
    exit 0
}


#trap 'exit 130' INT #Exit if trap Ctrl+C
trap ctrl_c INT


#####################################################
################### basic utils #####################
#####################################################

function setup_utils() {
    INSTALL="unzip wget git gcc make cmake neovim"
    print_format "${GREEN_COLOUR}Installing ${ORANGE_COLOUR}$INSTALL @development-tools${RESET_COLOUR}"

    if [[ $OS_SYSTEM = 'fedora' ]]; then
        $DNF install $INSTALL
        $DNF install @development-tools
    elif [[ $OS_SYSTEM = 'centos' ]]; then
        $DNF install $INSTALL
#        $DNF install @development-tools
    elif [[ $OS_SYSTEM = 'ubuntu' ]]; then
        sudo apt install -y $INSTALL
    elif [[ $OS_SYSTEM = 'debian' ]]; then
        sudo apt install -y $INSTALL
    elif [[ $OS_SYSTEM = 'raspbian' ]]; then
        sudo apt install -y $INSTALL
    elif [[ $OS_SYSTEM = 'arch' ]]; then
        sudo pacman -Sy $INSTALL 2>&1
    else
        print_format "Error with $OS_SYSTEM"
    fi
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

    if [[ $OS_SYSTEM = 'fedora' ]]; then
        $DNF install dbus-devel libX11-devel libXrandr-devel glib2-devel pango-devel \
            gtk2-devel libxdg-basedir-devel libXScrnSaver-devel libnotify-devel
    elif [[ $OS_SYSTEM = 'centos' ]]; then
        $DNF install dbus-devel libX11-devel libXrandr-devel glib2-devel pango-devel \
            gtk2-devel libxdg-basedir-devel libXScrnSaver-devel libnotify-devel
    elif [[ $OS_SYSTEM = 'ubuntu' ]]; then
        sudo apt install -y libdbus-1-dev libx11-dev libxinerama-dev libxrandr-dev libxss-dev \
            libglib2.0-dev libpango1.0-dev libgtk-3-dev libxdg-basedir-dev libnotify-dev
    elif [[ $OS_SYSTEM = 'debian' ]]; then
        sudo apt install -y libdbus-1-dev libx11-dev libxinerama-dev libxrandr-dev libxss-dev \
            libglib2.0-dev libpango1.0-dev libgtk-3-dev libxdg-basedir-dev libnotify-dev
    elif [[ $OS_SYSTEM = 'raspbian' ]]; then
        sudo apt install -ylibdbus-1-dev libx11-dev libxinerama-dev libxrandr-dev libxss-dev \
            libglib2.0-dev libpango1.0-dev libgtk-3-dev libxdg-basedir-dev libnotify-dev
    elif [[ $OS_SYSTEM = 'arch' ]]; then
        sudo pacman -Sy $INSTALL 2>&1
    else
        print_format "Error with $OS_SYSTEM"
    fi

    # clone the repository
    test -d dunst_comp/ && $RM -rf dunst_comp/
    git clone -q https://github.com/dunst-project/dunst.git dunst_comp/
    pushd dunst_comp/ || exit 2
    # compile and install
    make > /dev/null
    sudo make install > /dev/null
    #sudo cp -f {dunst,dunstify} /usr/local/bin/
    popd || exit 2
    test -d dunst_comp/ && $RM -rf dunst_comp/
    cp -fu "$MY_PATH/dunst/dunstrc" ~/.config/dunst/dunstrc
}


function setup_bspwm() {
    INSTALL="bspwm sxhkd compton feh rofi ksysguard dolphin dolphin-plugins numlockx plasma-integration"
    print_format "${GREEN_COLOUR}Installing ${ORANGE_COLOUR}$INSTALL ${RESET_COLOUR}"

    if [[ $OS_SYSTEM = 'fedora' ]]; then
        $DNF install $INSTALL libXinerama libXinerama-devel libxcb xcb-util \
           xcb-util-devel xcb-util-keysyms-devel xcb-util-wm-devel alsa-lib-devel dmenu rxvt-unicode terminus-fonts \
           xcb-util-wm xcb-util-keysyms
        $DNF install konsole 2>&1
    elif [[ $OS_SYSTEM = 'centos' ]]; then
        $DNF install $INSTALL libXinerama libXinerama-devel libxcb xcb-util \
           xcb-util-devel xcb-util-keysyms-devel xcb-util-wm-devel alsa-lib-devel dmenu rxvt-unicode terminus-fonts \
           xcb-util-wm xcb-util-keysyms
        $DNF install konsole 2>&1
    elif [[ $OS_SYSTEM = 'ubuntu' ]]; then
        sudo apt install -y $INSTALL libxcb-xinerama0-dev libxcb-icccm4-dev \
            libxcb-randr0-dev libxcb-util0-dev libxcb-ewmh-dev libxcb-keysyms1-dev libxcb-shape0-dev konsole
    elif [[ $OS_SYSTEM = 'debian' ]]; then
        sudo apt install -y $INSTALL libxcb-xinerama0-dev libxcb-icccm4-dev \
            libxcb-randr0-dev libxcb-util0-dev libxcb-ewmh-dev libxcb-keysyms1-dev libxcb-shape0-dev konsole
    elif [[ $OS_SYSTEM = 'raspbian' ]]; then
        sudo apt install -y $INSTALL libxcb-xinerama0-dev libxcb-icccm4-dev \
            libxcb-randr0-dev libxcb-util0-dev libxcb-ewmh-dev libxcb-keysyms1-dev libxcb-shape0-dev konsole
    elif [[ $OS_SYSTEM = 'arch' ]]; then
        sudo pacman -Sy $INSTALL libxcb xcb-util xcb-util-wm xcb-util-keysyms konsole 2>&1
    else
        print_format "Error with $OS_SYSTEM"
    fi

    mkdir -p ~/.config/{bspwm/{scripts,},sxhkd,compton,rofi,icons,dunst}
    cp -rf "$MY_PATH/bspwm/" ~/.config/
    cp -rf "$MY_PATH/sxhkd/" ~/.config/
    cp -rf "$MY_PATH/rofi/" ~/.config/
    cp -rf "$MY_PATH/icons/" ~/.config/
    chmod u+x ~/.config/bspwm/bspwmrc

    echo "sxhkd &
exec bspwm" > ~/.xinitrc

    cp -f "$MY_PATH/bspwm/scripts/resize" ~/.config/bspwm/scripts/
    chmod u+x  ~/.config/bspwm/scripts/resize

    # set transparent
    cp -f "$MY_PATH/compton/compton.conf" ~/.config/compton/

    # set wallpaper
    #wget -O ~/.config/wallpaper.png https://procamora.github.io/images/wallpaper.png > wget.log
    cp -f "$MY_PATH/resources/wallpaper.png" ~/.config/wallpaper.png
    cp -f "$MY_PATH/resources/lock.png" ~/.config/lock.png

    dunst
}



#####################################################
###################### fonts ########################
#####################################################
# https://github.com/ryanoasis/nerd-fonts/

function setup_fonts() {
    print_format "${GREEN_COLOUR}Installing ${ORANGE_COLOUR}Hack Nerd Font${RESET_COLOUR}"

    #MY_FONT="Hack Nerd Font"

    # Set custom fonts
    sudo mkdir -p /usr/local/share/fonts
    sudo cp -f resources/Hack.zip /usr/local/share/fonts/
    sudo unzip -o /usr/local/share/fonts/Hack.zip -d /usr/local/share/fonts/ > /dev/null
    sudo $RM /usr/local/share/fonts/Hack.zip

    # test -f /etc/vconsole.conf && sudo sed -i.back -re "s/FONT=\".*\"/FONT=\"$MY_FONT\"/g" /etc/vconsole.conf
    # ! test -f /etc/vconsole.conf && sudo cp resources/vconsole.conf /etc/

    # basic language and time init calander monday
    echo 'LANG="en_US.UTF-8"
LC_TIME="en_GB.UTF-8"
LC_PAPER="en_GB.UTF-8"
LC_MEASUREMENT="en_GB.UTF-8"' | sudo tee /etc/locale.conf > /dev/null

    print_format "${GREEN_COLOUR}Installing ${ORANGE_COLOUR}papirus theme${RESET_COLOUR}"
    $WGET -qO- https://git.io/papirus-icon-theme-install | sh >/dev/null 2> $LOG

     # if exists command execute
    if command -v kwriteconfig5 > /dev/null ; then
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
    sudo cp -f resources/polybar-3.4.2.tar /opt/
    sudo tar xvf /opt/polybar-3.4.2.tar -C /opt/
    sudo $RM /opt/polybar-3.4.2.tar
    mkdir -p /opt/polybar/build
    pushd /opt/polybar/build && cmake .. && make -j "$(nproc)" && sudo make install && (popd || exit 2)
}


function setup_polybar() {
    print_format "${GREEN_COLOUR}Installing ${ORANGE_COLOUR}polybar and dependencies${RESET_COLOUR}"

    if [[ $OS_SYSTEM = 'fedora' ]]; then
        $DNF install gcc-c++ clang git cmake @development-tools python3-sphinx \
          cairo-devel xcb-util-devel libxcb-devel xcb-proto xcb-util-image-devel xcb-util-wm-devel polybar
    elif [[ $OS_SYSTEM = 'centos' ]]; then
        $DNF install gcc-c++ clang git cmake @development-tools python3-sphinx \
          cairo-devel xcb-util-devel libxcb-devel xcb-proto xcb-util-image-devel xcb-util-wm-devel polybar
    elif [[ $OS_SYSTEM = 'ubuntu' ]]; then
        sudo apt install -y cmake cmake-data libcairo2-dev libxcb1-dev libxcb-ewmh-dev \
           libxcb-icccm4-dev libxcb-image0-dev libxcb-randr0-dev libxcb-util0-dev libxcb-xkb-dev pkg-config python3-xcbgen \
           xcb-proto libxcb-xrm-dev i3-wm libasound2-dev libmpdclient-dev libiw-dev libcurl4-openssl-dev libpulse-dev \
           build-essential libxcb-composite0 libxcb-shape0-dev libxcb-xfixes0-dev libxcb-composite0-dev xcb \
           && polybar_debian
    elif [[ $OS_SYSTEM = 'debian' ]]; then
        sudo apt install -y cmake cmake-data libcairo2-dev libxcb1-dev libxcb-ewmh-dev \
           libxcb-icccm4-dev libxcb-image0-dev libxcb-randr0-dev libxcb-util0-dev libxcb-xkb-dev pkg-config \
           xcb-proto libxcb-xrm-dev i3-wm libasound2-dev libmpdclient-dev libiw-dev libcurl4-openssl-dev libpulse-dev \
           build-essential libxcb-composite0 libxcb-shape0-dev libxcb-xfixes0-dev libxcb-composite0-dev xcb \
           && polybar_debian
        sudo apt install -y python-xcbgen  # revisar si aparece python3-xcbgen
    elif [[ $OS_SYSTEM = 'raspbian' ]]; then
        sudo apt install -y cmake cmake-data libcairo2-dev libxcb1-dev libxcb-ewmh-dev \
           libxcb-icccm4-dev libxcb-image0-dev libxcb-randr0-dev libxcb-util0-dev libxcb-xkb-dev pkg-config python3-xcbgen \
           xcb-proto libxcb-xrm-dev i3-wm libasound2-dev libmpdclient-dev libiw-dev libcurl4-openssl-dev libpulse-dev \
           build-essential libxcb-composite0 libxcb-shape0-dev libxcb-xfixes0-dev libxcb-composite0-dev xcb \
           && polybar_debian
    elif [[ $OS_SYSTEM = 'arch' ]]; then
        sudo pacman -Sy $INSTALL 2>&1
    else
        print_format "Error with $OS_SYSTEM"
    fi

    # FIXME FALTA POR PONER LAS LIBRERIAS PARA PACMAN
    #pacman --version > /dev/null 2>&1 && sudo

    mkdir -p ~/.config/polybar/{bin,scripts}

    cp -rf "$MY_PATH/polybar/" ~/.config/
    #cp "$MY_PATH/polybar/launch.sh" ~/.config/polybar/
    chmod u+x ~/.config/polybar/launch.sh

    #cp -r "$MY_PATH/polybar/config" ~/.config/polybar/

    #cp -r "$MY_PATH/polybar/bin/" ~/.config/polybar/bin/
    #cp -r "$MY_PATH/polybar/scripts/" ~/.config/polybar/scripts/
    chmod u+x ~/.config/polybar/bin/*.sh
    chmod u+x ~/.config/polybar/scripts/*.sh

    $WGET -O ~/.config/polybar/scripts/networkmanager_dmenu.py https://raw.githubusercontent.com/firecat53/networkmanager-dmenu/main/networkmanager_dmenu

    find ~/.config/polybar/ -name "*.sh" -exec chmod u+x {} \;
    find ~/.config/polybar/ -name "*.py" -exec chmod u+x {} \;

    # install libreries scripts FIXME falta apt pacman y otro
    dnf --version > /dev/null 2>&1 && $DNF install python3-pip redshift xdotool yad light jq blueberry udiskie

    cp -f "$MY_PATH/redshift.conf" ~/.config/redshift.conf

    test -d ~/.config/polybar/scripts/gmail/ && $RM -rf ~/.config/polybar/scripts/gmail/
    git clone -q https://github.com/vyachkonovalov/polybar-gmail.git ~/.config/polybar/scripts/gmail/
    pip3 -q install --upgrade google-api-python-client google-auth-httplib2 google-auth-oauthlib --user

    # laptop backlight
    if [ -f  /sys/class/backlight/intel_backlight/brightness ]; then
        sudo usermod -aG video "$MY_USER"
        sudo chown root:video /sys/class/backlight/intel_backlight/brightness
        sudo chmod 664 /sys/class/backlight/intel_backlight/brightness
    fi

}

#####################################################
#################### i3-lock ########################
#####################################################

function setup_i3lock() {
    print_format "${GREEN_COLOUR}Installing ${ORANGE_COLOUR}i3lock and ImageMagick ${RESET_COLOUR}"

    if [[ $OS_SYSTEM = 'fedora' ]]; then
        $DNF install ImageMagick i3lock xautolock
    elif [[ $OS_SYSTEM = 'centos' ]]; then
        $DNF install ImageMagick i3lock xautolock
    elif [[ $OS_SYSTEM = 'ubuntu' ]]; then
        sudo apt install -y imagemagick i3lock xautolock
    elif [[ $OS_SYSTEM = 'debian' ]]; then
        sudo apt install -y imagemagick i3lock xautolock
    elif [[ $OS_SYSTEM = 'raspbian' ]]; then
        sudo apt install -y imagemagick i3lock xautolock
    elif [[ $OS_SYSTEM = 'arch' ]]; then
        sudo pacman -Sy ImageMagick i3lock xautolock 2>&1
    else
        print_format "Error with $OS_SYSTEM"
    fi

    # TODO delete i3lock-fancy by use i3lock alone
    #test -d /opt/i3lock-fancy/ && sudo $RM -rf /opt/i3lock-fancy/
    #sudo git -q clone https://github.com/meskarune/i3lock-fancy.git /opt/i3lock-fancy/
    #cd /opt/i3lock-fancy
    #sudo make install

    #cd $MY_PATH
    echo > /dev/null # force return ok
}



#####################################################
######################## vim ########################
#####################################################

function setup_vim() {
    print_format "${GREEN_COLOUR}Installing ${ORANGE_COLOUR}vim, plugins and syntax checkers ${RESET_COLOUR}"
    # Install checklinter to:
    # - C C++       cppcheck
    # - CMake
    # - Dockerfile  dockerfile_lint
    # - Go
    # - JSON        python3-demjson (jsonlint)
    # - Python      pylint
    # - Sh          ShellCheck
    # - SQL         sqlint
    # - VimL        vim-vimlint
    # - XML         libxml2 (xmllint)
    # - YAML        yamllint
    # Others: python3-ansible-lint tflint

    if [[ $OS_SYSTEM = 'fedora' ]]; then
        $DNF install pylint yamllint ShellCheck python3-ansible-lint gem ruby-devel redhat-rpm-config npm \
            python3-demjson python3-pycodestyle cmake gcc-c++ make python3-devel mono-complete nodejs java-1.8.0-openjdk-devel python3-pip
    elif [[ $OS_SYSTEM = 'centos' ]]; then
      # fixme search python3-ansible-lint python3-demjson shellcheck
        $DNF install pylint yamllint  gem ruby-devel redhat-rpm-config npm \
            python3-pycodestyle cmake gcc-c++ make python3-devel mono-complete nodejs java-1.8.0-openjdk-devel python3-pip
    elif [[ $OS_SYSTEM = 'ubuntu' ]]; then
        sudo apt install -y
    elif [[ $OS_SYSTEM = 'debian' ]]; then
        sudo apt install -y npm python3-pip yamllint pylint gem shellcheck ansible-lint ruby-dev python3-dev nodejs openjdk-11-jdk python3-pip
    elif [[ $OS_SYSTEM = 'raspbian' ]]; then
        sudo apt install -y
    elif [[ $OS_SYSTEM = 'arch' ]]; then
        sudo pacman -Sy  2>&1
    else
        print_format "Error with $OS_SYSTEM"
    fi

    sudo gem update 2>/dev/null
    sudo gem update --system >/dev/null  # fixme funciona???
    gem install sqlint >/dev/null  # fixme funciona ??
    pip3 install cmakelint --user >/dev/null
    sudo npm install -g dockerfile_lint --silent >/dev/null
    sudo npm install sql-formatter --silent >/dev/null
    sudo npm install node-sql-parser --save --silent >/dev/null
    sudo pip3 install jedi >/dev/null
    sudo npm install -g bash-language-server --silent >/dev/null
    sudo npm install -g dockerfile-language-server-nodejs --silent >/dev/null

    mkdir -p ~/.vim
    cp -f vim/vimrc ~/.vimrc
    cp -f vim/my_plugins.vim ~/.vim/
    cp -f vim/coc-settings.json ~/.vim/coc-settings.json

    curl -sfLo ~/.vim/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    #(timeout 120 xterm -e /bin/bash -l -c "vim +PlugInstall +qall") &
    #timeout 120 vim +PlugInstall +qall


    TAR_GO="go1.15.2.linux-amd64.tar.gz"
    wget -q https://golang.org/dl/$TAR_GO \
     -O $TAR_GO
    sudo tar -C /usr/local -xzf $TAR_GO
    export PATH=$PATH:/usr/local/go/bin
    rm -rf $TAR_GO

    TAR="terraform-ls_0.10.0_linux_amd64.zip"
    wget -q https://github.com/hashicorp/terraform-ls/releases/download/v0.10.0/"$TAR"
    unzip -q "$TAR"
    sudo mv terraform-ls /usr/local/bin/
    rm -f "$TAR"

    # alias vipluginstall="vim +PlugInstall +qall"

    #bash -c "$(wget -q -O - https://linux.kite.com/dls/linux/current)"

    sudo cp -rf ~/.vimrc /root/.vimrc
    sudo cp -rf ~/.vim /root/.vim
    echo > /dev/null  # force return true
}



#####################################################
######################## zsh ########################
#####################################################

# https://github.com/ohmyzsh/ohmyzsh/blob/master/tools/install.sh
# https://github.com/romkatv/powerlevel10k#oh-my-zsh

function setup_zsh() {
    INSTALL="zsh fzf"
    print_format "${GREEN_COLOUR}Installing ${ORANGE_COLOUR}zsh $INSTALL lsd bat ripgrep${RESET_COLOUR}"

    if [[ $OS_SYSTEM = 'fedora' ]]; then
        $DNF install $INSTALL
        $DNF install lsd bat ripgrep util-linux-user trash-cli
        $DNF install scrub
    elif [[ $OS_SYSTEM = 'centos' ]]; then
        $DNF install $INSTALL
        $DNF install lsd bat ripgrep util-linux-user trash-cli
        $DNF install scrub
    elif [[ $OS_SYSTEM = 'ubuntu' ]]; then
        sudo apt install -y $INSTALL
        sudo apt install -y ripgrep trash-cli  # maybe not store in repositories
        sudo dpkg -i "$MY_PATH/resources/lsd_0.16.0_amd64.deb"
        sudo dpkg -i "$MY_PATH/resources/bat_0.13.0_amd64.deb"
    elif [[ $OS_SYSTEM = 'debian' ]]; then
        sudo apt install -y $INSTALL
        sudo apt install -y ripgrep trash-cli  # maybe not store in repositories
        sudo dpkg -i "$MY_PATH/resources/lsd_0.16.0_amd64.deb"
        sudo dpkg -i "$MY_PATH/resources/bat_0.13.0_amd64.deb"
    elif [[ $OS_SYSTEM = 'raspbian' ]]; then
        sudo apt install -y $INSTALL
        sudo apt install -y ripgrep trash-cli # maybe not store in repositories
        sudo cp -f "$MY_PATH/resources/lsd-0.17.0-arm" /usr/local/bin/lsd
        sudo cp -f "$MY_PATH/resources/bat-0.13.0-arm" /usr/local/bin/bat
   elif [[ $OS_SYSTEM = 'arch' ]]; then
        sudo pacman -Sy $INSTALL lsd bat
    else
        print_format "Error with $OS_SYSTEM"
    fi
    #zypper --version > /dev/null 2>&1 && sudo zypper install -y $INSTALL lsd bat


    test -d ./bat-extras && sudo rm -rf ./bat-extras
    git clone -q https://github.com/eth-p/bat-extras ./bat-extras
    pushd ./bat-extras && sudo ./build.sh --install >/dev/null && popd && sudo rm -rf ./bat-extras

    unzip -o resources/bat-extras-20200401.zip -d resources/ > /dev/null
    sudo mv resources/bat-extras/bin/batgrep /usr/local/bin/
    sudo mv resources/bat-extras/bin/prettybat /usr/local/bin/
    $RM -rf resources/bat-extras
    sudo mv -f resources/shfmt_v3.2.1_linux_amd64 /usr/local/bin/shfmt && sudo chmod +x /usr/local/bin/shfmt

    cp -f zsh/alias_git.zsh ~/.alias_git.zsh

    #[ -f ~/.fzf.sh ] && source ~/.fzf.sh
    # shellcheck disable=SC1090
    test -f ~/.fzf.sh && source ~/.fzf.sh

    # If exsits remove back files and dir
    test -f ~/.zshrc && $RM -r ~/.zshrc
    test -f ~/.p10k.zsh && $RM -f ~/.p10k.zsh
    test -d ~/.oh-my-zsh && $RM -rf ~/.oh-my-zsh

    # Download and configuration oh my zsh
    timeout 20 sh -c "$(wget -q -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" > /dev/null 2> $LOG

    sudo chsh -s "$(command -v  zsh)" "$MY_USER" 2>&1
    sudo chsh -s "$(command -v  zsh)" root 2>&1

    # Download theme oh my zsh
    ZSH_CUSTOM=$HOME/.oh-my-zsh/custom/themes
    git clone -q --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
    cp -f "$MY_PATH/zsh/zshrc" ~/.zshrc
    cp -f "$MY_PATH/zsh/p10k.zsh" ~/.p10k.zsh

    # plugins zsh
    git clone -q https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    git clone -q https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    git clone -q https://github.com/zsh-users/zsh-completions.git "$ZSH_CUSTOM/plugins/zsh-completions"
    git clone -q https://github.com/zsh-users/zsh-history-substring-search.git "$ZSH_CUSTOM/plugins/zsh-history-substring-search"
    git clone -q https://github.com/zsh-users/zsh-docker.git "$ZSH_CUSTOM/plugins/zsh-docker"

    # copy config user tp root
    sudo cp -rf ~/.zshrc /root/.zshrc
    sudo cp -rf ~/.p10k.zsh /root/.p10k.zsh
    sudo cp -rf ~/.oh-my-zsh/ /root/
}



function setup_konsole() {
    # set default profile konsole
    mkdir -p ~/.local/share/konsole/
    mkdir -p ~/.config/
    cp -f konsole/zsh.profile ~/.local/share/konsole/
    cp -f konsole/config_konsolerc ~/.config/konsolerc
}


function setup_tmux() {
    INSTALL="tmux"
    print_format "${GREEN_COLOUR}Installing ${ORANGE_COLOUR}$INSTALL ${RESET_COLOUR}"

    if [[ $OS_SYSTEM = 'fedora' ]]; then
        $DNF install $INSTALL
    elif [[ $OS_SYSTEM = 'centos' ]]; then
        $DNF install $INSTALL
    elif [[ $OS_SYSTEM = 'ubuntu' ]]; then
        sudo apt install -y $INSTALL
    elif [[ $OS_SYSTEM = 'debian' ]]; then
        sudo apt install -y $INSTALL
    elif [[ $OS_SYSTEM = 'raspbian' ]]; then
        sudo apt install -y $INSTALL
    elif [[ $OS_SYSTEM = 'arch' ]]; then
        sudo pacman -Sy $INSTALL 2>&1
    else
        print_format "Error with $OS_SYSTEM"
    fi

    test -d ~/.tmux && $RM -rf ~/.tmux
    test -f ~/.tmux.conf && $RM -f ~/.tmux.conf
    test -L ~/.tmux.conf && unlink ~/.tmux.conf
    test -f ~/.tmux.conf.local && $RM -f ~/.tmux.conf.local

    git clone -q https://github.com/gpakosz/.tmux.git ~/.tmux
    ln -sf ~/.tmux/.tmux.conf ~/.tmux.conf
    cp -f ~/.tmux/.tmux.conf.local ~/.tmux.conf.local
}


function install_bspwn() {
    setup_utils
    setup_bspwm
    sudo -v # refresh timeout
    setup_fonts
    setup_polybar
    sudo -v # refresh timeout
    setup_i3lock
}


function install_vim() {
    setup_utils
    setup_vim
}


function install_zsh() {
    setup_utils
    setup_fonts
    sudo -v # refresh timeout
    setup_zsh
    setup_konsole
    setup_tmux
}


function install_all() {
    setup_utils
    setup_bspwm
    sudo -v # refresh timeout
    setup_fonts
    setup_polybar
    sudo -v # refresh timeout
    setup_i3lock
    setup_vim
    sudo -v # refresh timeout
    setup_zsh
    setup_konsole
    sudo -v # refresh timeout
    setup_tmux
}


function print_help() {
    PROGRAM=$(echo "$0" | tr -d './' | tr -d '.sh')
    PROGRAM=$(echo "$0" | awk -F "./" '{print $NF}' | awk -F ".sh" '{print $1}')

    echo -e "\n${PURPLE_COLOUR}${PROGRAM} v1.0 (Source: https://github.com/procamora/custom_workspace)${RESET_COLOUR}"
    echo -e  "\n${ORANGE_COLOUR}[*] Use: ./${PROGRAM}.sh OPTION${RESET_COLOUR}"
    echo -e  "\n${ORANGE_COLOUR}[*] DO NOT EXECUTE the script with the sudo command without specifying the user${RESET_COLOUR}"
    echo -e  "\n${ORANGE_COLOUR}[*] List of available options:${RESET_COLOUR}"
    echo -e  "\t${GREEN_COLOUR}bspwm${RESET_COLOUR}\t\t Install the bspwm window manager and all its requirements"
    echo -e  "\t${GREEN_COLOUR}vim${RESET_COLOUR}\t\t Install the vim editor with a custom theme"
    echo -e  "\t${GREEN_COLOUR}zsh${RESET_COLOUR}\t\t Install the zsh shell, various plugins and customize"
    echo -e  "\t${GREEN_COLOUR}all${RESET_COLOUR}\t\t Install all packages"
    echo -e  "\t${GREEN_COLOUR}help${RESET_COLOUR}\t\t Show help"


    echo -e  "\n\n${BLUE_COLOUR}Example: ./${PROGRAM}.sh all${RESET_COLOUR}\n"

    #tput cnorm
    exit 1
}



function main() {
    #tput civis
    #print_format "$@"
    VALID_ARGUMENT="False" # Usado para detectar si se ha puesto un argumento valido

    test "$1" = "" && print_help
    test "$1" = "help" && print_help

    # check user administrator
    sudo -l > /dev/null || (print_format "$MY_USER is not user administrator" && exit 1)

    test "$1" = "bspwm" && install_bspwn ; VALID_ARGUMENT="True"
    test "$1" = "vim" && install_vim ; VALID_ARGUMENT="True"
    test "$1" = "zsh" && install_zsh ; VALID_ARGUMENT="True"
    test "$1" = "all" && install_all ; VALID_ARGUMENT="True"

    test "$1" = "_utils" && setup_utils ; VALID_ARGUMENT="True"
    test "$1" = "_bspwm" && setup_bspwm ; VALID_ARGUMENT="True"
    test "$1" = "_fonts" && setup_fonts ; VALID_ARGUMENT="True"
    test "$1" = "_polybar" && setup_polybar ; VALID_ARGUMENT="True"
    test "$1" = "_i3lock" && setup_i3lock ; VALID_ARGUMENT="True"
    test "$1" = "_vim" && setup_vim ; VALID_ARGUMENT="True"
    test "$1" = "_zsh" && setup_zsh ; VALID_ARGUMENT="True"
    test "$1" = "_konsole" && setup_konsole ; VALID_ARGUMENT="True"
    test "$1" = "_tmux" && setup_tmux ; VALID_ARGUMENT="True"


    # BUSCAR DOLPHIN O CUALQUIER OTRO EXPLORADOR DE FICHEROS
    test "$VALID_ARGUMENT" = "False" && print_help

    wait
    echo -e "${GREEN_COLOUR}Finishing $0${RESET_COLOUR}"
}


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

