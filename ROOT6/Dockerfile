FROM ubuntu:20.04

LABEL maintainer="Mark Anderson <anderson.mark@queensu.ca>"

# Switch default shell to bash
SHELL ["/bin/bash", "-c"]

# Create place to copy scripts to
RUN mkdir /home/scripts
COPY scripts/build-rat.sh /home/scripts
COPY scripts/setup-env.sh /home/scripts
COPY scripts/docker-entrypoint.sh /usr/local/bin/

ENV DEBIAN_FRONTEND=noninteractive

ARG SOFTWAREDIR=/home/software
RUN mkdir -p /home/software

RUN apt-get update && apt-get install -y gcc g++ gfortran \
    libssl-dev libpcre3-dev xlibmesa-glu-dev libglew1.5-dev \
    libftgl-dev libmysqlclient-dev libfftw3-dev libcfitsio-dev \
    graphviz-dev libavahi-compat-libdnssd-dev libldap2-dev libxml2-dev libkrb5-dev \
    libgsl0-dev emacs wget git tar curl nano vim rsync strace valgrind make cmake \
    libxpm-dev libxft-dev libxext-dev libcurl4-openssl-dev libbz2-dev latex2html \
    python3 python3-dev python3-pip python2 python2-dev python-is-python3

# Install Python packages
RUN python3 -m pip install --upgrade --no-cache-dir pip && \
    python3 -m pip install --upgrade --no-cache-dir setuptools && \
    python3 -m pip install --no-cache-dir pipx && \
    python3 -m pip install --no-cache-dir requests pytz python-dateutil \
    ipython numpy scipy matplotlib

# Install SCons via pip (quicker and simpler than from source)
ARG SCONS_VERSION=3.1.2
RUN PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin pipx install scons==$SCONS_VERSION

# Fetch and install TensorFlow C API v1.15.0 and cppflow
WORKDIR $SOFTWAREDIR
RUN wget -O tflow https://storage.googleapis.com/tensorflow/libtensorflow/libtensorflow-cpu-linux-x86_64-1.15.0.tar.gz && \
    tar -C /usr/local -xzf tflow && \
    export LIBRARY_PATH=$LIBRARY_PATH:/usr/local/lib && \
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib && \
    rm tflow && \
    git clone git://github.com/mark-r-anderson/cppflow.git && \
    cd cppflow && \
    git checkout ML-fitter && \
    mkdir lib && \
    make

# Fetch and install GEANT4 from source
ARG GEANT4_VERSION=4.10.00.p04
WORKDIR $SOFTWAREDIR
RUN wget https://cern.ch/geant4-data/releases/geant$GEANT4_VERSION.tar.gz && \
    mkdir geant$GEANT4_VERSION && mkdir geant$GEANT4_VERSION-source && mkdir geant$GEANT4_VERSION-build && \
    tar zxvf geant$GEANT4_VERSION.tar.gz -C geant$GEANT4_VERSION-source --strip-components 1 && \
    cd geant$GEANT4_VERSION-build && \
    cmake -DCMAKE_INSTALL_PREFIX=../geant$GEANT4_VERSION \
    -DGEANT4_INSTALL_DATA=ON \
    -DGEANT4_BUILD_CXXSTD=c++11 \
    ../geant$GEANT4_VERSION-source && \
    make -j4 && make install && \
    cd .. && \
    rm -rf geant$GEANT4_VERSION-source && \
    rm -rf geant$GEANT4_VERSION-build && \
    rm -rf geant$GEANT4_VERSION.tar.gz

# Install ROOT 6 binary
ARG ROOT_VERSION=6.22.08
WORKDIR $SOFTWAREDIR
RUN wget https://root.cern/download/root_v$ROOT_VERSION.Linux-ubuntu20-x86_64-gcc9.3.tar.gz && \
    tar xzfv root_v$ROOT_VERSION.Linux-ubuntu20-x86_64-gcc9.3.tar.gz && \
    rm -rf root_v$ROOT_VERSION.Linux-ubuntu20-x86_64-gcc9.3.tar.gz

# Cleanup the cache to make the image smaller
RUN apt-get autoremove -y && apt-get clean -y

# Set up the environment when entering the container
WORKDIR /home
ENTRYPOINT ["docker-entrypoint.sh"]
