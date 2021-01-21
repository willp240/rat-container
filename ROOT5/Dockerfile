FROM scientificlinux/sl:7

LABEL maintainer="Jamie Rajewski <jrajewsk@ualberta.ca>"

# Switch default shell to bash
SHELL ["/bin/bash", "-c"]

# Create place to copy scripts to
RUN mkdir /home/scripts
COPY build-rat.sh /home/scripts
COPY setup-env.sh /home/scripts
COPY docker-entrypoint.sh /usr/local/bin/

RUN mkdir /home/software

# Install all tools, compilers, libraries, languages, and general pre-requisites
# for the SNO+ tools
RUN yum group install -y "Development Tools"
RUN yum install -y vim emacs valgrind gdb which wget git python-devel \
    python-argparse uuid-devel tar fftw fftw-devel gsl gsl-devel curl curl-devel bzip2 bzip2-devel openssl \
    libX11-devel libXpm-devel libXft-devel libXext-devel mesa-libGL-devel mesa-libGLU-devel openssl-devel \
    libXmu-devel libXi-devel expat-devel make nano wget rsync strace cmake latex2html postgresql-devel && \
    yum clean all && \
    rm -rf /var/cache/yum

RUN cd /home/software && \
    wget https://root.cern/download/root_v5.34.38.Linux-ubuntu14-x86_64-gcc4.8.tar.gz && \
    tar xzfv root_v5.34.38.Linux-ubuntu14-x86_64-gcc4.8.tar.gz && \
    rm -rf root_v5.34.38.Linux-ubuntu14-x86_64-gcc4.8.tar.gz

# Fetch and install GEANT4 from source
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

# Fetch and install scons
RUN cd /home/software && wget http://downloads.sourceforge.net/project/scons/scons/3.1.2/scons-3.1.2.tar.gz
RUN cd /home/software && tar zxvf scons-3.1.2.tar.gz && \
    chmod +x scons-3.1.2/script/scons && \
        rm -rf scons-3.1.2.tar.gz

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

# Cleanup the cache to make the image smaller
RUN cd /home && yum -y clean all && rm -rf /var/cache/yum

# Set up the environment when entering the container
ENTRYPOINT ["docker-entrypoint.sh"]
