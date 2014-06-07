# !python

import os
import zipfile
import subprocess
import re


def translateMapping(originalString):
  lines = originalString.split('\n') 
  ret = ''
  for l in lines:
    m = re.search('([0-9]+):\[.*([0-9]+):', l)
    if m:
      luaInd = m.group(1)
      moonInd = m.group(2)
      ret += '["%s"]=%s,'%(luaInd, moonInd)
  return ret

def translateCompileErrorMapping(originalString):
  m = re.search('\[([0-9]+)\]', originalString)
  return 'Parse error', m.group(1)


def handleMoonFiles(zipOut, r, prefix, filePaths):
  sourceMappings = ''
  for path in filePaths:
    proc = subprocess.Popen(['moonc', path], stderr=subprocess.PIPE)
    output =  proc.communicate()[1]
    ret = proc.returncode

    luaFilePath = path.replace('.moon', '.lua')
    rp = os.path.relpath(luaFilePath, r)
    fileKey = (os.path.join(prefix, os.path.splitext(rp)[0]))

    if ret != 0:
      msg, rowNum = translateCompileErrorMapping(output)
      with open(luaFilePath, 'w') as out:
        out.write("error('%s')"%msg)
      sourceMappings+='["%s"]={["1"]=%s},'%(fileKey, rowNum)

    zipOut.write(luaFilePath, os.path.join("assets", prefix, rp))
    os.remove(luaFilePath)

    if ret == 0:
      mapping = subprocess.check_output(['moonc', '-X', path]) 
      sourceMappings+='["%s"]={%s},'%(fileKey, translateMapping(mapping))

  return sourceMappings

def zipDir(zipOut, r, prefix=""):
  moonFiles = []
  for root, dirs, files in os.walk(r):
    for f in files:
      p = os.path.join(root, f)
      rp = os.path.relpath(p, r)
      if not rp.startswith("."):
        if p.endswith('.moon'):
          moonFiles.append(p)
        else:
          print rp, '<-', p
          zipOut.write(p, os.path.join("assets", prefix, rp))
  return handleMoonFiles(zipOut, r, prefix, moonFiles)




import sys
APPLICATION_PATH = os.path.join("..", "bounce")
#APPLICATION_PATH = sys.argv[1]
print 'Application path:', APPLICATION_PATH

if not os.path.exists("bin"):
  os.mkdir("bin")
zipOutFile = zipfile.ZipFile("bin/assets.zip", "w")
moonSourceMappings = zipDir(zipOutFile, "src/lua", "framework")
moonSourceMappings += zipDir(zipOutFile, "src/luatest", "framework/test")
moonSourceMappings += zipDir(zipOutFile, APPLICATION_PATH)

with open('moon_source_mappings.lua', 'w') as out:
  out.write('return {%s}'%moonSourceMappings);
zipOutFile.write('moon_source_mappings.lua', os.path.join('assets', 'moon_source_mappings.lua'))
os.remove('moon_source_mappings.lua')

zipOutFile.close() 
