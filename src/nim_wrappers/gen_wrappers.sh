#! /bin/env sh

foo(){
  c2nim --header ../common/framework/$1.h
  mv ../common/framework/$1.nim .
}

modules='rect texture quad graphics matrix2'



rm all.nim
touch all.nim
for n in $modules; do
  foo "$n"
  cat "$n.nim" >> all.nim
done
