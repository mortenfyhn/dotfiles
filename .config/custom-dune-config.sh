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

imc_update () {
  python $IMC_PATH/user/update.py build
  make -C $IMC_PATH
  ninja -C $BUILD_PATH imc
}

imc_build () {
  python $IMC_PATH/user/update.py

  if [ -n "$(git -c $IMC_PATH status --porcelain)" ]; then
    echo "IMC repo is dirty!"
    return 1
  fi

  cmake $DUNE_PATH -DIMC_URL=$IMC_PATH -DIMC_TAG=uavlab $BUILD_PATH

  ninja -C $BUILD_PATH imc_download
  ninja -C $BUILD_PATH imc
  ninja -C $BUILD_PATH

  # Build imcjava
  cwd=$PWD
  cd $IMCJAVA_PATH
  ant -q -Dimc.dir=$IMC_PATH
  cd $cwd

  # Copy java imc definitions to neptus
  cp $IMCJAVA_PATH/dist/libimc.jar $NEPTUS_PATH/lib/libimc.jar

  # Build neptus
  cwd=$PWD
  cd $NEPTUS_PATH
  ant -q
  cd $cwd
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
  ninja -C $TBUILD_PATH
  ret=$?; if [ $ret -ne 0 ]; then; return $ret; fi

  rsync -avz --human-readable --progress $TBUILD_PATH/dune target:/opt/scout/dune/bin/
  ret=$?; if [ $ret -ne 0 ]; then; return $ret; fi

  rsync -avzr $DUNE_PATH/user/etc/  target:/opt/scout/dune/user/etc
  ret=$?; if [ $ret -ne 0 ]; then; return $ret; fi
}

dune_gdb () {
  $GLUED_PATH/ntnu-b2xx/toolchain/bin/armv7-lsts-linux-gnueabihf-gdb -q ~/dune/tbuild/dune
}

dune_copy_logs () {
  rsync -avzr --human-readable --progress target:/opt/scout/dune/log/ntnu-hexa-002/ $HOME/Desktop/logs/
}

dune_replay_log () {
  if [ $# -eq 1 ]; then; $BUILD_PATH/dune-sendmsg localhost 6002 ReplayControl 0 $1; fi
  if [ $# -eq 2 ]; then; $BUILD_PATH/dune-sendmsg localhost $2 ReplayControl 0 $1; fi
}
