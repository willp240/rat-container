FROM ubuntu:20.04

LABEL maintainer="Jamie Rajewski <jrajewsk@ualberta.ca>"

# Switch default shell to bash
SHELL ["/bin/bash", "-c"]

# Create place to copy scripts to
RUN mkdir /home/scripts
COPY build-rat.sh /home/scripts
COPY setup-env.sh /home/scripts
COPY docker-entrypoint.sh /usr/local/bin/

ENV DEBIAN_FRONTEND=noninteractive

RUN mkdir /home/software

RUN apt-get update && apt-get install -y gcc g++ gfortran libssl-dev libpcre3-dev \
    xlibmesa-glu-dev libglew1.5-dev libftgl-dev libmysqlclient-dev libfftw3-dev libcfitsio-dev \
    graphviz-dev libavahi-compat-libdnssd-dev libldap2-dev python-dev libxml2-dev libkrb5-dev \
    libgsl0-dev emacs wget git tar curl nano vim rsync strace valgrind make cmake \
    libxpm-dev libxft-dev libxext-dev libcurl4-openssl-dev libbz2-dev latex2html python3-pip

RUN cd /home/software && \
    wget https://root.cern/download/root_v6.22.02.Linux-ubuntu20-x86_64-gcc9.3.tar.gz && \
    tar xzfv root_v6.22.02.Linux-ubuntu20-x86_64-gcc9.3.tar.gz && \
    rm -rf root_v6.22.02.Linux-ubuntu20-x86_64-gcc9.3.tar.gz

# Cleanup the cache to make the image smaller
RUN apt-get clean -y

# Install pip and Python libs
# RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
#     python3 get-pip.py && \
#     rm -f get-pip.py && \
RUN python3 -m pip install ipython numpy scipy

# Fetch and install scons
RUN cd /home/software && wget http://downloads.sourceforge.net/project/scons/scons/3.1.2/scons-3.1.2.tar.gz
RUN cd /home/software && tar zxvf scons-3.1.2.tar.gz && \
    chmod +x scons-3.1.2/script/scons && \
    rm -rf scons-3.1.2.tar.gz

# Install GEANT4
# New GEANT4 source installation
RUN cd /home/software && wget http://cern.ch/geant4-data/releases/geant4.10.00.p04.tar.gz
RUN cd /home/software && mkdir geant4.10.00.p04-source && \
    tar -xvzf geant4.10.00.p04.tar.gz -C geant4.10.00.p04-source --strip-components 1 && \
    mkdir geant4.10.00.p04 && \
    mkdir geant4.10.00.p04-build && \
    cd geant4.10.00.p04-build && \
    cmake -DCMAKE_INSTALL_PREFIX=../geant4.10.00.p04 -DGEANT4_INSTALL_DATA=ON ../geant4.10.00.p04-source && \
    make ../geant4.10.00.p04 && \
    make install ../geant4.10.00.p04 && \
    cd .. && \
    rm -rf geant4.10.00.p04-source && \
    rm -rf geant4.10.00.p04-build && \
    rm -rf geant4.10.00.p04.tar.gz

# Fetch and install TensorFlow C API v1.15.0 and cppflow
RUN cd /home/software && \
    wget -O tflow https://storage.googleapis.com/tensorflow/libtensorflow/libtensorflow-cpu-linux-x86_64-1.15.0.tar.gz && \
    tar -C /usr/local -xzf tflow && \
    export LIBRARY_PATH=$LIBRARY_PATH:/usr/local/lib && \
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib && \
    rm tflow && \
    git clone git://github.com/mark-r-anderson/cppflow.git && \
    cd cppflow && \
    git checkout ML-fitter && \
    mkdir lib && \
    make

# Set up the environment when entering the container
ENTRYPOINT ["docker-entrypoint.sh"]
