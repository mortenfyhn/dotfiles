#!/usr/bin/env bash

set -Eeuo pipefail

yellow() { echo -e "\e[33m$*\e[0m"; }
bold() { echo -e "\e[1m$*\e[0m"; }
bold_green() { echo -e "\e[1;32m$*\e[0m"; }
bold_blue() { echo -e "\e[1;36m$*\e[0m"; }

# Install a single binary from a release tarball, for tools the distros package
# too old or not at all
install_release_binary() {
    local command_name="$1" version="$2" url="$3"
    bold_blue "Installing $command_name"
    if command -v "$command_name" >/dev/null &&
        # Stderr hidden: an installed-but-unrunnable binary is noisy (issue #89)
        [[ $("$command_name" --version 2>/dev/null | awk 'NR==1 {print $2}') == "$version" ]]; then
        echo "Already installed ${version}"
        return
    fi
    if [[ $(uname -m) != "x86_64" ]]; then
        yellow "Skipping: no release build for $(uname -m)"
        return
    fi
    pushd "$(mktemp --directory)" >/dev/null
    wget -q "$url"
    tar -xzf ./*.tar.gz
    mkdir -p ~/.local/bin
    mv "$command_name" ~/.local/bin/
    popd >/dev/null
    echo "Done"
}

# Grant sudo right away
sudo -v
echo "Sudo granted"

bold_blue "Installing applications"
core_packages=(bat ccache git jq tree zsh zoxide curl tmux trash-cli unzip shellcheck shfmt diffutils sublime-text)
if command -v apt-get >/dev/null; then # Ubuntu
    # add-apt-repository is missing on minimal installs
    sudo apt-get --quiet --quiet update
    sudo apt-get --quiet --quiet install software-properties-common
    sudo add-apt-repository --yes --no-update ppa:git-core/ppa
    # Add the Sublime Text repository
    wget -qO- https://download.sublimetext.com/sublimehq-pub.gpg |
        sudo tee /etc/apt/keyrings/sublimehq-pub.asc >/dev/null
    printf 'Types: deb\nURIs: https://download.sublimetext.com/\nSuites: apt/stable/\nSigned-By: /etc/apt/keyrings/sublimehq-pub.asc\n' |
        sudo tee /etc/apt/sources.list.d/sublime-text.sources >/dev/null
    sudo apt-get --quiet --quiet update
    sudo apt-get --quiet --quiet install "${core_packages[@]}"
    # Not in every release I use, so this is allowed to fail
    sudo apt-get --quiet --quiet install alacritty neofetch gnome-shell-extensions ||
        yellow "Skipped desktop packages"
    # Route x-terminal-emulator consumers to Alacritty (Debian/Ubuntu only)
    if command -v alacritty >/dev/null; then
        sudo update-alternatives --set x-terminal-emulator /usr/bin/alacritty
    fi
elif command -v dnf >/dev/null; then # Fedora
    # Add the Sublime Text repository. dnf imports its key on the first install.
    sudo wget -qO /etc/yum.repos.d/sublime-text.repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
    sudo dnf --assumeyes --quiet install "${core_packages[@]}"
    sudo dnf --assumeyes --quiet install alacritty || yellow "Skipped alacritty"
else
    echo "I only support apt and dnf"
    exit 1
fi

# Clone dotfiles
bold_blue "Cloning dotfiles repo"
if [[ ! -d ~/.dotfiles ]]; then
    # Clone over HTTPS so it works without an SSH key, push over SSH
    git clone -q --bare https://github.com/mortenfyhn/dotfiles.git ~/.dotfiles
    dots() { git --git-dir="$HOME"/.dotfiles/ --work-tree="$HOME" "$@"; }
    dots remote set-url --push origin git@github.com:mortenfyhn/dotfiles.git
    dots checkout --force
    dots config --local status.showUntrackedFiles no
    dots config --local --add remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
    dots fetch
fi
# Run the CI checks locally before every push
printf '#!/bin/sh\nexec ~/.dotfiles-check.sh\n' >~/.dotfiles/hooks/pre-push
chmod +x ~/.dotfiles/hooks/pre-push
echo "Done"

bold_blue "Configure git"
git config --global user.name "Morten Fyhn Amundsen"
git config --global merge.conflictStyle zdiff3
git config --global fetch.prune true
git config --global pull.ff only
git config --global help.autocorrect 20
git config --global init.defaultBranch master
git config --global core.editor "subl -n -w"
echo "Done"

# Install Iosevka font (for my editor)
bold_blue "Installing Iosevka font"
if [[ -f ~/.local/share/fonts/Iosevka.ttc ]]; then
    echo "Already installed"
else
    pushd "$(mktemp --directory)" >/dev/null
    wget -q https://github.com/be5invis/Iosevka/releases/download/v33.2.3/SuperTTC-Iosevka-33.2.3.zip -O Iosevka.zip
    unzip Iosevka.zip
    mkdir -p ~/.local/share/fonts
    mv Iosevka.ttc ~/.local/share/fonts
    fc-cache -f
    popd >/dev/null
fi

difft_version="0.67.0"
install_release_binary difft "$difft_version" \
    "https://github.com/Wilfred/difftastic/releases/download/${difft_version}/difft-x86_64-unknown-linux-gnu.tar.gz"
if difft --version &>/dev/null; then
    git config --global diff.external difft
else
    # See https://github.com/mortenfyhn/dotfiles/issues/89
    git config unset --global diff.external || :
fi

bold_blue "Installing other tools"
if ! command -v emoji >/dev/null; then
    wget -q https://codeberg.org/EvanHahn/dotfiles/raw/commit/6af71a8aebe18656b575ab0d7b9b7e5c47d39998/home/bin/bin/emoji -O ~/.local/bin/emoji
    chmod +x ~/.local/bin/emoji
fi
echo "Done"

# Logitech MX Keys Mini (YR0084) sends Super+Shift+O for its screenshot key
# instead of Print, even with "Set OS: Linux" in Solaar
bold_blue "Configuring screenshot shortcut"
if [[ "${XDG_CURRENT_DESKTOP:-}" != *"GNOME"* ]]; then
    yellow "Skipping (not GNOME). Screenshot shortcut may need manual setup."
else
    gsettings set org.gnome.shell.keybindings show-screenshot-ui "['Print', '<Super><Shift>o']"
    echo "Done"
fi

# Configure GNOME
# automount-open pops open a Files window every time removable media (e.g. my
# phone's storage) is plugged in. Keep automount so devices still mount, but
# don't open a window.
if [[ "${XDG_CURRENT_DESKTOP:-}" == *"GNOME"* ]]; then
    bold_blue "Configuring GNOME"
    gsettings set org.gnome.desktop.media-handling automount-open false
    # Caps Lock is AltGr. AltGr+Space gives a usual space, not a non-breaking
    # space.
    gsettings set org.gnome.desktop.input-sources xkb-options "['lv3:caps_switch', 'nbsp:none']"
    echo "Done"
fi

# Make Alacritty the default terminal
bold_blue "Setting Alacritty as default terminal"
if [[ "${XDG_CURRENT_DESKTOP:-}" != *"GNOME"* ]]; then
    yellow "Skipping (not GNOME)."
else
    # For legacy apps that read the (deprecated) gsettings key
    gsettings set org.gnome.desktop.default-applications.terminal exec 'alacritty'
    gsettings set org.gnome.desktop.default-applications.terminal exec-arg '-e'

    # For "Open in Terminal" etc. (xdg-terminal-exec spec, GNOME 48+)
    echo "Alacritty.desktop" >~/.config/xdg-terminals.list

    # Ctrl+Alt+T: GNOME has no built-in terminal shortcut, so add a
    # custom keybinding (idempotent — reuses a fixed dconf path)
    kb="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/alacritty/"
    schema="org.gnome.settings-daemon.plugins.media-keys"
    list=$(gsettings get "$schema" custom-keybindings)
    if [[ "$list" != *"$kb"* ]]; then
        if [[ "$list" == "@as []" ]]; then
            gsettings set "$schema" custom-keybindings "['$kb']"
        else
            gsettings set "$schema" custom-keybindings "${list%]}, '$kb']"
        fi
    fi
    kb_schema="$schema.custom-keybinding:$kb"
    gsettings set "$kb_schema" name 'Terminal'
    gsettings set "$kb_schema" command 'alacritty'
    gsettings set "$kb_schema" binding '<Control><Alt>t'
    echo "Done"
fi

bold_blue "Configuring Claude Code"
settings=~/.claude/settings.json
[[ -f $settings ]] || echo '{}' >"$settings"
jq '.statusLine = {type: "command", command: "bash ~/.claude/statusline-command.sh"}' "$settings" >"$settings.tmp"
mv "$settings.tmp" "$settings"
echo "Done"

# Install ZSH prompt (pure)
bold_blue "Installing 'Pure' prompt"
mkdir -p "$HOME/.zsh"
if [[ -d "$HOME/.zsh/pure" ]]; then
    echo "Already installed"
else
    git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
    echo "Done"
fi

# Install zsh-autosuggestions
bold_blue "Installing zsh-autosuggestions"
if [[ -d "$HOME/.zsh/zsh-autosuggestions" ]]; then
    echo "Already installed"
else
    git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.zsh/zsh-autosuggestions"
    echo "Done"
fi

# Make ZSH the default shell
bold_blue "Make ZSH default shell"
need_relog=false
if [[ "${SHELL:-}" == "/usr/bin/zsh" ]]; then
    echo "Default shell is already ZSH"
elif [[ -n "${CI:-}" ]]; then
    echo "Running in CI, skipping"
else
    chsh -s "$(command -v zsh)"
    need_relog=true
fi
echo "Done"

bold_green "All done!"
if [[ $need_relog == true ]]; then
    bold "Log out and back in again."
fi
if command -v dnf >/dev/null; then # Fedora
    echo "Manual UI setup: https://github.com/mortenfyhn/dotfiles/issues/83"
fi
