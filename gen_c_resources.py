#!/bin/python2
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
        #os.system('luac -s -o '+fullPath.replace('.lua', '.luac')+' '+fullPath)
        p = PJ(prefix, os.path.relpath(fullPath, path))
        with open(fullPath) as rf:
          hexDict[p] = toHex(rf.read())

appPath = PJ("..", "bounce")
frameworkSrcPath = PJ('src', 'lua')

processPath(appPath)
processPath(frameworkSrcPath, 'framework')



if __name__ == '__main__':
  with open(PJ('src', 'gen', 'assets.c'), 'w') as f:
    f.write('static const int ASSET_COUNT=%i;\n'%len(hexDict.keys()))
    f.write('static const char* ASSET_KEYS[] = {')
    keys = hexDict.keys()
    for k in keys:
      f.write('"%s",'%k)
    f.write('};\n')
    #f.write('static const unsigned char* ASSET_DATA[] = {\n')

    f.write('static const unsigned int ASSET_SIZES[] = {')
    for k in keys:
      f.write('%i,'%(len(hexDict[k])/2))

    f.write('};\n')
    for i in range(len(keys)):
      k = keys[i]
      s = hexDict[k]

    for i in range(len(keys)):
      k = keys[i]
      s = hexDict[k]
      f.write('static const unsigned char ASSET_%i[] = {'%i)
      for i in range(0, len(s)/2):
        f.write('0x%s,'%s[i*2:i*2+2])
      f.write('};\n')

    #f.write('};\n')

    f.write('static const unsigned char* ASSET_DATA[] = {')
    for i in range(len(keys)):
      f.write('ASSET_%i,'%i);
    f.write('};')

  cleanMoonOutputs(appPath)
  cleanMoonOutputs(frameworkSrcPath)
  cleanMoonOutputs('src/luatest')




