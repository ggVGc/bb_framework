#! /bin/env sh
nim c --parallelBuild:1 -p:../common/framework --include:rect.nim --include:camera.nim --include:quad.nim --cincludes:../common/framework  --noMain --noLinking --header:nimapp.h nimapp.nim
