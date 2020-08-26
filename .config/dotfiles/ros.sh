export ROSCONSOLE_FORMAT='[${severity}] [${node}] [${time}]: ${message}'

if [ -e /opt/ros/melodic/setup.zsh ]; then
    source /opt/ros/melodic/setup.zsh
fi

if [ -e "$CATKIN_WS"/devel/setup.zsh ]; then
    source "$CATKIN_WS"/devel/setup.zsh
fi
