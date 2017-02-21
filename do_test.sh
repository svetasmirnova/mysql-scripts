#!/bin/bash

# runs MySQL tests in all source directories

# prints usage information
usage ()
{
	echo "$VERSION"
	echo "
do_test copies MySQL test files from any place
to each of source directory, then runs them

Usage: `basename $0` [option]... [testfile ...]
	or `basename $0` [option]... -d dirname [test ...]
	or `basename $0` [option]... [-b build [build option]... ]...

Options:

	-d --testdir    directory, contains test files
	-s --builddir   directory, contains mysql directories
	-b --build      mysql directory
	-c --clean      remove tests from mysql directory after execution
	-t --suite      suite where to put test
	-v --version    print version number, then exit
	-h --help       print this help, then exit

You can also pass any option to mysqltest program.
	"
}

# error exit
error()
{
	printf "$@" >&2
	exit $E_CDERROR
}

# creates defaults values
initialize()
{
	MACHINE_HOME_DIR=$HOME
	TESTDIR=$MACHINE_HOME_DIR/src/tests
	BUILDDIR=$MACHINE_HOME_DIR/build
	BUILDS="mysql-5.5 mysql-5.6 mysql-5.7 mysql-8.0"
	CLEAN=0 #false
	MYSQLTEST_OPTIONS="--record --force"
	TESTS_TO_PASS=""
	TESTS=""
	SUITE=""
	SUITEDIR=""
	OLD_PWD=`pwd`
	VERSION="do_test v0.4 (September 27 2016)"
}

# parses arguments/sets values to defaults
parse()
{
	TEMP_BUILDS=""
	
	while getopts "cvhd:s:b:t:" Option
	do
		case $Option in
			c) CLEAN=1;;
			v) echo "$VERSION";;
			h) usage; exit 0;;
			d) TESTDIR="$OPTARG";;
			s) BUILDDIR="$OPTARG";;
			b) TEMP_BUILDS="$TEMP_BUILDS $OPTARG";;
			t) SUITE="$OPTARG"; SUITEDIR="/suite/$SUITE"; MYSQLTEST_OPTIONS="$MYSQLTEST_OPTIONS --suite=$SUITE";;
			*) usage; exit 0; ;;
		esac
	done
	if [[ $TEMP_BUILDS ]]
	then
		BUILDS="$TEMP_BUILDS"
	fi
}

# copies test to source directories
copy()
{
	cd "$TESTDIR/t"
	TESTS_TO_PASS=`ls *.test 2>/dev/null | sed s/.test$//`
	cd $OLD_PWD
	for build in $BUILDS
	do
		#cp -i for reject silent overload
		cp "$TESTDIR"/t/*.{test,opt,init,sql,cfg} "$BUILDDIR/$build/mysql-test$SUITEDIR/t" 2>/dev/null
	done
}

# runs tests
run()
{
	for build in $BUILDS
	do
		cd "$BUILDDIR/$build/mysql-test"
		perl ./mysql-test-run.pl $MYSQLTEST_OPTIONS $TESTS_TO_PASS
	done
	cd $OLD_PWD
}

# copies result and log files to the main directory
get_result()
{
	for build in $BUILDS
	do
		ls "$TESTDIR/r/$build" 2>/dev/null
		if [[ 0 -ne $? ]]
		then
			mkdir "$TESTDIR/r/$build"
		fi
		for test in $TESTS_TO_PASS
		do
			cp "$BUILDDIR/$build/mysql-test$SUITEDIR/r/$test".{log,result} "$TESTDIR/r/$build" 2>/dev/null
		done
	done
}

# removes tests and results from MySQL sources directories
cleanup()
{
	if [[ 1 -eq $CLEAN ]]
	then
		for build in $BUILDS
		do
			for test in $TESTS_TO_PASS
			do
				rm "$BUILDDIR/$build/mysql-test$SUITEDIR/r/$test".{log,result} 2>/dev/null
				rm "$BUILDDIR/$build/mysql-test$SUITEDIR/t/$test.test"
			done
		done
	fi
}

# shows results
show()
{
	for build in $BUILDS
	do
		echo "=====$build====="
		for test in $TESTS_TO_PASS
		do
			echo "=====$test====="
			cat "$TESTDIR/r/$build/$test".{log,result} 2>/dev/null
			echo
		done
		echo
	done
}

E_CDERROR=65

#usage
initialize
parse $@
copy
run
get_result
cleanup
show

exit 0
