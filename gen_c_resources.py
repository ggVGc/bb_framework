#!/bin/python
import os
from clean_moon_outputs import cleanMoonOutputs

PJ = os.path.join

def toHex(s):
  return "".join("{:02x}".format(ord(c)) for c in s)

hexDict = {}

def processPath(path, prefix=''):
  for root, dirs, files in os.walk(path):
    for f in files:
      if f.endswith('.lua'):
        fullPath = PJ(root, f)
        os.system('luac -s -o '+fullPath.replace('.lua', '.luac')+' '+fullPath)
        p = PJ(prefix, os.path.relpath(fullPath, path))
        with open(fullPath) as rf:
          hexDict[p] = toHex(rf.read())

appPath = PJ("..", "bounce")
frameworkSrcPath = PJ('src', 'lua')

processPath(appPath)
processPath(frameworkSrcPath, 'framework')



if __name__ == '__main__':
  with open(PJ('src', 'gen', 'assets.c'), 'w') as f:
    f.write('static const ASSET_COUNT=%i;\n'%len(hexDict.keys()))
    f.write('static const char* ASSET_KEYS[] = {')
    for k in hexDict:
      f.write('"%s",'%k)
    f.write('};\n')
    f.write('static const char* ASSET_DATA[] = {\n')
    for k in hexDict:
      f.write('"%s",\n'%hexDict[k])
    f.write('};\n')

  cleanMoonOutputs(appPath)
  cleanMoonOutputs(frameworkSrcPath)
  cleanMoonOutputs('src/luatest')




