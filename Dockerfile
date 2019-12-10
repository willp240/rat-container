FROM scientificlinux/sl:7

LABEL maintainer="Jamie Rajewski <jrajewsk@ualberta.ca>"

# Switch default shell to bash
SHELL ["/bin/bash", "-c"]

# Create place to copy scripts to
RUN mkdir /home/scripts

# Create the environment setup script and give it exec permissions
RUN printf '#!/bin/bash\nsource /home/root/bin/thisroot.sh\nsource /home/geant4.10.00.p02/bin/geant4.sh\nexport RAT_SCONS=/home/scons-2.1.0\n' > /home/scripts/setup-env.sh
RUN printf 'if [ -f /rat/env.sh ]; then source /rat/env.sh; else printf "\nCould not find /rat/env.sh\nIf youre building RAT, please ignore.\nOtherwise, ensure RAT is mounted to /rat"; fi' >> /home/scripts/setup-env.sh
RUN chmod +x /home/scripts/setup-env.sh

# Create the build-rat script and give it exec permissions
RUN printf '#!/bin/bash\necho "[ BUILDING RAT ]"\necho "Now checking to see if RAT was mounted correctly..."' > /home/scripts/build-rat.sh
RUN printf '\nif [ -d /rat ]; then cd /rat && ./configure && chmod +x /rat/env.sh && source /rat/env.sh && scons; else echo "RAT was not mounted correctly, please ensure it was mounted to /rat."; fi' >> /home/scripts/build-rat.sh
RUN printf '\n/bin/bash' >> /home/scripts/build-rat.sh
RUN chmod +x /home/scripts/build-rat.sh                                                                

# Install all tools, compilers, libraries, languages, and general pre-requisites
# for the SNO+ tools
RUN yum -y groups mark convert && \
    yum -y grouplist && \
    yum -y groupinstall "Compatibility Libraries" "Development Tools" "Scientific Support" && \
    yum -y install avahi-compat-libdns_sd-devel bc binutils binutils-devel bzip2 bzip2-devel cfitsio-devel \
    cmake coreutils curl curl-devel emacs expat-devel fftw fftw-devel fontconfig ftgl-devel g++ \
    gcc-4.8.5 gcc-gfortran git glew-devel glib2-devel glib-devel graphviz graphviz-devel \
    gsl gsl-devel gsl-static java-1.8.0-openjdk java-1.8.0-openjdk-devel libcurl-devel \
    libgfortran libgomp libldap-dev libX11-devel libXext-devel libXft-devel libxml2-devel \
    libXpm-devel libXt-devel make man mesa-libGL-devel mesa-libGLU-devel mysql-devel nano \
    openssl-devel pcre-devel python python-devel python-pip rsync strace valgrind wget

# Fetch and install ROOT 5.34.36 from source
RUN cd /home && \
    wget https://root.cern.ch/download/root_v5.34.36.source.tar.gz && \
    tar zxvf root_v5.34.36.source.tar.gz && \
    cd root && \
    ./configure --enable-minuit2 --enable-python --enable-mathmore && \
    # Currently set to compile on 4 cores; increase this if you have more available
    make -j4 && \
    chmod +x /home/root/bin/thisroot.sh && source /home/root/bin/thisroot.sh

# Fetch and install GEANT4 from source
RUN cd /home && \
    wget http://geant4.cern.ch/support/source/geant4.10.00.p02.tar.gz && \
    tar zxvf geant4.10.00.p02.tar.gz && \
    mkdir geant4.10.00.p02-build && \
    cd geant4.10.00.p02-build && \
    cmake -DGEANT4_INSTALL_DATA=ON -DCMAKE_INSTALL_PREFIX=../geant4.10.00.p02 ../geant4.10.00.p02 && \
    make -j4 && \
    make install && \
    chmod +x /home/geant4.10.00.p02/bin/geant4.sh && source /home/geant4.10.00.p02/bin/geant4.sh && \
    chmod +x /home/geant4.10.00.p02/share/Geant4-10.0.2/geant4make/geant4make.sh && \
    source /home/geant4.10.00.p02/share/Geant4-10.0.2/geant4make/geant4make.sh

# Fetch and install scons
RUN cd /home && \
    wget http://downloads.sourceforge.net/project/scons/scons/2.1.0/scons-2.1.0.tar.gz && \
    tar zxvf scons-2.1.0.tar.gz && \
    chmod +x scons-2.1.0/script/scons


#Cleanup the cache to make the image smaller
RUN cd /home && yum -y clean all && rm -rf /var/cache/yum && rm *.gz*
