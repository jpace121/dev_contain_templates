#!/usr/bin/env bash
set -x
# Based on script in:
#   https://index.ros.org/doc/ros2/Installation/Eloquent/Linux-Development-Setup/
# which is licensed under CC-BY-3.0:
#   https://creativecommons.org/licenses/by/3.0/
# Build ROS 2 Eloquent from scratch.
sudo apt update -y && sudo apt install -y curl gnupg2 lsb-release ca-certificates
# rehash required because of a bug in qemu for 64bit hosting arm binaries.
# Alternative fix is to use 32bit qemu-static-bin on 64bit host.
# See: https://bugs.launchpad.net/qemu/+bug/1805913 and
#      https://github.com/RPi-Distro/pi-gen/issues/271
sudo c_rehash /etc/ssl/certs
curl https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64,arm64] http://packages.ros.org/ros2/ubuntu `lsb_release -cs` main" > /etc/apt/sources.list.d/ros2-latest.list'

# Apt dependencies
sudo apt update && sudo apt install -y \
  build-essential \
  cmake \
  git \
  libbullet-dev \
  python3-colcon-common-extensions \
  python3-flake8 \
  python3-pip \
  python3-pytest-cov \
  python3-rosdep \
  python3-setuptools \
  python3-vcstool \
  wget
# install some pip packages needed for testing
python3 -m pip install -U \
  argcomplete \
  flake8-blind-except \
  flake8-builtins \
  flake8-class-newline \
  flake8-comprehensions \
  flake8-deprecated \
  flake8-docstrings \
  flake8-import-order \
  flake8-quotes \
  pytest-repeat \
  pytest-rerunfailures \
  pytest
# install Fast-RTPS dependencies
sudo apt install --no-install-recommends -y \
  libasio-dev \
  libtinyxml2-dev
# install Cyclone DDS dependencies
sudo apt install --no-install-recommends -y \
  libcunit1-dev

mkdir -p ~/ros2_ws/src
cd ~/ros2_ws
vcs import src < /foxy-ros2.repos

sudo rosdep init
rosdep update
rosdep install --from-paths src --ignore-src --rosdistro foxy -y --skip-keys "console_bridge fastcdr fastrtps rti-connext-dds-5.3.1 urdfdom_headers"

cd ~/ros2_ws/
colcon build
