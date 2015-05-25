#!/bin/env sh

startDir=$(pwd)
thisDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )
cd $thisDir
src/nim_app/build.sh $1
./do_build.py -e $1
cd $startDir


