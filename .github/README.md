# dotfiles

[![Build Status](https://fyhn.semaphoreci.com/badges/dotfiles/branches/master.svg?key=4b5186bf-a18b-48bc-b700-f27055a84f02)](https://fyhn.semaphoreci.com/projects/dotfiles)

My dotfiles and other computer setup stuff. Based on [this](https://www.atlassian.com/git/tutorials/dotfiles).

### Supported operating systems

| OS | Support | Tested |
| --- | --- | --- |
| Fedora, latest release | full | no |
| Ubuntu 24.04 | full | CI, every push |
| Ubuntu 20.04 | `--headless` only, best-effort | no |

Ubuntu 20.04 is only there for a work dev container. It packages neither zoxide
nor alacritty: zoxide is installed from a GitHub release instead, and desktop
packages are only installed without `--headless`.

Plan: run the install in a container per supported OS in CI.

### Prerequisites

* [Connect to GitHub with SSH](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
* Install `wget`

### First install

```sh
bash <(wget -qO- -o /dev/null \
  https://raw.githubusercontent.com/mortenfyhn/dotfiles/master/.dotfiles-install.sh)
```

Append `--headless` when needed.

### Re-install

```sh
~/.dotfiles-install.sh
```

