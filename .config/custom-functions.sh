extract () {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2) tar xjf    $1 ;;
      *.tar.gz)  tar xzf    $1 ;;
      *.bz2)     bunzip2    $1 ;;
      *.rar)     rar x      $1 ;;
      *.gz)      gunzip     $1 ;;
      *.tar)     tar xf     $1 ;;
      *.tbz2)    tar xjf    $1 ;;
      *.tgz)     tar xzf    $1 ;;
      *.zip)     unzip      $1 ;;
      *.Z)       uncompress $1 ;;
      *)         echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

myinstalls () {
  comm -23 \
  <(apt-mark showmanual | sort -u) \
  <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u)
}

myrepos () {
  for APT in `find /etc/apt/ -name \*.list`; do
    grep -o "^deb http://ppa.launchpad.net/[a-z0-9\-]\+/[a-z0-9\-]\+" $APT | while read ENTRY ; do
      USER=`echo $ENTRY | cut -d/ -f4`
      PPA=`echo $ENTRY | cut -d/ -f5`
      echo sudo apt-add-repository ppa:$USER/$PPA
    done
  done
}

find_in_path () {
  if echo "$PATH" | grep -q $1; then
    return 0
  else
    return 1
  fi
}

conda_toggle () {
  if find_in_path 'conda'; then
    export PATH=$PATH_ORIGINAL
    echo Removed conda from path.
  else
    export PATH=$PATH_WITH_CONDA
    echo Added conda to path.
  fi
}
