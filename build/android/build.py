
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
  shutil.copytree("../../../bounce", "assets") 
  os.system("ant debug")
  adb = "~/stuff/work/android/adt-bundle-linux-x86_64-20140702/sdk/platform-tools/adb "
  os.system(adb+"install -r bin/FrameworkTest-debug.apk")
  os.system(adb+"shell am kill com.jumpz.frameworktest/.FrameworkTest")
  os.system(adb+"shell am start -n com.jumpz.frameworktest/.FrameworkTest")
  #os.system("adb lolcat")
else:
  for e in errlines:
    fileName = e[:e.find(":")]
    fnameInd = fileName.rfind("/")+1
    fileName = fileName[fnameInd:]
    print e[fnameInd:-1]
