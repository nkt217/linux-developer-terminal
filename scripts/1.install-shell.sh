#!/bin/bash

line_divider() {
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
}

# get os id
pkg_manager=""

# Check for Debian family
if [ -f /etc/debian_version ]; then
    pkg_manager="apt"
fi

# Check for Red Hat family
if [ -f /etc/redhat-release ]; then
    pkg_manager="dnf"
fi

if [ -z "$pkg_manager" ] || [ "$pkg_manager" == "" ]; then
    line_divider
    echo "OS Family not supported by the script. Only Debian/RedHat based OS supported right now."
    line_divider
    exit 1
fi

base_dir="/media/$(whoami)/LxData"

if ! [ -d $base_dir ];then
    line_divider
    read -p $'Dir \"$base_dir\" directory doesn\'t exists.\nSetup link to directory (N/n to cancel this operation) [default: /home/$(whoami)]' response
    if [[ -z "$response" ]]; then
        response="/home/$(whoami)"
    fi
    if [[ "$response" =~ ^([nN])$ ]]; then
        line_divider
        echo "Aborting..."
        line_divider
    else
        sudo mkdir -p /media/$(whoami)
        sudo ln -nfs $response $base_dir
        line_divider
        echo "Dir \"$base_dir\" is setup and is symlink to ${response}"
        line_divider
    fi
fi

line_divider
echo "Installing essential utilities"
line_divider

if [ "$pkg_manager" ==  "apt" ]; then
    sudo apt update  
elif [ "$pkg_manager" ==  "dnf" ]; then
    sudo dnf check-update
fi
sudo $pkg_manager install curl wget zsh vim zip unzip tilix -y
if [ "$pkg_manager" ==  "apt" ]; then
    sudo apt install build-essential apt-transport-https software-properties-common ttf-mscorefonts-installer -y
elif [ "$pkg_manager" ==  "dnf" ]; then
    sudo dnf install @development-tools dnf-plugins-core fedora-workstation-repositories.noarch cabextract -y
fi

line_divider
read -p "Install flatpak? [Y/n]" response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Proceeding with installation..."    
    sudo $pkg_manager install flatpak gnome-software-plugin-flatpak -y
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
else
    echo "Aborting."
fi

line_divider
read -p "Install gnome tools? [Y/n]" response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Proceeding with installation..."
    sudo $pkg_manager install gnome-tweaks -y
    flatpak install org.gnome.Extensions com.mattjakeman.ExtensionManager 
else
    echo "Aborting."
fi

line_divider
echo 'Configuring git globals'
line_divider

git config --global user.email "your_email@example.com"
git config --global user.name "FirstName"
git config --global core.editor "vim"
git config --global core.excludesFile "/media/$(whoami)/LxData/codebase/terminal-setup/git/.gitignore"
git config --global init.defaultBranch "main"

line_divider
echo 'Installing symlinks for customization scripts'
line_divider

mkdir -p $HOME/.ssh

ln -nfs /media/$(whoami)/LxData/codebase/000-personal/terminal-setup/.custom-config $HOME/.custom-config &&
ln -nfs /media/$(whoami)/LxData/codebase/000-personal/terminal-setup/.custom-aliases $HOME/.custom-aliases &&
ln -nfs /media/$(whoami)/LxData/codebase/000-personal/terminal-setup/ssh-keys/id_rsa $HOME/.ssh/id_rsa &&
ln -nfs /media/$(whoami)/LxData/codebase/000-personal/terminal-setup/ssh-keys/id_rsa.pub $HOME/.ssh/id_rsa.pub

chmod 400 $HOME/.ssh/*

line_divider
echo 'Installing ohmy-zsh'
line_divider
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

source ~/.zshrc
