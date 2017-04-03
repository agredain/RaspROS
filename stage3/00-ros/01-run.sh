#!/bin/bash -e

on_chroot << EOF
# setting up ROS repositories
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
sudo apt-get update

# Installing bootstrap dependencies
sudo apt-get install -y python-rosdep python-rosinstall-generator python-wstool python-rosinstall build-essential cmake

# Initializing rosdep
sudo rosdep init
rosdep update

# Installation ROS
mkdir /home/pi/ros_catkin_ws
cd /home/pi/ros_catkin_ws

rosinstall_generator ros_comm --rosdistro kinetic --deps --wet-only --tar > kinetic-ros_comm-wet.rosinstall
wstool init src kinetic-ros_comm-wet.rosinstall

# Resolving Dependencies
mkdir -p /home/pi/ros_catkin_ws/external_src
cd /home/pi/ros_catkin_ws/external_src
wget http://sourceforge.net/projects/assimp/files/assimp-3.1/assimp-3.1.1_no_test_models.zip/download -O assimp-3.1.1_no_test_models.zip
unzip assimp-3.1.1_no_test_models.zip
cd assimp-3.1.1
cmake .
make
sudo make install

cd /home/pi/ros_catkin_ws
rosdep install -y --from-paths src --ignore-src --rosdistro kinetic -r --os=debian:jessie

# Building catking Workspace
cd /home/pi/ros_catkin_ws
sudo ./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release --install-space /opt/ros/kinetic
sudo sh -c 'echo "source /opt/ros/kinetic/setup.bash" >> /root/.bashrc'
echo "source /opt/ros/kinetic/setup.bash" >> /home/pi/.bashrc
EOF
