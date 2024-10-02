FROM ubuntu:20.04

LABEL maintainer="Will Parker <william.parker@physics.ox.ac.uk>"

# Switch default shell to bash
SHELL ["/bin/bash", "-c"]

# Create place to copy scripts to
RUN mkdir /home/scripts
COPY scripts/build-rat.sh /home/scripts
COPY scripts/setup-env.sh /home/scripts
COPY scripts/setup-genie.sh /home/scripts
COPY scripts/docker-entrypoint.sh /usr/local/bin/

ENV DEBIAN_FRONTEND=noninteractive

ARG SOFTWAREDIR=/home/software
RUN mkdir -p ${SOFTWAREDIR}

RUN apt-get update && apt-get install -y gcc g++ gfortran \
    libssl-dev libpcre3-dev xlibmesa-glu-dev libglew1.5-dev \
    libftgl-dev libmysqlclient-dev libfftw3-dev libcfitsio-dev \
    graphviz-dev libavahi-compat-libdnssd-dev libldap2-dev libxml2-dev libkrb5-dev \
    libgsl0-dev emacs wget git tar curl nano vim rsync strace valgrind make cmake \
    libxpm-dev libxft-dev libxext-dev libcurl4-openssl-dev libbz2-dev latex2html libxerces-c-dev\
    python3 python3-dev python3-pip python3-venv python-is-python3

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
ARG TENSORFLOW_VERSION=2.5.3
ARG TENSORFLOW_TAR_FILE=libtensorflow-cpu-linux-x86_64-$TENSORFLOW_VERSION.tar.gz
WORKDIR $SOFTWAREDIR
RUN wget https://storage.googleapis.com/tensorflow/libtensorflow/$TENSORFLOW_TAR_FILE && \
    tar -C /usr/local -xzf $TENSORFLOW_TAR_FILE && \
    export LIBRARY_PATH=$LIBRARY_PATH:/usr/local/lib && \
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib && \
    rm $TENSORFLOW_TAR_FILE && \
    git clone --single-branch https://github.com/serizba/cppflow && \
    cd cppflow && \
    git checkout 883eb4c526979dae56f921571b1ab93df85a0a0d

# Fetch and install GEANT4 from source
ARG GEANT4_VERSION=4.10.00.p04
WORKDIR $SOFTWAREDIR
RUN wget https://cern.ch/geant4-data/releases/geant$GEANT4_VERSION.tar.gz && \
    mkdir geant$GEANT4_VERSION && mkdir geant$GEANT4_VERSION-source && mkdir geant$GEANT4_VERSION-build && \
    tar zxvf geant$GEANT4_VERSION.tar.gz -C geant$GEANT4_VERSION-source --strip-components 1 && \
    pushd geant$GEANT4_VERSION-source && \
    wget https://github.com/JamesJieranShen/geant4/commit/3ec1153a22a76c181d45a8ee67fb3121cadff1e6.patch -O out.patch && \
    patch -p1 < out.patch && \
    popd && \
    cd geant$GEANT4_VERSION-build && \
    cmake -DCMAKE_INSTALL_PREFIX=../geant$GEANT4_VERSION \
    -DGEANT4_INSTALL_DATA=ON \
    -DGEANT4_BUILD_CXXSTD=c++11 \
    -DGEANT4_USE_GDML=ON \
    ../geant$GEANT4_VERSION-source && \
    make -j$(nproc) && make install && \
    cd .. && \
    rm -rf geant$GEANT4_VERSION-source && \
    rm -rf geant$GEANT4_VERSION-build && \
    rm -rf geant$GEANT4_VERSION.tar.gz
    
# Pythia6 -- need to be built before root
RUN mkdir -p ${SOFTWAREDIR}/pythia6
WORKDIR ${SOFTWAREDIR}/pythia6
RUN wget https://raw.githubusercontent.com/GENIE-MC/Generator/29dc1a99ae56161f86be455c17fddd8be86666ac/src/scripts/build/ext/build_pythia6.sh
RUN source build_pythia6.sh 6.4.28
WORKDIR ${SOFTWAREDIR}
ENV PYTHIA6=${SOFTWAREDIR}/pythia6/v6_428

# Install ROOT 6 binary
ARG ROOT_VERSION=6.28.06
WORKDIR $SOFTWAREDIR

RUN wget https://root.cern/download/root_v$ROOT_VERSION.source.tar && \
    tar xvf root_v${ROOT_VERSION}.source.tar && \
    mv root-${ROOT_VERSION} root && \
    mkdir root-build && cd root-build && \
    cmake -Droofit=ON -Dfortran=OFF -Dfftw3=ON -Dgsl=ON -Dgdml=ON -Dmathmore=ON -Dclad=OFF -Dbuiltin_tbb=OFF -Dimt=OFF -Dpythia6=ON -DPYTHIA6_DIR=${SOFTWAREDIR}/pythia6/v6_428 ../root && \
    make -j $(nproc) && \
    rm ../root_v$ROOT_VERSION.source.tar

RUN apt-get -y update && apt-get -y upgrade && apt-get -y install liblog4cpp5-dev
RUN wget https://lhapdf.hepforge.org/downloads/?f=LHAPDF-6.5.4.tar.gz -O LHAPDF-6.5.4.tar.gz && \
    tar xf LHAPDF-6.5.4.tar.gz && rm LHAPDF-6.5.4.tar.gz && mv LHAPDF-6.5.4 LHAPDF6-src
RUN mkdir -p ${SOFTWAREDIR}/LHAPDF6
WORKDIR ${SOFTWAREDIR}/LHAPDF6-src
RUN ./configure --prefix=${SOFTWAREDIR}/LHAPDF6 && make -j$(nproc) && make install
WORKDIR ${SOFTWAREDIR}
RUN rm -rf ${SOFTWAREDIR}/LHDPDF6-src
ENV LHAPDF6=${SOFTWAREDIR}/LHAPDF6

RUN git clone --depth=1 --branch=R-3_04_02 https://github.com/GENIE-MC/Generator.git genie-src
ARG GENIE=${SOFTWAREDIR}/genie-src
WORKDIR ${GENIE}
RUN pushd ${SOFTWAREDIR}/root-build/bin && source thisroot.sh && popd && \
  source ${SOFTWAREDIR}/geant4.10.00.p04/bin/geant4.sh && \
  ./configure --enable-atmo --enable-fnal --enable-t2k --enable-nucleon-decay --enable-vle-extension\
  --prefix=${SOFTWAREDIR}/genie \
  --enable-lhapdf6 \
  --with-lhapdf6-lib=${SOFTWAREDIR}/LHAPDF6/lib \
  --with-lhapdf6-inc=${SOFTWAREDIR}/LHAPDF6/include \
  --with-pythia6-lib=${SOFTWAREDIR}/pythia6/v6_428/lib &&\
  make -j$(nproc) && make install && \
  # # GENIE requires these files to be present at runtime, but doesn't install them
  cp -r config ${SOFTWAREDIR}/genie/ && \
  cp -r data ${SOFTWAREDIR}/genie/ && \
  cp -r src ${SOFTWAREDIR}/genie/
ENV GENIE=${SOFTWAREDIR}/genie

# Cleanup the cache to make the image smaller
RUN apt-get autoremove -y && apt-get clean -y

# Set up the environment when entering the container
WORKDIR /home
ENTRYPOINT ["docker-entrypoint.sh"]
