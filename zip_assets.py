# !python

import os
import sys
import zipfile
import subprocess
import re


LUA_EXE = 'lua'
MOON_COMPILER = 'simple_moon_compile.lua'
if 'win' in sys.platform:
  LUA_EXE = 'lua.exe'

def translateMapping(originalString):
  lines = originalString.split('\n') 
  ret = ''
  for l in lines:
    m = re.search('([0-9]+):\[.* ([0-9]+):', l)
    if m:
      luaInd = m.group(1)
      moonInd = m.group(2)
      ret += '{%s,%s},'%(luaInd, moonInd)
  return ret

def translateCompileErrorMapping(originalString):
  msg = originalString
  m = re.search('\[([0-9]+)\]', originalString)
  if m:
    msg = m.group(1)
  return 'Parse error', msg


def handleMoonFiles(zipOut, r, prefix, filePaths):
  sourceMappings = ''


  proc = subprocess.Popen([LUA_EXE, MOON_COMPILER]+filePaths, stderr=subprocess.PIPE)
  output =  proc.communicate()[1]
  print(output)
  ret = proc.returncode

  for path in filePaths:
    luaFilePath = path.replace('.moon', '.lua')
    rp = os.path.relpath(luaFilePath, r)
    fileKey = (os.path.join(prefix, os.path.splitext(rp)[0]))

    if ret != 0:
      msg, rowNum = translateCompileErrorMapping(output)
      with open(luaFilePath, 'w') as out:
        out.write("error('%s')"%msg)
      os.remove(luaFilePath)
      sourceMappings+='["%s"]={{1,%s}},'%(fileKey, rowNum)

    zipOut.write(luaFilePath, os.path.join("assets", prefix, rp))
    os.remove(luaFilePath)

    if ret == 0:
      mapping = subprocess.check_output([LUA_EXE, MOON_COMPILER, '-X', path])
      sourceMappings+='["%s"]={%s},'%(fileKey, translateMapping(mapping))

  return sourceMappings

def zipDir(zipOut, r, prefix=""):
  moonFiles = []
  for root, dirs, files in os.walk(r):
    for f in files:
      p = os.path.join(root, f)
      rp = os.path.relpath(p, r)
      if not rp.startswith(".") and not 'moonscript' in p and not p.endswith('.zip') and (p.endswith('.lua') or p.endswith('.moon') or p.endswith('.png') or p.endswith('.xml') or p.endswith('.txt')):
        if p.endswith('.moon'):
          moonFiles.append(p)
        else:
          #print rp, '<-', p
          zipOut.write(p, os.path.join("assets", prefix, rp))
  return handleMoonFiles(zipOut, r, prefix, moonFiles)


import sys
appPath = os.path.join("..", "bounce")
outZipPath = os.path.join('bin', 'assets.zip')
frameworkSrcPath = os.path.join('src', 'lua')
if len(sys.argv) > 1:
  appPath = sys.argv[1]
if len(sys.argv) > 2:
  outZipPath = sys.argv[2]
if len(sys.argv) > 3:
  frameworkSrcPath = sys.argv[3]

if not os.path.exists(appPath):
  raise Exception('Invalid path: %s'%appPath)

print 'Application path:', appPath
print 'Zip path:', outZipPath

zipOutFile = zipfile.ZipFile(outZipPath, "w")
moonSourceMappings = zipDir(zipOutFile, frameworkSrcPath, "framework")
#moonSourceMappings += zipDir(zipOutFile, "src/luatest", "framework/test")
moonSourceMappings += zipDir(zipOutFile, appPath)

with open('moon_source_mappings.lua', 'w') as out:
  out.write('return {%s}'%moonSourceMappings);
zipOutFile.write('moon_source_mappings.lua', os.path.join('assets', 'moon_source_mappings.lua'))
os.remove('moon_source_mappings.lua')

zipOutFile.close() 
print ''
print 'DONE'
