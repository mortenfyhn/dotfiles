#!/usr/bin/env bash

set -Eeuo pipefail
shopt -s expand_aliases

# Echo bold text (green)
bold() {
    echo -e "\e[1;32m$*\e[0m"
}

headless=false
while [[ $# -gt 0 ]]
do
    case "$1" in
        --headless)
            headless=true
            shift
            ;;
    esac
done

if [[ "$headless" = false ]]
then
    # Add Vivaldi repo
    # https://help.vivaldi.com/desktop/install-update/manual-setup-vivaldi-linux-repositories/
    bold "Adding Vivaldi repository"
    wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | gpg --dearmor | sudo dd of=/usr/share/keyrings/vivaldi-browser.gpg
    echo "deb [signed-by=/usr/share/keyrings/vivaldi-browser.gpg arch=$(dpkg --print-architecture)] https://repo.vivaldi.com/archive/deb/ stable main" | sudo dd of=/etc/apt/sources.list.d/vivaldi-archive.list

    # Add Sublime Text repo
    # https://www.sublimetext.com/docs/linux_repositories.html
    bold "Adding Sublime Text repository"
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

    # Install Iosevka font (for my editor)
    bold "Installing Iosevka font"
    pushd "$(mktemp --directory)" > /dev/null
    wget -qO iosevka.zip https://github.com/be5invis/Iosevka/releases/download/v16.3.4/super-ttc-iosevka-16.3.4.zip
    unzip iosevka.zip
    mv iosevka.ttc ~/.local/share/fonts
    fc-cache -f
    popd > /dev/null
fi

# Add git repo
bold "Adding git repository"
sudo add-apt-repository -y ppa:git-core/ppa
echo "Done"

# Install system packages
bold "Installing apt packages"
sudo apt-get update -qq
sudo apt-get upgrade -qq
sudo apt-get install -qq \
    apt-transport-https \
    build-essential \
    byobu \
    ccache \
    clang \
    clang-format \
    clang-tidy \
    cloc \
    cmake \
    curl \
    git \
    gparted \
    htop \
    less \
    meld \
    minicom \
    mosh \
    ncdu \
    neofetch \
    ninja-build \
    nmap \
    python3-gpg \
    python3-pip \
    shellcheck \
    silversearcher-ag \
    tldr \
    trash-cli \
    tree \
    unzip \
    wget \
    xclip \
    zsh
if [[ "$headless" = false ]]
then
    sudo apt-get install -qq \
        qbittorrent \
        redshift-gtk \
        sublime-merge \
        sublime-text \
        vivaldi-stable \
        vlc \
        xbacklight
fi
echo "Done"

# Install and configure fd-find
# Do nothing if unavailable
bold "Installing fd-find"
if sudo apt-get install -qq fd-find
then
    mkdir -p ~/.local/bin
    ln --force --symbolic "$(which fdfind)" ~/.local/bin/fd
else
    echo "Cannot install fd-find, continuing..."
fi
echo "Done"

# Install Python packages
bold "Installing Python packages"
pip3 install -q \
    black \
    cmakelang
echo "Done"

# Setup ccache
bold "Setting up ccache"
sudo /usr/sbin/update-ccache-symlinks
echo "Done"

# Setup ZSH with oh-my-zsh
bold "Setting up Oh My Zsh"
if [[ -d ~/.oh-my-zsh ]]
then
    echo "Oh My Zsh already installed"
else
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
echo "Done"

# Set ZSH as default shell
bold "Make ZSH default shell"
if [[ "$SHELL" != "/usr/bin/zsh" && ! -f /.dockerenv ]]; then
    echo "Changing login shell to ZSH..."
    chsh -s "$(command -v zsh)"
fi
echo "Done"

# Setup ZSH themes and plugins
bold "Configuring ZSH"
ZSH_CUSTOM=~/.oh-my-zsh/custom
wget -qO "$ZSH_CUSTOM/themes/bullet-train.zsh-theme" https://raw.githubusercontent.com/caiogondim/bullet-train.zsh/master/bullet-train.zsh-theme
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    git clone --quiet https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-256color" ]]; then
    git clone --quiet https://github.com/chrissicool/zsh-256color.git "$ZSH_CUSTOM/plugins/zsh-256color"
fi
font_dir=$(mktemp -d)
git clone --quiet --depth=1 https://github.com/powerline/fonts.git "$font_dir" && "$font_dir/install.sh"
echo "Done"

# Clone dotfiles
bold "Cloning dotfiles repo"
grep -sqxF ".dotfiles" ~/.gitignore || echo ".dotfiles" >> ~/.gitignore
if [[ ! -d ~/.dotfiles ]]; then
    git clone -q --bare git@github.com:mortenfyhn/dotfiles.git ~/.dotfiles
    dots() { git --git-dir="$HOME"/.dotfiles/ --work-tree="$HOME" "$@"; }
    dots checkout --force
    dots config --local status.showUntrackedFiles no
    dots config --local --add remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
    dots fetch
fi
echo "Done"

# Load dconf settings
bold "Load MATE desktop environment settings"
if command -v dconf > /dev/null
then
    dconf load /org/mate/terminal/profiles/default/ < ~/.config/dotfiles/dconf/mate-terminal
    dconf load /org/mate/marco/window-keybindings/ < ~/.config/dotfiles/dconf/shortcuts
    dconf load /org/mate/desktop/peripherals/keyboard/kbd/ < ~/.config/dotfiles/dconf/keyboard
else
    echo "Cannot find dconf, won't load dconf settings"
fi
echo "Done"

# Remap keyboard
# Note: Patch returns 1 if the patch already has been applied, so I hide the exit code and then check the text output to make this idempotent
bold "Remapping keyboard"
# Patch 1: Remap caps lock to alt gr
if patch_output=$(sudo patch --unified --backup --forward --reject-file=- /usr/share/X11/xkb/symbols/pc --input="$HOME"/.config/dotfiles/remap-caps-lock.patch)
then
    echo "Applied keyboard patch 1"
else
    if echo "$patch_output" | grep -q "Reversed (or previously applied) patch detected!"
    then
        echo "Keyboard patch 1 already applied"
    else
        echo "Failed to apply keyboard patch 1"
        exit 1
    fi
fi
# Patch 2: Don't spit out non-breaking space for alt gr + space (common "mistake" when typing a space after a bracket)
if patch_output=$(sudo patch --unified --backup --forward --reject-file=- /usr/share/X11/xkb/symbols/no --input="$HOME"/.config/dotfiles/non-breaking-space.patch)
then
    echo "Applied keyboard patch 2"
else
    if echo "$patch_output" | grep -q "Reversed (or previously applied) patch detected!"
    then
        echo "Keyboard patch 2 already applied"
    else
        echo "Failed to apply keyboard patch 2"
        exit 1
    fi
fi
echo "Done"

bold "All done! Log out and back in again."
