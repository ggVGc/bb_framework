
import shutil
import os
import sys


errlines = []
with open("buildoutput.txt") as f:
  for l in f.readlines():
    if "error" in l:
      errlines.append(l)

if len(errlines) == 0:
  #os.system("/cygdrive/c/android-ndk-r4b/ndk-build")
  if os.path.exists("assets"):
    shutil.rmtree("assets")
  shutil.copytree("../jumpz/assets", "assets") 
  os.system("ant debug")
  os.system("adb install -r bin/FrameworkTest-debug.apk")
  #os.system("adb lolcat")
else:
  for e in errlines:
    fileName = e[:e.find(":")]
    fnameInd = fileName.rfind("/")+1
    fileName = fileName[fnameInd:]
    print e[fnameInd:-1]
