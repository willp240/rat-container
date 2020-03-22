FROM scientificlinux/sl:7

LABEL maintainer="Jamie Rajewski <jrajewsk@ualberta.ca>"

# Switch default shell to bash
SHELL ["/bin/bash", "-c"]

# Create place to copy scripts to
RUN mkdir /home/scripts

# Create the environment setup script and give it exec permissions
RUN printf '#!/bin/bash\nsource /home/root/bin/thisroot.sh\nsource /home/geant4.10.00.p02/bin/geant4.sh\nexport RAT_SCONS=/home/scons-2.1.0\n' > /home/scripts/setup-env.sh
#RUN printf 'export TF_DIR=/usr/local\nexport CPPFLOW_DIR=/home/software/cppflow\n' >> /home/scripts/setup-env.sh
#RUN printf 'export LIBRARY_PATH=$LIBRARY_PATH:$TF_DIR/lib\nexport LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$TF_DIR/lib\nexport LIBRARY_PATH=$LIBRARY_PATH:$CPPFLOW_DIR/lib\nexport LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CPPFLOW_DIR/lib\n' >> /home/scripts/setup-env.sh
RUN printf 'if [ -f /rat/env.sh ]; then source /rat/env.sh; else printf "\nCould not find /rat/env.sh\nIf youre building RAT, please ignore.\nOtherwise, ensure RAT is mounted to /rat\n"; fi' >> /home/scripts/setup-env.sh
RUN chmod +x /home/scripts/setup-env.sh

# Create the build-rat script and give it exec permissions
RUN printf '#!/bin/bash\necho "[ BUILDING RAT ]"\necho "Now checking to see if RAT was mounted correctly..."' > /home/scripts/build-rat.sh
RUN printf '\nif [ -d /rat ]; then cd /rat && ./configure && chmod +x /rat/env.sh && source /rat/env.sh && scons; else echo "RAT was not mounted correctly, please ensure it was mounted to /rat."; fi' >> /home/scripts/build-rat.sh
RUN chmod +x /home/scripts/build-rat.sh                                                                

# Install all tools, compilers, libraries, languages, and general pre-requisites
# for the SNO+ tools
RUN yum install -y vim emacs valgrid gdb which wget git gcc-c++-4.8.5-39.el7.x86_64 gcc-gfortran python-devel \
    python-argparse uuid-devel tar fftw fftw-devel gsl gsl-devel curl curl-devel bzip2 bzip2-devel \
    libX11-devel libXpm-devel libXft-devel libXext-devel mesa-libGL-devel mesa-libGLU-devel \
    libXmu-devel libXi-devel expat-devel make nano wget rsync strace cmake && \
    yum clean all && \
    rm -rf /var/cache/yum

# Fetch and install ROOT 5.34.36 from source
RUN cd /home && \
    wget https://root.cern.ch/download/root_v5.34.36.source.tar.gz && \
    tar zxvf root_v5.34.36.source.tar.gz && \
    cd root && \
    ./configure --enable-minuit2 --enable-python --enable-mathmore && \
    make -j4 && \
    chmod +x /home/root/bin/thisroot.sh && source /home/root/bin/thisroot.sh && \
    rm -rf root_v5.34.36.source.tar.gz

# Fetch and install GEANT4 from source
RUN cd /home && \
    wget http://geant4.cern.ch/support/source/geant4.10.00.p02.tar.gz && \
    mkdir geant4.10.00.p02-source && \
    tar -xvzf geant4.10.00.p02.tar.gz -C geant4.10.00.p02-source --strip-components 1 && \
    mkdir geant4.10.00.p02 && \
    mkdir geant4.10.00.p02-build && \
    cd geant4.10.00.p02-build && \
    cmake -DCMAKE_INSTALL_PREFIX=../geant4.10.00.p02 -DGEANT4_INSTALL_DATA=ON ../geant4.10.00.p02-source && \
    make ../geant4.10.00.p02 && \
    make install ../geant4.10.00.p02 && \
    cd .. && \
    rm -rf geant4.10.00.p02-source && \
    rm -rf geant4.10.00.p02-build && \
    rm -rf geant4.10.00.p02.tar.gz

# Fetch and install scons
RUN cd /home && \
    wget http://downloads.sourceforge.net/project/scons/scons/2.1.0/scons-2.1.0.tar.gz && \
    tar zxvf scons-2.1.0.tar.gz && \
    chmod +x scons-2.1.0/script/scons && \
    rm -rf scons-2.1.0.tar.gz

# Fetch and install TensorFlow C API v1.15.0 and cppflow
# RUN mkdir /home/software && \
#     cd /home/software && \
#     wget -O tflow https://storage.googleapis.com/tensorflow/libtensorflow/libtensorflow-cpu-linux-x86_64-1.15.0.tar.gz && \
#     tar -C /usr/local -xzf tflow && \
#     export LIBRARY_PATH=$LIBRARY_PATH:/usr/local/lib && \
#     export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib && \
#     rm tflow && \
#     git clone git://github.com/mark-r-anderson/cppflow.git && \
#     cd cppflow && \
#     git checkout ML-fitter && \
#     mkdir lib && \
#     make

# Cleanup the cache to make the image smaller
RUN cd /home && yum -y clean all && rm -rf /var/cache/yum
