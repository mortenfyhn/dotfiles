# dotfiles

[![Build Status](https://fyhn.semaphoreci.com/badges/dotfiles/branches/master.svg?key=4b5186bf-a18b-48bc-b700-f27055a84f02)](https://fyhn.semaphoreci.com/projects/dotfiles)

My dotfiles and other computer setup stuff. Based on [this](https://www.atlassian.com/git/tutorials/dotfiles).

### Prerequisites

* [Connect to GitHub with SSH](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
* Install `wget`

### First install

```sh
bash <(wget -qO- -o /dev/null \
  https://raw.githubusercontent.com/mortenfyhn/dotfiles/master/install-dotfiles.sh)
```

Append `--headless` when needed.

### Re-install

```sh
~/install-dotfiles.sh
```

