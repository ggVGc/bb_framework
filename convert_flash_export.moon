lpeg = require 'lpeg'
P = lpeg.P
R = lpeg.R
S = lpeg.S
C = lpeg.C
V = lpeg.V


inFilePath = arg[1]
content = io.open(inFilePath)\read('*a')
content = content\gsub '// symbols:\n', ''
content = content\gsub '//', '--'

anywhere = (pattern) ->
  P { P(pattern) + 1 * V(1) }


ind, ind2 = content\find 'stage content:\n'
content = content\sub ind2+1

identifier = R'az'+R'AZ'+R'09'+P'_'
anything = P(1)


objectProcessor = (name, content, type) ->

  initContent = ''
  if type == 'Bitmap'
    _,_,initContent = content\find'this%.initialize%(img%.([%w%._%d]*)'
    initContent = 'lib.sourceFolder..\'/images/'..initContent..'.png\''
    type = 'cjs.Bitmap'
  else
    _,_,initContent = content\find 'this%.initialize%(([%w%u%d_,%{%}%.=:]*)%);'
  initContent = initContent\gsub ':', '='

  content = content\gsub '= function%(mode,startPosition,loop%) {', ''
  content = content\gsub '= function%(%) {\n', ''
  content = content\gsub 'this%.initialize%([%w%u%d_,%{%}%.=:]*%);', ''
  content = content\gsub 'new lib%.([%u%w%d_]*)%(([,%d%w"]*)%);', 'lib.%1.new(%2)'
  content = content\gsub 'cjs.Tween', 'framework.Tween'
  content = content\gsub ';\n', '\n'
  content = content\gsub ':', '='

  ret = 'lib.'..name..' = {}\n'
  ret=ret..'lib.'..name..'.new = function(mode, startPosition, loop)\n'
  ret=ret..'    local this = framework.'..type..'.new('..initContent..')\n'
  ret=ret..content
  ret=ret..'    return this\nend'
  --ret = name..' = framework.'..type..'.new!'
  ret



initInner = (identifier+S',{}.=')^1
--contentHeader = P' = function('*initInner*P') {\n\tthis.initialize('*initInner*P');\n'
contentHeader = P''
libObjPatt = P'(lib.' * C(identifier^1)*contentHeader*C((anything-P'}).prototype')^1)*P'}).prototype = p = new cjs.'*C(identifier^1)*P'();'
middle = P'\np.nominalBounds = new cjs.Rectangle('*((S'-0123456789.,')^1)*P');\n\n'*P'\n'^-1


inFilePath = inFilePath\gsub '\\', '/'
ind = inFilePath\find ("/[^/]*$")
inFileDir = inFilePath\sub 1, ind-1
ind = inFileDir\find ("/[^/]*$")
inFileDir = inFileDir\sub ind+1

outContent = 'local lib = {}\nlib.sourceFolder=\''..inFileDir..'\'\n'
patt = ((libObjPatt/objectProcessor)*middle)^1
for obj in *{patt\match(content)}
  outContent = outContent..obj..'\n\n'

outContent = outContent..'return lib'


io.open(inFilePath\gsub('%.js', '.lua'), 'w')\write(outContent)


