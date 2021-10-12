FROM scientificlinux/sl:7

LABEL maintainer="Mark Anderson <anderson.mark@queensu.ca>"

# Switch default shell to bash
SHELL ["/bin/bash", "-c"]

# Create place to copy scripts to
RUN mkdir /home/scripts
COPY scripts/build-rat.sh /home/scripts
COPY scripts/setup-env.sh /home/scripts
COPY scripts/docker-entrypoint.sh /usr/local/bin/

ARG SOFTWAREDIR=/home/software
RUN mkdir -p $SOFTWAREDIR

# Install all tools, compilers, libraries, languages, and general pre-requisites
# for the SNO+ tools
RUN yum group install -y "Development Tools"
RUN yum install -y vim emacs valgrind gdb which wget git tar \
    uuid-devel fftw fftw-devel gsl gsl-devel curl curl-devel bzip2 bzip2-devel openssl \
    libX11-devel libXpm-devel libXft-devel libXext-devel mesa-libGL-devel mesa-libGLU-devel openssl-devel \
    libXmu-devel libXi-devel expat-devel make nano wget rsync strace cmake latex2html postgresql-devel \
    scl-utils scl-utils-build yum-conf-repos
RUN yum install -y yum-conf-softwarecollections
RUN yum update -y

# Install Python packages
RUN yum install -y python27
RUN source /opt/rh/python27/enable && \
    python2 -m pip install --upgrade --no-cache-dir pip==20.3.4 && \
    python2 -m pip install --upgrade --no-cache-dir setuptools && \
    python2 -m pip install --no-cache-dir requests pytz python-dateutil \
    numpy sympy matplotlib six redis \
    psycopg2-binary CouchDB SQLAlchemy

# Fetch and install SCons
ARG SCONS_VERSION=3.1.2
WORKDIR $SOFTWAREDIR
RUN source /opt/rh/python27/enable && \
    wget https://downloads.sourceforge.net/project/scons/scons/$SCONS_VERSION/scons-$SCONS_VERSION.tar.gz && \
    tar zxvf scons-$SCONS_VERSION.tar.gz && \
    cd scons-$SCONS_VERSION && \
    python2 setup.py install && \
    cd .. && \
    rm -rf scons-$SCONS_VERSION.tar.gz && rm -rf scons-$SCONS_VERSION

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

# Compile ROOT 5 from source
ARG ROOT_VERSION=5.34.38
WORKDIR $SOFTWAREDIR
RUN source /opt/rh/python27/enable && \
    wget https://root.cern.ch/download/root_v$ROOT_VERSION.source.tar.gz && \
    tar zxvf root_v$ROOT_VERSION.source.tar.gz && \
    cd root && \
    ./configure --enable-minuit2 --enable-python --enable-mathmore --enable-roofit --enable-cxx11 && \
    make -j4 && \
    cd .. && \
    rm -rf root_v$ROOT_VERSION.source.tar.gz

# Cleanup the cache to make the image smaller
RUN yum -y clean all && rm -rf /var/cache/yum

# Set up the environment when entering the container
WORKDIR /home
ENTRYPOINT ["docker-entrypoint.sh"]
