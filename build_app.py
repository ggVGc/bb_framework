#!/bin/env python2

import getopt
import os
import shutil
import sys
import subprocess
import re

LUA_EXE = 'lua'
MOON_COMPILER = 'simple_moon_compile.lua'

EXTENSIONS = ('.moon', '.png', '.xml', '.it','.txt', '.ogg', '.xm')

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


def handleMoonFiles(r, filePaths):
  sourceMappings = ''
  for path in filePaths:
    luaFilePath = path.replace('.moon', '.lua')
    rp = os.path.relpath(luaFilePath, r)
    fileKey = (os.path.join(os.path.splitext(rp)[0]))

    proc = subprocess.Popen([LUA_EXE, MOON_COMPILER]+[path], stderr=subprocess.PIPE)
    output =  proc.communicate()[1]
    sys.stdout.write(output)
    ret = proc.returncode
    if ret != 0:
      msg, rowNum = translateCompileErrorMapping(output)
      with open(luaFilePath, 'w') as out:
        out.write("error('%s')"%msg)
      sourceMappings+='["%s"]={{1,%s}},'%(fileKey, rowNum)
    else:
      mapping = subprocess.check_output([LUA_EXE, MOON_COMPILER, '-X', path])
      sourceMappings+='["%s"]={%s},'%(fileKey, translateMapping(mapping))

  return sourceMappings

convertScript = (subprocess.check_output([LUA_EXE, 'simple_moon_compile.lua', '-stdout', 'convert_flash_export.moon']))

def compileDir(r, moonFiles=None):
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

  localMoonFiles = []
  for root, dirs, files in os.walk(r):
    for f in files:
      p = os.path.join(root, f)
      rp = os.path.relpath(p, r)
      if not rp.startswith(".") and not 'moonscript' in p and p.endswith('.moon'):
        if moonFiles:
          moonFiles.append(p)
        localMoonFiles.append(p)

  return handleMoonFiles(r, localMoonFiles)

opts, args = getopt.getopt(sys.argv[1:],"tsf")
stripCode = ('-s','') in opts

outDir = 'bin/compiled'
if not os.path.exists(outDir):
  os.mkdir(outDir)

frameworkSrcPath = os.path.join('src', 'lua')
if len(args)>1:
  frameworkSrcPath = args[1]

if len(args)<=0:
  print('Please supply root path')
else:
  rootPath = args[0]
  appMoonFiles = []
  frameworkMoonFiles = []
  moonSourceMappings = compileDir(rootPath, appMoonFiles)
  #moonSourceMappings = compileDir(frameworkSrcPath, frameworkMoonFiles)
  if ('-t','') in opts:
    print('Including test sources')
    moonSourceMappings += compileDir("src/luatest", "framework/test")
    moonSourceMappings += compileDir("src/luatest/data", "framework/testdata")

  with open(os.path.join(outDir, 'moon_source_mappings.lua'), 'w') as out:
    out.write('return {%s}'%moonSourceMappings.replace("\\", "/"));

  
  def copyMoonFiles(files, srcPath, destSubPath=''):
    for f in files:
      f = f.replace('.moon', '.lua')
      dest = os.path.join(outDir, destSubPath, os.path.relpath(f, srcPath))
      d = os.path.split(dest)[0]
      if not os.path.exists(d):
        os.makedirs(d)
      shutil.copy(f, dest)

  copyMoonFiles(appMoonFiles, rootPath)
  copyMoonFiles(frameworkMoonFiles, frameworkSrcPath, 'framework')

  if ('-f', '') in opts:
    if not os.path.exists(os.path.join('bin', 'framework_src')):
      os.makedirs(os.path.join('bin', 'framework_src'))
    frameworkDest = os.path.join('bin', 'framework_src', 'framework')
    if os.path.exists(frameworkDest):
      shutil.rmtree(frameworkDest)
    shutil.copytree(frameworkSrcPath, frameworkDest)
    compileDir(frameworkDest)
      
  print('')
  print('Done')
