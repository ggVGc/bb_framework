#! /bin/env sh
thisDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )
nim c --parallelBuild:1 --experimental -p:$thisDir/../common/framework -p:$1 --cincludes:$thisDir/../common/framework  --noMain --noLinking --header:nimapp.h $thisDir/nimapp.nim
