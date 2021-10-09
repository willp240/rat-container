#!/bin/bash

echo "[ BUILDING RAT ]"
echo "Now checking to see if RAT was mounted correctly..."

if [ -d /rat ]; then
    cd /rat
    ./configure
    chmod +x /rat/env.sh
    source /rat/env.sh
    scons
else
    echo "RAT was not mounted correctly, please ensure it was mounted to /rat."
fi
