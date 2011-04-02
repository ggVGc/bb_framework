
import os

def buildLib(outfile, srcDirs, srcFiles, cflags):
  objDir = outfile+"_obj"

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
    if not os.path.exists("obj"):
      os.mkdir("obj")
    out = os.path.join("obj", os.path.split(f)[1]+".o")
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
  buildLib("libluaa.a", ["./../deps_src/lua"], [], "")

def buildMinizip():
  files =[
      "./../deps_src/minizip/unzip.c",
      "./../deps_src/minizip/mztools.c",
      "./../deps_src/minizip/ioapi.c"
      ]

  buildLib("libminizipa.a", [], files, "")

def buildPng():
  buildLib("libpnga.a", ["./../deps_src/libpng"], [], "")


def buildFramework():
  srcDirs = [
      "./../src/common",
      "./../src/common/framework",
      "./../src/linux",
      "./../src/linux/framework"
      ]
 
  srcFiles = [
      " ./../src/win32/framework/util.c",
      " ./../src/gles_imp.c",
      #" ./../src/common/framework_wrap.cxx"
      ]


  cflags =" ".join([
      "-I./../deps_src/gles_headers",
      "-I./../deps_src/libpng",
      "-I./../deps_src/lua",
      "-I./../deps_src/minizip",
      "-I./../src/common",
      "-I./../src/common/framework",
      ])
  
  return buildApp("framework",srcDirs, srcFiles,cflags, "-g -L"+os.getcwd()+" -lm -ldl -lpnga -lminizipa -lluaa -lGL -lGLU -lsfml-graphics -lsfml-window -lsfml-system -lsfml-audio")



if __name__ == '__main__':
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
