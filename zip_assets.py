# !python

import os
import getopt
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


def handleMoonFiles(zipOut, r, prefix, filePaths, stripCode):
  sourceMappings = ''
  for path in filePaths:
    luaFilePath = path.replace('.moon', '.lua')
    rp = os.path.relpath(luaFilePath, r)
    fileKey = (os.path.join(prefix, os.path.splitext(rp)[0]))

    proc = subprocess.Popen([LUA_EXE, MOON_COMPILER]+[path], stderr=subprocess.PIPE)
    output =  proc.communicate()[1]
    ret = proc.returncode
    if ret != 0:
      msg, rowNum = translateCompileErrorMapping(output)
      with open(luaFilePath, 'w') as out:
        out.write("error('%s')"%msg)
      sourceMappings+='["%s"]={{1,%s}},'%(fileKey, rowNum)
    else:
      mapping = subprocess.check_output([LUA_EXE, MOON_COMPILER, '-X', path])
      sourceMappings+='["%s"]={%s},'%(fileKey, translateMapping(mapping))

    if not stripCode:
      zipOut.write(luaFilePath, os.path.join("assets", prefix, rp))
      os.remove(luaFilePath)

  return sourceMappings

def zipDir(zipOut, r, stripCode=False, prefix=""):
  convertScript = (subprocess.check_output([LUA_EXE, 'simple_moon_compile.lua', '-stdout', 'convert_flash_export.moon']))

  moonFiles = []

  for root, dirs, files in os.walk(r):
    for f in files:
      if f.endswith('.fla'):
        htmlPath = os.path.join(root, f.replace('.fla','.html'))
        if os.path.exists(htmlPath):
          os.remove(htmlPath)
        jsPath = os.path.join(root, f.replace('.fla', '.js'))
        if os.path.exists(jsPath):
          p = subprocess.Popen([LUA_EXE, '-', jsPath], stdin=subprocess.PIPE)
          p.communicate(input=convertScript)

  for root, dirs, files in os.walk(r):
    for f in files:
      p = os.path.join(root, f)
      rp = os.path.relpath(p, r)
      if not rp.startswith(".") and not 'moonscript' in p and ((not stripCode and p.endswith('.lua')) or p.endswith(('.moon', '.png', '.xml','.txt'))):
        if p.endswith('.moon'):
          moonFiles.append(p)
        else:
          #print rp, '<-', p
          zipOut.write(p, os.path.join("assets", prefix, rp))
  return handleMoonFiles(zipOut, r, prefix, moonFiles, stripCode)


if __name__ == '__main__':
  import sys
  appPath = os.path.join("..", "bounce")
  outZipPath = os.path.join('bin', 'assets.zip')
  frameworkSrcPath = os.path.join('src', 'lua')
  
  opts, args = getopt.getopt(sys.argv[1:],"ts")

  stripCode = ('-s','') in opts

  if stripCode:
    print 'Stripping code'

  if len(args)>0:
    appPath = args[0]
  if len(args)>1:
    outZipPath = args[1]
  if len(args)>2:
    frameworkSrcPath = args[2]

  if not os.path.exists(appPath):
    raise Exception('Invalid path: %s'%appPath)

  print 'Application path:', appPath
  print 'Zip path:', outZipPath

  zipOutFile = zipfile.ZipFile(outZipPath, "w")
  moonSourceMappings = zipDir(zipOutFile, frameworkSrcPath, stripCode, "framework")
  if ('-t','') in opts:
    print 'Including test sources'
    moonSourceMappings += zipDir(zipOutFile, "src/luatest", "framework/test", stripCode)
    moonSourceMappings += zipDir(zipOutFile, "src/luatest/data", "framework/testdata", stripCode)
  moonSourceMappings += zipDir(zipOutFile, appPath, stripCode)

  with open('moon_source_mappings.lua', 'w') as out:
    out.write('return {%s}'%moonSourceMappings.replace("\\", "/"));
  if not stripCode:
    zipOutFile.write('moon_source_mappings.lua', os.path.join('assets', 'moon_source_mappings.lua'))
  os.remove('moon_source_mappings.lua')

  zipOutFile.close() 
  print ''
  print 'DONE'
