# Vivaldi browser
# https://help.vivaldi.com/article/manual-setup-vivaldi-linux-repositories/
wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | sudo apt-key add -
sudo add-apt-repository 'deb https://repo.vivaldi.com/archive/deb/ stable main'

# Sublime Text
# https://www.sublimetext.com/docs/3/linux_repositories.html
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

# Standard packages
sudo apt update
sudo apt upgrade -y
sudo apt-get install -y \
    apt-transport-https \
    build-essential \
    ccache \
    clang \
    cmake \
    cmake-curses-gui \
    gdb \
    git \
    htop \
    lldb \
    minicom \
    mosh \
    neofetch \
    ninja-build \
    nmap \
    python-pip \
    python3-pip \
    shellcheck \
    sublime-text \
    trash-cli \
    tree \
    vivaldi-stable \
    xclip \
    zsh \

# ccache
sudo /usr/sbin/update-ccache-symlinks

# oh-my-zsh
# https://ohmyz.sh/#install
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# oh-my-zsh: Bullet Train theme
# https://github.com/caiogondim/bullet-train.zsh#for-oh-my-zsh-users
wget -q -O "$ZSH_CUSTOM/themes/bullet-train.zsh-theme" https://raw.githubusercontent.com/caiogondim/bullet-train.zsh/master/bullet-train.zsh-theme

# oh-my-zsh: zsh-256color plugin
# https://github.com/chrissicool/zsh-256color#oh-my-zsh
git clone -q git@github.com:chrissicool/zsh-256color "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-256color"

# oh-my-zsh: thefuck plugin
# https://github.com/nvbn/thefuck#installation
pip3 install thefuck

# Powerline fonts
# https://github.com/powerline/fonts#quick-installation
git clone -q git@github.com:powerline/fonts.git --depth=1 /tmp/fonts
/tmp/fonts/install.sh
