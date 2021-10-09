FROM scientificlinux/sl:7

LABEL maintainer="Jamie Rajewski <jrajewsk@ualberta.ca>"

# Switch default shell to bash
SHELL ["/bin/bash", "-c"]

# Create place to copy scripts to
RUN mkdir /home/scripts
COPY build-rat.sh /home/scripts
COPY setup-env.sh /home/scripts
COPY docker-entrypoint.sh /usr/local/bin/

ARG SOFTWAREDIR=/home/software
RUN mkdir $SOFTWAREDIR

# Install all tools, compilers, libraries, languages, and general pre-requisites
# for the SNO+ tools
RUN yum group install -y "Development Tools"
RUN yum install -y vim emacs valgrind gdb which wget git \
    uuid-devel tar fftw fftw-devel gsl gsl-devel curl curl-devel bzip2 bzip2-devel openssl \
    libX11-devel libXpm-devel libXft-devel libXext-devel mesa-libGL-devel mesa-libGLU-devel openssl-devel \
    libXmu-devel libXi-devel expat-devel make nano wget rsync strace cmake latex2html postgresql-devel \
    scl-utils scl-utils-build yum-conf-repos
RUN yum install -y yum-conf-softwarecollections
RUN yum update -y

# Install python packages
RUN yum install -y python27
RUN source /opt/rh/python27/enable && \
    python2 -m pip install --upgrade --no-cache-dir pip==20.3.4 && \
    python2 -m pip install --upgrade --no-cache-dir setuptools && \
    python2 -m pip install --no-cache-dir requests pytz python-dateutil \
    numpy sympy matplotlib six redis \
    psycopg2-binary CouchDB SQLAlchemy

# Fetch and install GEANT4 from source
RUN cd $SOFTWAREDIR && \
    wget https://cern.ch/geant4-data/releases/geant4.10.00.p04.tar.gz && \
    mkdir geant4.10.00.p04-source && mkdir geant4.10.00.p04 && mkdir geant4.10.00.p04-build && \
    tar zxvf geant4.10.00.p04.tar.gz -C geant4.10.00.p04-source --strip-components 1 && \
    cd geant4.10.00.p04-build && \
    cmake -DCMAKE_INSTALL_PREFIX=../geant4.10.00.p04 -DGEANT4_INSTALL_DATA=ON ../geant4.10.00.p04-source && \
    make -j4 ../geant4.10.00.p04 && \
    make install ../geant4.10.00.p04 && \
    cd .. && \
    rm -rf geant4.10.00.p04-source && \
    rm -rf geant4.10.00.p04-build && \
    rm -rf geant4.10.00.p04.tar.gz

# Fetch and install SCons
ARG SCONS_VERSION=3.1.2
RUN cd $SOFTWAREDIR && \
    source /opt/rh/python27/enable && \
    wget https://downloads.sourceforge.net/project/scons/scons/$SCONS_VERSION/scons-$SCONS_VERSION.tar.gz && \
    tar zxvf scons-$SCONS_VERSION.tar.gz && \
    cd scons-$SCONS_VERSION && \
    python2 setup.py install && \
    cd .. && \
    rm -rf scons-$SCONS_VERSION.tar.gz && rm -rf scons-$SCONS_VERSION

# Fetch and install TensorFlow C API v1.15.0 and cppflow
RUN cd $SOFTWAREDIR && \
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

# Compile ROOT 5 from source
ARG ROOT_VERSION=5.34.38
RUN cd $SOFTWAREDIR && \
    source /opt/rh/python27/enable && \
    wget https://root.cern.ch/download/root_v$ROOT_VERSION.source.tar.gz && \
    tar zxvf root_v$ROOT_VERSION.source.tar.gz && \
    cd root && \
    ./configure --enable-minuit2 --enable-python --enable-mathmore --enable-roofit --enable-cxx11 && \
    make -j4 && \
    chmod +x /home/software/root/bin/thisroot.sh && source /home/software/root/bin/thisroot.sh && \
    cd .. && \
    rm -rf root_v$ROOT_VERSION.source.tar.gz

# Cleanup the cache to make the image smaller
RUN cd /home && yum -y clean all && rm -rf /var/cache/yum

# Set up the environment when entering the container
ENTRYPOINT ["docker-entrypoint.sh"]
