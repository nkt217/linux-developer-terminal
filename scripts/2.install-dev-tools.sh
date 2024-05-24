#!/bin/zsh

line_divider() {
    local cols=$(tput cols)
    if [[ -z "$cols" ]]; then
        cols=80  # Default value if tput fails
    fi
    printf '%*s\n' "$cols" '' | tr ' ' =
}

# Get OS ID and version
if [ -f /etc/os-release ]; then
    source /etc/os-release
    DISTRO_ID=$ID
    DISTRO_VERSION=$VERSION_ID
else
    line_divider
    echo "Cannot determine the OS distribution. /etc/os-release not found."
    line_divider
    exit 1
fi

# Determine package manager
pkg_manager=""

# Check for Debian family
if [[ "$DISTRO_ID" = "debian" || "$DISTRO_ID" = "ubuntu" ]] || [ -f /etc/debian_version ]; then
	pkg_manager="apt"
fi

# Check for Red Hat family
if [[ "$DISTRO_ID" = "rhel" || "$DISTRO_ID" = "fedora" || "$DISTRO_ID" = "centos" ]] || [ -f /etc/redhat-release ]; then
	pkg_manager="dnf"
fi

if [ -z "$pkg_manager" ] || [ "$pkg_manager" = "" ]; then
    line_divider
    echo "OS Family not supported by the script. Only Debian/RedHat based OS supported right now."
    line_divider
    exit 1
fi

line_divider
read -q "response?Configure Dotfiles? [Y/n] "
echo
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
	# updating zsh file
	line_divider
	echo "Updating ZSH config file"
	line_divider
	sed -i -e 's/ZSH_THEME="\w*"/ZSH_THEME="bira"/g' $HOME/.zshrc

	echo 'source ~/.custom-config' >> $HOME/.zshrc
	echo 'source ~/.custom-aliases' >> $HOME/.zshrc
	echo 'export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"' >> $HOME/.zshrc
	echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm' >> $HOME/.zshrc
	echo 'export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$HOME/.local/bin:$PATH"' >> $HOME/.zshrc
fi

line_divider
echo 'Installing initial packages and tools...'
line_divider
if [ "$pkg_manager" =  "apt" ]; then
    sudo apt update  
elif [ "$pkg_manager" =  "dnf" ]; then
	sudo dnf install https://rpms.remirepo.net/fedora/remi-release-$(cut -d ' ' -f 3 /etc/fedora-release).rpm
	sudo dnf config-manager --set-enabled remi
    sudo dnf check-update
fi

# sudo apt update && sudo apt install nginx redis-server mariadb-server postgresql postgresql-contrib -y
# have commented this out as I have started using docker containers for most of my dev tools

line_divider
read -q "response?Install php8.2? [Y/n] "
echo
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
	echo 'Installing php8.2...'
	if [ "$pkg_manager" =  "apt" ]; then		
		sudo add-apt-repository -r ppa:ondrej/php
		sudo apt update
		sudo $pkg_manager install php8.2 php8.2-fpm php8.2-common php8.2-mbstring php8.2-xmlrpc php8.2-soap php8.2-gd php8.2-xml php8.2-intl php8.2-mysql php8.2-pgsql php8.2-cli php8.2-zip php8.2-curl php8.2-bcmath -y
	elif [ "$pkg_manager" =  "dnf" ]; then
		sudo $pkg_manager install php82 php82-php-fpm php82-php-common php82-php-mbstring php82-php-xmlrpc php82-php-soap php82-php-gd php82-php-xml php82-php-intl php82-php-mysql php82-php-mysqlnd php82-php-pgsql php82-php-cli php82-php-zip php82-php-curl php82-php-bcmath php82-php-opcache -y
		sudo update-alternatives --install /usr/bin/php php /usr/bin/php82 100
		sudo update-alternatives --set php /usr/bin/php82
	fi	
fi

line_divider
read -q "response?Install docker? [Y/n] "
echo
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
	echo 'Installing docker engine...'
	if [ "$pkg_manager" =  "apt" ]; then
		sudo install -m 0755 -d /etc/apt/keyrings
		curl -fsSL https://download.docker.com/linux/$ID/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
		sudo chmod a+r /etc/apt/keyrings/docker.gpg
		echo \
		"deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$ID \
			"$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |
		sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
		sudo apt update  
	elif [ "$pkg_manager" =  "dnf" ]; then
		sudo dnf config-manager --add-repo https://download.docker.com/linux/$ID/docker-ce.repo
		sudo dnf check-update
	fi
	sudo $pkg_manager install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
	
	# configure docker group and permissions for current user
	sudo groupadd docker
	sudo usermod -aG docker $USER
	mkdir -p "$HOME/.docker"
	sudo chown "$USER":"$USER" "$HOME/.docker" -R
	sudo chmod g+rwx "$HOME/.docker" -R
fi

line_divider
read -q "response?Install nvm and nodejs? [Y/n] "
echo
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
	echo "Installing nvm and node..."
	git clone https://github.com/nvm-sh/nvm.git "$HOME/.nvm"
		
	source ~/.zshrc
	exec zsh

	nvm install 18 && \
	npm i -g yarn serve lt pnpm && \
	nvm alias default 18
fi

line_divider
read -q "response?Install aws-cli? [Y/n] "
echo
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
	echo 'Installing aws-cli...'
	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
	unzip -u awscliv2.zip
	sudo ./aws/install
	rm -rf ./aws ./awscliv2.zip
fi

line_divider
read -q "response?Install openvpn3? [Y/n] "
echo
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
	echo 'Installing openvpn3...'
	if [ "$pkg_manager" =  "apt" ]; then	    
		sudo wget https://swupdate.openvpn.net/repos/openvpn-repo-pkg-key.pub
		sudo apt-key add openvpn-repo-pkg-key.pub && rm -rf openvpn-repo-pkg-key.pub
		sudo wget -O /etc/apt/sources.list.d/openvpn3.list https://swupdate.openvpn.net/community/openvpn3/repos/openvpn3-$DISTRO.list
		sudo apt update
	elif [ "$pkg_manager" =  "dnf" ]; then
	    sudo rpm --import https://swupdate.openvpn.net/repos/openvpn-repo-pkg-key.pub
    	sudo dnf config-manager --add-repo=https://swupdate.openvpn.net/community/openvpn3/repos/openvpn3-$(. /etc/os-release && echo "$VERSION_ID").repo
    	sudo dnf check-update
	fi
	sudo $pkg_manager install openvpn3
fi

line_divider
read -q "response?Install additional tools(p3x-onenote robo3t-snap ngrok slack google-chat-electron signal etc...)? [Y/n] "
echo
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
	echo 'Installing additional tools...'
	sudo $pkg_manager install snapd
	sudo ln -s /var/lib/snapd/snap /snap

	sleep 10s
	source ~/.zshrc
	exec zsh

	sudo snap install p3x-onenote ngrok google-chat-electron notion-snap-reborn
fi

line_divider
read -q "response?Install flatpak tools? [Y/n] "
echo
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
	echo 'Installing flatpak tools...'
	flatpak install flathub org.videolan.VLC com.brave.Browser com.google.Chrome com.slack.Slack com.spotify.Client com.adobe.Reader org.gimp.GIMP us.zoom.Zoom com.github.IsmaelMartinez.teams_for_linux com.github.hluk.copyq rest.insomnia.Insomnia fr.handbrake.ghb io.dbeaver.DBeaverCommunity com.sublimetext.three com.jgraph.drawio.desktop -y 
fi
