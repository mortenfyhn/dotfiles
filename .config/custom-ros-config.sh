scout_source_catkin_ws ()
{
  if [ -e "$CATKIN_WS/devel/setup.zsh" ]; then
    source $CATKIN_WS/devel/setup.zsh
  fi
}



# Source ROS installation in every new shell
source /opt/ros/melodic/setup.zsh

# Source (default) catkin workspace in every new shell
scout_source_catkin_ws



scout_catkin_build ()
{
  catkin build \
    --workspace $CATKIN_WS \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
    -DCMAKE_BUILD_TYPE=Release

  scout_source_catkin_ws
  echo -e "\nRe-sourced setup files."
}

disable_conda () {
  if find_in_path 'conda'; then
    conda_toggle
  fi
}
