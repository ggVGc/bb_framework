#!/bin/python
import os

def cleanMoonOutputs(path):
  for root, dirs, files in os.walk(path):
    for f in files:
      if f.endswith('.moon'):
        p = os.path.join(root, f)
        luaPath = p.replace('.moon', '.lua')
        if os.path.exists(luaPath):
          os.remove(luaPath)



if __name__ == '__main__':
  import sys
  cleanMoonOutputs(sys.argv[1])


