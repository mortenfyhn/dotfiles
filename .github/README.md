# dotfiles

[![ShellCheck](https://github.com/mortenfyhn/dotfiles/workflows/ShellCheck/badge.svg)](https://github.com/mortenfyhn/dotfiles/actions/workflows/main.yml)

My dotfiles and other computer setup stuff. Based on [this](https://www.atlassian.com/git/tutorials/dotfiles).

### Prerequisites

* [Connect to GitHub with SSH](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
* Install `wget`

### Desktop install

Both installs use the same [install.sh](https://github.com/mortenfyhn/dotfiles/blob/master/.config/dotfiles/install.sh) script.

For a graphical desktop install, run:

```sh
bash <(wget -qO- -o /dev/null \
  https://raw.githubusercontent.com/mortenfyhn/dotfiles/master/.config/dotfiles/install.sh)
```

### Headless install

For a headless install, run:

```sh
bash <(wget -qO- -o \
  /dev/null https://raw.githubusercontent.com/mortenfyhn/dotfiles/master/.config/dotfiles/install.sh) \
  --headless
```

### Run local install script

If you are hacking the install script and want to run the local version:

```sh
~/.config/dotfiles/install.sh
```

or

```sh
~/.config/dotfiles/install.sh --headless
```
