#!/usr/bin/python

import os
import sys

def buildLib(outfile, srcDirs, srcFiles, cflags):
  objDir = os.path.join("obj", os.path.split(outfile)[1])

  if not os.path.exists(objDir):
    os.mkdir(objDir)

  global objFiles
  objFiles = ""

  def compile(fullPath):
    global objFiles
    x , fileName = os.path.split(fullPath)
    objFile = os.path.join(objDir, fileName[:-2]+".o")
    objFiles += " "+objFile
    cmd = ("cc "+cflags+" -c -o "+objFile+" "+fullPath)
    print cmd
    os.system(cmd)

  for d in srcDirs:
    for x in os.listdir(d):
      if x.endswith(".c"):
        compile(os.path.join(d, x))
        
  for f in srcFiles:
    print objFiles+" 2"
    compile(f)


  cmd = "ar -cvq "+outfile+" "+objFiles
  print cmd
  return os.system(cmd)




def buildApp(outfile, srcDirs, srcFiles, cflags, linkFlags):

  cfiles = srcFiles
  cppfiles = ""
  for d in srcDirs:
    for f in os.listdir(d):
      if f.endswith(".c"):
        cfiles.append( os.path.join(d, f) )
      if f.endswith(".cpp"):
        cppfiles+=" "+os.path.join(d, f)

  ret = 0
  ofiles = ""
  for f in cfiles:
    if not os.path.exists("obj/framework"):
      os.mkdir("obj/framework")
    out = os.path.join("obj","framework", os.path.split(f)[1]+".o")
    ofiles += " "+out
    ofiles
    cmd = "gcc "+cflags+" -c "+f+" -o "+out
    print cmd
    ret = os.system(cmd)
    if ret != 0:
      break

  if ret != 0:
    return ret 

  files = cppfiles+" "+ofiles

  cmd = "g++ "+cflags+" "+files+" -o "+outfile+" "+linkFlags
  print cmd
  return os.system(cmd)


  #objDir = outfile+"_obj"

  #if not os.path.exists(objDir):
    #os.mkdir(objDir)

  #global objFiles
  #objFiles = ""

  #def compile(fullPath):
    #global objFiles
    #x , fileName = os.path.split(fullPath)
    #objFile = os.path.join(objDir, fileName[:-2]+".o")
    #objFiles += " "+objFile
    #cmd = ("cc "+cflags+" -c -o "+objFile+" "+fullPath)
    #print cmd
    #os.system(cmd)

  #for d in srcDirs:
    #for x in os.listdir(d):
      #if x.endswith(".c"):
        #compile(os.path.join(d, x))
        
  #for f in srcFiles:
    #print objFiles+" 2"
    #compile(f)


  #cmd = "gcc "+linkFlags+objFiles+" -o "+outfile
  #print cmd
  #os.system(cmd)



def buildLua():
  buildLib("bin/libluaa.a", ["./deps/common/lua"], [], "")

def buildMinizip():
  files =[
      "./deps/common/minizip/unzip.c",
      "./deps/common/minizip/mztools.c",
      "./deps/common/minizip/ioapi.c"
      ]

  buildLib("bin/libminizipa.a", [], files, "")

def buildPng():
  buildLib("bin/libpnga.a", ["./deps/common/libpng"], [], "")


def buildFramework():
  srcDirs = [
      "./src/common",
      "./src/common/framework",
      "./src/sfml",
      "./src/sfml/framework"
      ]
 
  srcFiles = [
      " ./src/gles_imp.c",
      #" ./src/common/framework_wrap.cxx"
      ]


  cflags =" ".join([
      "-I./deps/common/gles_headers",
      "-I./deps/common/libpng",
      "-I./deps/common/lua",
      "-I./deps/common/minizip",
      "-I./src/common",
      "-I./src/common/framework",
      "-I./SFML-1.6/include"
      ])

  if sys.platform == "darwin":
    cflags += " -I/Users/walt/sfml/include "

    return buildApp("bin/framework",srcDirs, srcFiles,cflags, "-g -L"+os.getcwd()+"/bin -lm -ldl -lpnga -lz -lminizipa -lluaa -framework OpenGL -framework sfml-graphics -framework sfml-window -framework sfml-system -framework sfml-audio")
  else:
      return buildApp("bin/framework",srcDirs, srcFiles,cflags, "-g -L"+os.getcwd()+"/bin -lm -ldl -lpnga -lz -lminizipa -lluaa -lGL -lGLU -l:libsfml-graphics.so.1.6 -l:libsfml-window.so.1.6 -l:libsfml-system.so.1.6 -l:libsfml-audio.so.1.6")



if __name__ == '__main__':
  if not os.path.exists("obj"):
    os.mkdir("obj")
  if not os.path.exists("bin"):
    os.mkdir("bin")
  import sys
  compileLibs = True
  if len(sys.argv) >= 2 and sys.argv[1] == "only_exe":
    compileLibs = False
  if compileLibs:
    buildLua()
    buildMinizip()
    buildPng()
  ret = buildFramework()
  if ret >=255:
    ret = 255
  print ret
  sys.exit(ret)
