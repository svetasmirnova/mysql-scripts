#!/bin/bash

# copies MySQL tests to remote box

# prints usage information
usage ()
{
	echo "$VERSION"
	echo "
scp_test copies MySQL test files from t directory on local box to remote MySQL machine

Usage: `basename $0` [-v] [-d dirname] [-r user@host:path] [test ...]

Options:

	-d directory, which contains test files
	-r path to test directory on remote server, default: sveta@machine.foo.bar:~/machine/src/tests/t
	-v print version
	-h print this help
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
	TESTDIR=$HOME/src/tests
	MOVETO='sveta@machine.foo.bar:~/machine/src/tests/t'
	TESTS_TO_MOVE=""
	OLD_PWD=`pwd`
	VERSION="scp_test v0.3 (Dec 12 2014)"
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
			r) MOVETO="$OPTARG"; shift;;
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
		scp "$TESTDIR"/t/* "$MOVETO"
	else
		for test in $TESTS_TO_MOVE
	do
		scp "$TESTDIR/t/$test".{test,opt,init,sql,cfg,cnf} "$MOVETO"
	done
	fi
}

E_CDERROR=65

initialize
parse $@
copy

exit 0
