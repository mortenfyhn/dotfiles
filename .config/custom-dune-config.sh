alias dune="$BUILD_PATH/dune"
alias dune_kill="ssh target 'killall -9 dune'"
alias dune_create_task_user2="python $DUNE_PATH/programs/scripts/dune-create-task.py $DUNE_PATH/user2 \"Morten Fyhn Amundsen\""
alias neptus="$NEPTUS_PATH/neptus.sh"

dune_build () {
  ninja -C $BUILD_PATH
}
alias db=dune_build

dune_tbuild () {
  ninja -C $TBUILD_PATH
}
alias dt=dune_tbuild

dune_rebuild () {
  ninja -C $BUILD_PATH rebuild_cache
  ninja -C $BUILD_PATH
}
alias dr=dune_rebuild

imc_build_dune () {
    boldecho "Verifying clean IMC repo..."
  python $IMC_PATH/user/update.py
  if [ -n "$(git -C $IMC_PATH status --porcelain)" ]; then
    tput setaf 1; boldecho "Dirty IMC repo!"; tput sgr0
    return 1
  else
    echo "Clean IMC repo"
  fi

  boldecho "Verifying IMC definitions..."
  if ! make -C $IMC_PATH --no-print-directory; then
    tput setaf 1; boldecho "Invalid IMC definitions!"; tput sgr0
    return 1
  else
    echo "Valid IMC definitions"
  fi

  boldecho "Updating DUNE IMC definitions..."
  imc_branch=$(git -C $IMC_PATH rev-parse --abbrev-ref HEAD)
  cmake $DUNE_PATH -DIMC_URL=$IMC_PATH -DIMC_TAG=$imc_branch $BUILD_PATH
  ninja -C $BUILD_PATH imc_download
  ninja -C $BUILD_PATH imc

  boldecho "Building DUNE..."
  ninja -C $BUILD_PATH
}

imc_build_neptus () {
  # Build imcjava
  boldecho "Generating JAVA IMC definitions..."
  cwd=$PWD
  cd $IMCJAVA_PATH
  ant -q -Dimc.dir=$IMC_PATH
  cd $cwd

  boldecho "Updating Neptus IMC definitions..."
  cp $IMCJAVA_PATH/dist/libimc.jar $NEPTUS_PATH/lib/libimc.jar

  boldecho "Building Neptus..."
  cwd=$PWD
  cd $NEPTUS_PATH
  ant -q
  cd $cwd
}

imc_build () {
  imc_build_dune
  imc_build_neptus
}

pyimc_build () {
  python $IMC_PATH/user/update.py
  python3 $PYIMC_PATH/setup.py install
}

imc_broker_update () {
  # Update ROS IMC broker ImcTypes.hpp
  cwd=$PWD
  if [ -z ${ROS_IMC_BROKER_PATH+x} ]; then
    return 0
  else
    cd $ROS_IMC_BROKER_PATH/workspace/translator
    python imc-translator.py -x $IMC_PATH/IMC.xml -o $ROS_IMC_BROKER_PATH/workspace/src/ros_imc_broker/include/ros_imc_broker/ImcTypes.hpp
    echo "Updated ros_imc_broker/ImcTypes.hpp!"
  fi
  cd $cwd
}

dune_upload_full () {
  boldecho "building..."
  ninja rebuild_cache -C $TBUILD_PATH
  ninja -C $TBUILD_PATH
  ret=$?; if [ $ret -ne 0 ]; then; return $ret; fi

  boldecho "\npackaging..."
  ninja -C $TBUILD_PATH package
  ret=$?; if [ $ret -ne 0 ]; then; return $ret; fi

  boldecho "\ntransferring..."
  rsync -avz --human-readable --progress $TBUILD_PATH/dune-**-*tar.bz2 target:/opt/scout/dune/
  ret=$?; if [ $ret -ne 0 ]; then; return $ret; fi

  boldecho "\nupgrading..."
  ssh target /usr/bin/dune_upgrade.sh
}

dune_upload_quick () {
  ninja rebuild_cache -C $TBUILD_PATH
  ninja -C $TBUILD_PATH
  ret=$?; if [ $ret -ne 0 ]; then; return $ret; fi

  rsync -avz --human-readable --progress $TBUILD_PATH/dune target:/opt/scout/dune/bin/
  ret=$?; if [ $ret -ne 0 ]; then; return $ret; fi

  rsync -avzr $DUNE_PATH/user/etc/ target:/opt/scout/dune/user/etc
  ret=$?; if [ $ret -ne 0 ]; then; return $ret; fi
}

dune_upload_full_debug () {
  boldecho "building..."
  ninja rebuild_cache -C $TDBUILD_PATH
  ninja -C $TDBUILD_PATH
  ret=$?; if [ $ret -ne 0 ]; then; return $ret; fi

  boldecho "\npackaging..."
  ninja -C $TDBUILD_PATH package
  ret=$?; if [ $ret -ne 0 ]; then; return $ret; fi

  boldecho "\ntransferring..."
  rsync -avz --human-readable --progress $TDBUILD_PATH/dune-**-*tar.bz2 target:/opt/scout/dune/
  ret=$?; if [ $ret -ne 0 ]; then; return $ret; fi

  boldecho "\nupgrading..."
  ssh target /usr/bin/dune_upgrade.sh
}

dune_upload_quick_debug () {
  ninja -C $TDBUILD_PATH
  ret=$?; if [ $ret -ne 0 ]; then; return $ret; fi

  rsync -avz --human-readable --progress $TDBUILD_PATH/dune target:/opt/scout/dune/bin/
  ret=$?; if [ $ret -ne 0 ]; then; return $ret; fi

  rsync -avzr $DUNE_PATH/user/etc/ target:/opt/scout/dune/user/etc
  ret=$?; if [ $ret -ne 0 ]; then; return $ret; fi
}

dune_gdb () {
  $GLUED_PATH/ntnu-b2xx/toolchain/bin/armv7-lsts-linux-gnueabihf-gdb -q ~/dune/tbuild/dune
}

dune_copy_logs () {
  rsync -avzr --human-readable --progress target:/opt/scout/dune/log/ $HOME/Desktop/log/
}

dune_replay_log () {
  if [ $# -eq 1 ]; then; $BUILD_PATH/dune-sendmsg localhost 6002 ReplayControl 0 $1; fi
  if [ $# -eq 2 ]; then; $BUILD_PATH/dune-sendmsg localhost $2 ReplayControl 0 $1; fi
}

tail_log () {
  ssh root@target 'journalctl -f --no-tail --output cat'
}

target_start_dune () {
  ssh root@target 'systemctl start dune'
}

target_stop_dune () {
  ssh root@target 'systemctl stop dune'
}

target_restart_dune () {
  ssh root@target 'systemctl restart dune'
}
