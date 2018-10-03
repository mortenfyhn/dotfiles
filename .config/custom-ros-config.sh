if [ -e "/opt/ros/kinetic/setup.zsh" ]; then
  source /opt/ros/kinetic/setup.zsh
fi

if [ -e "/opt/ros/melodic/setup.zsh" ]; then
  source /opt/ros/melodic/setup.zsh
fi

if [ -e "$CATKIN_WS/devel/setup.zsh" ]; then
  source $CATKIN_WS/devel/setup.zsh
fi

ros_build () {
  disable_conda
  catkin_make \
    --directory $CATKIN_WS \
    --use-ninja \
    --cmake-args \
      -Wno-dev \
      -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
      -DCMAKE_CXX_FLAGS=-fdiagnostics-color=always
  source $CATKIN_WS/devel/setup.zsh
}

ros_clean () {
  disable_conda
  catkin_make clean \
    --directory $CATKIN_WS \
    --use-ninja
}

ros_build_tests () {
  disable_conda
  catkin_make tests --directory $CATKIN_WS
  source $CATKIN_WS/devel/setup.zsh
}

ros_run_tests () {
  disable_conda
  catkin_make run_tests --directory $CATKIN_WS
  catkin_test_results
}

ros_lint () {
  disable_conda
  catkin_make roslint --directory $CATKIN_WS
}

disable_conda () {
  if find_in_path 'conda'; then
    conda_toggle
  fi
}
