WORKSPACE="$HOME/workspace"

TARGET_IP=10.0.62.105
DUNE_PATH="$WORKSPACE/dune"
INSTALL_PATH="$WORKSPACE/install"
IMC_PATH="$WORKSPACE/imc"
IMCJAVA_PATH="$WORKSPACE/imcjava"
NEPTUS_PATH="$WORKSPACE/neptus"
BUILD_PATH="$WORKSPACE/build"
TBUILD_PATH="$WORKSPACE/tbuild"
GLUED_PATH="$WORKSPACE/glued"
PYIMC_PATH="$WORKSPACE/pyimc"
ROS_IMC_BROKER_PATH="$HOME/catkin_ws/src/ros-imc-broker"



alias cmake_tbuild="cmake -G Ninja -DCROSS=$GLUED_PATH/ntnu-b2xx/toolchain/bin/armv7-lsts-linux-gnueabihf $DUNE_PATH"

alias dune_kill="ssh root@$TARGET_IP 'killall -9 dune'"
alias dune_create_task_user2="python $DUNE_PATH/programs/scripts/dune-create-task.py $DUNE_PATH/user2 \"Morten Fyhn Amundsen\""
alias totarget="ssh root@$TARGET_IP"
alias neptus="$NEPTUS_PATH/neptus.sh"



target_setup () {
  ssh root@$TARGET_IP 'mount -o remount,rw /'
  # cat ~/.ssh/id_rsa.pub | ssh root@$TARGET_IP 'cat >> .ssh/authorized_keys'  # TODO: use ssh-copy-id
  ssh root@$TARGET_IP 'echo "alias dune=/opt/lsts/dune/bin/dune" >> /etc/profile'
  ssh root@$TARGET_IP 'echo "alias l=ls" >> /etc/profile'
  ssh root@$TARGET_IP 'echo "alias radar='dune -c dev/x4radar -p Hardware'" >> /etc/profile'
  ssh root@$TARGET_IP 'mount -o remount,ro /'
}

dune_build () {
  ninja -C $BUILD_PATH
}

dune_tbuild () {
  ninja -C $TBUILD_PATH
}

dune_rebuild () {
  ninja -C $BUILD_PATH rebuild_cache
  ninja -C $BUILD_PATH
}

imc_update () {
  python $IMC_PATH/user/update.py build
  make -C $IMC_PATH
  ninja -C $BUILD_PATH imc
}

imc_build () {
  python $IMC_PATH/user/update.py

  cwd=$PWD
  cd $IMC_PATH
  if [ -n "$(git status --porcelain)" ]; then
    echo "IMC repo is dirty!"
    cd $cwd
    return 1
  fi
  cd $cwd

  cmake $DUNE_PATH -DIMC_URL=$IMC_PATH -DIMC_TAG=uavlab $BUILD_PATH

  ninja -C $BUILD_PATH imc_download
  ninja -C $BUILD_PATH imc
  ninja -C $BUILD_PATH

  imcjava_build
  cp $IMCJAVA_PATH/dist/libimc.jar $NEPTUS_PATH/lib/libimc.jar
  neptus_build
}

imcjava_build () {
  cwd=$PWD
  cd $IMCJAVA_PATH
  ant -q -Dimc.dir=$IMC_PATH
  cd $cwd
}

neptus_build () {
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

# doesn't cd back to pwd if build fails
dune_upload_full () {
  ninja -C $TBUILD_PATH
  ret=$?
  if [ $ret -ne 0 ]; then; errorbeep; return $ret; fi

  ninja -C $TBUILD_PATH package
  ret=$?
  if [ $ret -ne 0 ]; then; errorbeep; return $ret; fi

  rsync -avz --human-readable --progress $TBUILD_PATH/dune-**-*tar.bz2 root@$TARGET_IP:/opt/lsts/dune/
  ret=$?
  if [ $ret -ne 0 ]; then; errorbeep; return $ret; fi

  ssh root@$TARGET_IP '/sbin/services dune restart; /sbin/services dune stop'
  # ret=$?
  # if [ $ret -ne 0 ]; then; errorbeep; cd $cwd; return $ret; fi

  successbeep
  return 0
}

dune_upload_quick () {
  ninja -C $TBUILD_PATH
  ret=$?
  if [ $ret -ne 0 ]; then; errorbeep; return $ret; fi

  $GLUED_PATH/ntnu-b2xx/toolchain/bin/armv7-lsts-linux-gnueabihf-strip dune
  if [ $ret -ne 0 ]; then; errorbeep; return $ret; fi

  rsync -avz --human-readable --progress $TBUILD_PATH/dune root@$TARGET_IP:/opt/lsts/dune/bin/
  ret=$?
  if [ $ret -ne 0 ]; then; errorbeep; return $ret; fi

  dune_upload_user_ini

  successbeep
  return 0
}

dune_upload_user_ini () {
  rsync -avzr $DUNE_PATH/user/etc/  root@$TARGET_IP:/opt/lsts/dune/user/etc
  rsync -avzr $DUNE_PATH/user2/etc/ root@$TARGET_IP:/opt/lsts/dune/user2/etc
}

dune_gdb () {
  $GLUED_PATH/ntnu-b2xx/toolchain/bin/armv7-lsts-linux-gnueabihf-gdb -q ~/dune/tbuild/dune
}

dune_copy_logs () {
  rsync -avzr --human-readable --progress root@$TARGET_IP:/opt/lsts/dune/log/ntnu-hexa-002/ $HOME/Desktop/logs/
}

dune_replay_log () {
  if [ $# -eq 1 ]; then; $BUILD_PATH/dune-sendmsg localhost 6002 ReplayControl 0 $1; fi
  if [ $# -eq 2 ]; then; $BUILD_PATH/dune-sendmsg localhost $2 ReplayControl 0 $1; fi
}
