lpeg = require 'lpeg'
P = lpeg.P
R = lpeg.R
S = lpeg.S
C = lpeg.C
V = lpeg.V

content = io.open('../bounce/flash/level.js')\read('*a')
content = content\gsub '// symbols:\n', ''
content = content\gsub '//', '--'

anywhere = (pattern) ->
  P { P(pattern) + 1 * V(1) }


ind, ind2 = content\find 'stage content:\n'
content = content\sub ind2+1

identifier = R'az'+R'AZ'+R'09'+P'_'
anything = P(1)


objectProcessor = (name, content, type) ->

  if type == 'Bitmap'
    _,_,imgName = content\find'this%.initialize%(img%.([%w%.]*)'
    type = 'cjs.Bitmap(\'data/flash_images/'..imgName..'.png\')'
  else
    type = type..'()'
  
  content = content\gsub '= function%(mode,startPosition,loop%) {', ''
  content = content\gsub '= function%(%) {\n', ''
  content = content\gsub 'this%.initialize%([%w%d_,%{%}%.]*%);', ''
  content = content\gsub 'new lib%.([%w%d_]*)%(%);', 'lib.%1.new()'
  content = content\gsub ';\n', '\n'
  content = content\gsub ':', '='

  ret = 'lib.'..name..' = {}\n'
  ret=ret..'lib.'..name..'.new = function()\n'
  ret=ret..'    local this = new framework.'..type..'\n'
  ret=ret..content
  ret=ret..'    return this\nend'
  --ret = name..' = framework.'..type..'.new!'
  ret



initInner = (identifier+S',{}.')^1
contentHeader = P' = function('*initInner*P') {\n\tthis.initialize('*initInner*P');\n'
contentHeader = P''
libObjPatt = P'(lib.' * C(identifier^1)*contentHeader*C((anything-P'}).')^1)*P'}).prototype = p = new cjs.'*C(identifier^1)*P'();'
middle = P'\np.nominalBounds = new cjs.Rectangle('*((R'09'+P',')^1)*P');\n\n\n'


outContent = 'lib = {}\n'
patt = ((libObjPatt/objectProcessor)*middle)^1
for obj in *{patt\match(content)}
  outContent = outContent..obj..'\n\n'

outContent = outContent..'return lib'


io.open('output.lua', 'w')\write(outContent)


