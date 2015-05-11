#!/bin/bash

# prints usage information
usage ()
{
	echo "$VERSION"
	echo "
build.sh downloads from GitHub and builds specified MySQL servers

Usage: `basename $0` [option]

Options:

	-s --srcbase		directory, containing build directories
	-i --installbase	directory, where MySQL build should be instaled
	-b --builds		which branches to build
	-p --prefix		build prefix
	-g --gitdir		directory, where MySQL sources are located (relative to srcbase)
	-r --rootdir		home directory of the machine (root for srcbase and installbase)
	-v --version    	print version number, then exit
	-h --help		prints help, then exit
	"
}

# creates defaults values
initialize()
{
	# Place path to specific machine home directory here
	MACHINE_HOME_DIR=$HOME
	source $MACHINE_HOME_DIR/.bashrc
	
	srcbase=$MACHINE_HOME_DIR/src/
	installbase=$MACHINE_HOME_DIR/build
	builds="5.5 5.6 5.7"
	build_prefix="mysql-"
	git_dir="mysql-server"
	VERSION="build v0.4 (March 30 2015)"
}

parse()
{
	TEMP_BUILDS=""
	
	while getopts "hvs:i:b:p:g:r:" Option
	do
		case $Option in
		s) srcbase="$OPTARG";;
		i) installbase="$OPTARG";;
		b) TEMP_BUILDS="$TEMP_BUILDS $OPTARG";;
		p) build_prefix="$OPTARG";;
		g) git_dir="$OPTARG";;
		r) MACHINE_HOME_DIR="$OPTARG";;
		v) echo "$VERSION"; exit 0;;
		h) usage; exit 0;;
		esac
	done
	
	if [[ $TEMP_BUILDS ]]
	then
		builds="$TEMP_BUILDS"
	fi
}

build()
{
	for build in $builds
		do
		echo "=== Downloading $build ==="
		echo "=> $build"
		cd $srcbase/$git_dir
		git checkout -f $build
		git pull
		if [ $? -ne 0 ]
			then
			echo "checkout of $build failed" >> $1
		fi
	
		echo "=== Building $build ==="
		cd "$srcbase/$build_prefix$build"
	
		rm "$srcbase/$build_prefix$build/CmakeCache.txt"
	
		cmake "$srcbase/$git_dir" -DCMAKE_INSTALL_PREFIX="$installbase/$build_prefix$build" -DWITH_DEBUG=1 -DDOWNLOAD_BOOST=1 -DWITH_BOOST="$srcbase/$build_prefix$build/boost" -DENABLE_DTRACE=0
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
}

initialize
parse $@
build

exit 0
