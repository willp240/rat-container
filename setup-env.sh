#!/bin/bash

source /home/root/bin/thisroot.sh
source /home/geant4.10.00.p02/bin/geant4.sh

export RAT_SCONS=/home/scons-2.1.0
export TF_DIR=/usr/local
export CPPFLOW_DIR=/home/software/cppflow                                                                                                                       
export LIBRARY_PATH=$LIBRARY_PATH:$TF_DIR/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$TF_DIR/lib
export LIBRARY_PATH=$LIBRARY_PATH:$CPPFLOW_DIR/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CPPFLOW_DIR/lib

if [ -f /rat/env.sh ]; then
    source /rat/env.sh
else
    printf "\nCould not find /rat/env.sh\nIf youre building RAT, please ignore.\nOtherwise, ensure RAT is mounted to /rat\n"
fi
