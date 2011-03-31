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


outFile = zipfile.ZipFile("assets.zip", "w")
zipDir(outFile, "../framework/src/lua", "framework")
zipDir(outFile, "../../bounce")
outFile.close() 
