#!/bin/bash

# runs MySQL tests in all source directories

# prints usage information
usage ()
{
	echo "$VERSION"
	echo "
ar_test copies MySQL test files from t to archive folder

Usage: `basename $0` [-v] [-d dirname] [test ...]

Options:

	-d    directory, contains test files
	-v    print version
	-h    print this help
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
	MACHINE_HOME_DIR=$HOME/blade12
	TESTDIR=$MACHINE_HOME_DIR/src/tests
	TESTS_TO_MOVE=""
	OLD_PWD=`pwd`
	VERSION="ar_test v0.2 (Dec 09 2014)"
}

# parses arguments/sets values to defaults
parse()
{	
	while getopts "vhd:" Option
	do
		case $Option in
			v) echo "$VERSION"; shift;;
			h) usage; exit 0;;
			d) TESTDIR="$OPTARG"; shift;;
			*) usage; exit 0;;
		esac
	done
	
	TESTS_TO_MOVE="$@"
}

# copies test to source directories
copy()
{
	if [[ "xx" = x"$TESTS_TO_MOVE"x ]]
	then
		cp "$TESTDIR"/t/* "$TESTDIR"/archive 2>/dev/null
	else
		for test in $TESTS_TO_MOVE
		do
			cp "$TESTDIR/t/$test".{test,opt,init,sql} "$TESTDIR"/archive 2>/dev/null
		done
	fi
}

# removes tests and results from MySQL sources directories
cleanup()
{
	if [[ "xx" = x"$TESTS_TO_MOVE"x ]]
	then
		rm "$TESTDIR"/t/* 2>/dev/null
		rm "$TESTDIR"/r/*/* 2>/dev/null
	else
		for test in $TESTS_TO_MOVE
		do
			rm "$TESTDIR/t/$test".{test,opt,init,sql} 2>/dev/null
			rm "$TESTDIR/r/"*"/$test".{test,opt,init,sql} 2>/dev/null
		done
	fi
}

E_CDERROR=65

initialize
parse $@
copy
cleanup

exit 0
