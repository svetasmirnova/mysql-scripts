#!/bin/bash

# Place path to specific machine home directory here
MACHINE_HOME_DIR=$HOME
source $MACHINE_HOME_DIR/.profile

srcbase=$MACHINE_HOME_DIR/src/
installbase=$MACHINE_HOME_DIR/build
builds="mysql-5.5 mysql-5.6 mysql-trunk"
git_dir="mysql-git"

for build in $builds
        do
        echo "=== Downloading $build ==="
        echo "=> $build"
        cd $srcbase/$git_dir
        git checkout $build
        if [ $? -ne 0 ]
                then
                echo "checkout of $bild failed" >> $1
        fi

        echo "=== Building $build ==="
        cd "$srcbase/$build"

        rm "$srcbase/$build/CmakeCache.txt"

        cmake "$srcbase/$git_dir" -DCMAKE_INSTALL_PREFIX="$installbase/$build" --DWITH_DEBUG=1 -DDOWNLOAD_BOOST=1 -DWITH_BOOST="$srcbase/$build/boost"
        make

        if [ $? -ne 0 ]
                then
                echo "$build make failed" >> $1
        fi

        echo "=== Installing $build ==="
        make install
        if [ $? -ne 0 ]
                then
                echo "$build install failed" >> $1
        fi
done
