#!/bin/bash

# Place path to specific machine home directory here
MACHINE_HOME_DIR=$HOME
source $MACHINE_HOME_DIR/.bashrc

srcbase=$MACHINE_HOME_DIR/src/
installbase=$MACHINE_HOME_DIR/build
builds="5.5 5.6 5.7"
build_prefix="mysql-"
git_dir="mysql-server"

for build in $builds
        do
        echo "=== Downloading $build ==="
        echo "=> $build"
        cd $srcbase/$git_dir
        git checkout $build
        if [ $? -ne 0 ]
                then
                echo "checkout of $build failed" >> $1
        fi

        echo "=== Building $build ==="
        cd "$srcbase/$build_prefix$build"

        rm "$srcbase/$build_prefix$build/CmakeCache.txt"

        cmake "$srcbase/$git_dir" -DCMAKE_INSTALL_PREFIX="$installbase/$build_prefix$build" -DWITH_DEBUG=1 -DDOWNLOAD_BOOST=1 -DWITH_BOOST="$srcbase/$build_prefix$build/boost"
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
