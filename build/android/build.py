
import shutil
import os
import sys
import subprocess

LUA_EXE = 'lua'
MOON_COMPILER_DIR = '../..'
MOON_COMPILER = 'simple_moon_compile.lua'

def handleMoonFile(path):
  print path
  absp = os.path.abspath(path)
  cwd = os.getcwd()
  os.chdir(MOON_COMPILER_DIR)
  proc = subprocess.Popen([LUA_EXE, MOON_COMPILER]+[absp], stderr=subprocess.PIPE)
  output =  proc.communicate()[1]
  ret = proc.returncode
  os.chdir(cwd)
  if ret != 0:
    pass
    #msg, rowNum = translateCompileErrorMapping(output)
    #with open(luaFilePath, 'w') as out:
      #out.write("error('%s')"%msg)
    #sourceMappings+='["%s"]={{1,%s}},'%(fileKey, rowNum)
  else:
    pass
    #mapping = subprocess.check_output([LUA_EXE, MOON_COMPILER, '-X', path])
    #sourceMappings+='["%s"]={%s},'%(fileKey, translateMapping(mapping))


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
  shutil.copytree("../../src/lua", "assets/framework") 
  for root, dirs, files in os.walk('assets'):
    for f in files:
      if f.endswith('.moon'):
        handleMoonFile(os.path.join(root, f))

  os.system("ant debug")
  adb = "~/stuff/work/android/adt-bundle-linux-x86_64-20140702/sdk/platform-tools/adb "
  os.system(adb+"install -r bin/FrameworkTest-debug.apk")
  os.system(adb+"shell am kill com.jumpz.frameworktest/.FrameworkTest")
  os.system(adb+"shell am start -n com.jumpz.frameworktest/.FrameworkTest")
else:
  for e in errlines:
    fileName = e[:e.find(":")]
    fnameInd = fileName.rfind("/")+1
    fileName = fileName[fnameInd:]
    print e[fnameInd:-1]
