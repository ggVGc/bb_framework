# !python

import os
import zipfile

def zipDir(out, r, pref=""):
  for root, dirs, files in os.walk(r):
    for f in files:
      p = os.path.join(root, f)
      rp = os.path.relpath(p, r)
      if not rp.startswith("."):
        print rp, p
        out.write(p, os.path.join("assets", pref, rp))




APPLICATION_PATH = os.path.join("..", "bounce")

if not os.path.exists("bin"):
  os.mkdir("bin")
outFile = zipfile.ZipFile("bin/assets.zip", "w")
zipDir(outFile, "src/lua", "framework")
zipDir(outFile, APPLICATION_PATH)
outFile.close() 
