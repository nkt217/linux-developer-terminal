# Supported platforms

I have tested these scripts on `Ubuntu, Debian, Fedora and CentOS` on VMs as well as actual machines.

# Tools I install
* zsh and oh-my-zsh 
* Essential build & developer tools
* Flatpak & Flathub, and Gnome utils
* PHP
* Docker
* NVM and Nodejs
* OpenVPN3
* AWS CLI
* 

# First time setup

### Fork and Clone the repo
* `git clone https://github.com/nkt217/linux-developer-terminal.git ~/terminal-setup`

### Setup ssh keys
`ssh-keygen -t ed25519 -C "your_email@example.com"`

> Note: If you are using a legacy system that doesn't support the Ed25519 algorithm, use: <br>
>`ssh-keygen -t rsa -b 4096 -C "your_email@example.com"`

_When generating the ssh key add the path as ~/terminal-setup/ssh-keys. The reason I do this so whenever I have to set this up on a different system I don't need to re-setup my ssh key on all the platforms where I have already set this up like Github, Gitlab, Bitbucket, Dev VMs etc._

### Make changes to `terminal-setup/.custom-aliases`
This file contains the command aliases I use generally to increase my productivity during work. You can add/remove aliases from the file. I will generally have aliases for common project repos, ssh commands for my dev VMs etc.

### Make changes to `terminal-setup/.custom-config`
This file contains the custom configurations and ENV variables that I might need on my machine which I generally have to setup everytime I use a new machine.

### Make changes to `terminal-setup/scripts/1.install-shell.sh`
This file will install essential utilities, and `oh-my-zsh`.

Changes that you should make on this file:
1. `base_dir` - This is added incase you have to do this on a VM with external storage mounted. Don't change this if you want to setup everything in the `$HOME`(default) directory itself.
2. Make changes to the git global config settings. 

### Make changes to `terminal-setup/scripts/2.install-dev-tools.sh`
This file will install developer tools like php, docker, nvm & nodejs, and some essentials softwares from flatpak.
You can add/remove tools that you use in your day-to-day work

### Make changes to `terminal-setup/scripts/3.setup-code.sh`
Here you can organize your code structure and clone repositories

### Make changes to `terminal-setup/devops/docker-compose.yaml`
You can configure docker container for tools like jenkins, mariadb, postgres, redis etc. 

To start the services just run `docker compose up -d`
To stop the services just run `docker compose down`

### Finalize
Commit the changes and push into your own repository.

# On another computer
Once you have setup your scripts, anytime you need to spawn up a new developer environment either on a new VM or a new machine all you need to do is:
```
1. Clone the repository. Ex: `sudo apt install git -y&& git clone <git-url>/linux-developer-terminal.git  ~/terminal-setup`
2. Run `terminal-setup/scripts/1.install-shell.sh` and follow the instructions and prompts
3. Run `terminal-setup/scripts/2.install-dev-tools.sh` and follow the instructions and prompts
4. Run `terminal-setup/scripts/3.setup-code.sh` 
5. Run `cd terminal-setup/devops && docker compose up -d` to start the developer tools
6. Logout and Login again for things to work smoothly
```

And, your developer environment will be up within minutes.
