import os
import shutil

def zipAll(zipPrgPath, dirPath, outPath):

  curDir = os.getcwd()
  zipPath = os.path.join(curDir, outPath)
  os.chdir(dirPath)

  cmd = ""
  #for root, dirs, files in os.walk("."):
    #for f in files:
      #cmd += " "+os.path.join(root, f)
  cmd = "./assets"

  
  if os.path.exists(outPath):
    #os.remove(outPath)    
    opt = "u"
  else:
    opt = "a"
  cmd = zipPrgPath+" "+opt+" "+zipPath+" "+cmd
  os.system(cmd)
  



if __name__ == '__main__':
  prgPath = "C:/\"Program Files\"/7-Zip/7z.exe" 
  zipAll(prgPath, "../jumpz", "bin/assets.zip")
