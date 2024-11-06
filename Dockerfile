ARG AUTOWARE_VERSION=1.14.0-melodic

FROM autoware/autoware:$AUTOWARE_VERSION

WORKDIR /home/autoware

# Update simulation repo to latest master.
COPY --chown=autoware update_sim.patch ./Autoware
RUN patch ./Autoware/autoware.ai.repos ./Autoware/update_sim.patch
RUN cd ./Autoware \
    && vcs import src < autoware.ai.repos \
    && git --git-dir=./src/autoware/simulation/.git --work-tree=./src/autoware/simulation pull \
    && source /opt/ros/melodic/setup.bash \
    && AUTOWARE_COMPILE_WITH_CUDA=0 colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release

# Fix GPG error by updating ROS repository key
RUN sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys F42ED6FBAB17C654

# Update package lists and install pip
RUN apt-get update && apt-get install -y python-pip
RUN pip install --upgrade pip

# Now install the CARLA Python API via pip
RUN pip install carla==0.9.13


# CARLA ROS Bridge
# There is some kind of mismatch between the ROS debian packages installed in the Autoware image and
# the latest ros-melodic-ackermann-msgs and ros-melodic-derived-objects-msgs packages. As a
# workaround we use a snapshot of the ROS apt repository to install an older version of the required
# packages. 
RUN sudo rm -f /etc/apt/sources.list.d/ros1-latest.list
RUN sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key 4B63CF8FDE49746E98FA01DDAD19BAB3CBF125EA
RUN sudo sh -c 'echo "deb http://snapshots.ros.org/melodic/2020-08-07/ubuntu $(lsb_release -sc) main" >> /etc/apt/sources.list.d/ros-snapshots.list'
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
        python-pip \
        python-wheel \
        ros-melodic-ackermann-msgs \
        ros-melodic-derived-object-msgs \
    && sudo rm -rf /var/lib/apt/lists/*
RUN pip install simple-pid pygame networkx==2.2

RUN git clone -b '0.9.12' --recurse-submodules https://github.com/carla-simulator/ros-bridge.git

# CARLA Autoware agent
COPY --chown=autoware . ./carla-autoware

RUN mkdir -p carla_ws/src
RUN cd carla_ws/src \
    && ln -s ../../ros-bridge \
    && ln -s ../../carla-autoware/carla-autoware-agent \
    && cd .. \
    && source /opt/ros/melodic/setup.bash \
    && catkin_make

RUN echo "export CARLA_AUTOWARE_CONTENTS=~/autoware-contents" >> .bashrc \
    && echo "source ~/carla_ws/devel/setup.bash" >> .bashrc \
    && echo "source ~/Autoware/install/setup.bash" >> .bashrc

CMD ["/bin/bash"]

