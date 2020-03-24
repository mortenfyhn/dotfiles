export ROSCONSOLE_FORMAT='[${severity}] [${node}] [${time}]: ${message}'

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



disable_conda () {
  if find_in_path 'conda'; then
    conda_toggle
  fi
}
