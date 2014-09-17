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


objectProcessor = (name, content, type, bounds) ->
  initContentPattern = '[%w%u%d_%-,%{%}%.=:"]*'
  initContent = ''
  if type == 'Bitmap'
    _,_,initContent = content\find'this%.initialize%(img%.([%w%._%d]*)'
    initContent = 'lib.texLoader, lib.sourceFolder..\'/images/'..initContent..'.png\''
    type = 'cjs.Bitmap'
  else
    _,_,initContent = content\find 'this%.initialize%(('..initContentPattern..')%);'
    initContent = (initContent\gsub ':', '=')\gsub('"', '')\gsub '-', '_'

  content = content\gsub 'this%.frame_(%d*) = function%(%) {([,%w%.%d_%(%);"\' \n\t]*)}', 'this.frame_%1 = function()\n%2\nend'
  content = content\gsub '= function%(mode,startPosition,loop%) {', ''
  content = content\gsub '= function%(%) {\n', ''
  content = content\gsub 'this%.initialize%('..initContentPattern..'%);', ''
  content = content\gsub 'this.([%u%w%d_]*) = new lib%.([%u%w%d_]*)%(([,%d%w"]*)%);', 'rawset(this, "%1", lib.%2.new(%3))'
  content = content\gsub 'cjs.Tween', 'framework.Tween'
  content = content\gsub ';\n', '\n'
  content = content\gsub ':', '='
  content = content\gsub '%[', '{'
  content = content\gsub '%]', '}'
  content = content\gsub 'Tween%.get%(%{%}%)', 'Tween.get({state={}})'
  content = content\gsub 'synched', 'independent'

  ret = 'lib.'..name..' = {}\n'
  ret=ret..'lib.'..name..'.new = function(mode, startPosition, loop)\n'
  ret=ret..'    local this = framework.'..type..'.new('..initContent..')\n'
  ret=ret..content
  if bounds
    ret=ret..'this.nominalBounds = {'..bounds..'}\n'
  ret=ret..'    return this\nend'
  --ret = name..' = framework.'..type..'.new!'
  ret



initInner = (identifier+S',{}.=')^1
libObjPatt1 = P'(lib.' * C(identifier^1)*C((anything-P'}).prototype')^1)*P'}).prototype = p = new cjs.'*C(identifier^1)*P'();'
libObjPatt2 = P'\np.nominalBounds = '*(P'null'+P'new cjs.Rectangle('*C(   (S'-0123456789.,')^1      )*P')')
libObjPatt = libObjPatt1*libObjPatt2
middle = P';\n\n'*P'\n'^-1


inFilePath = inFilePath\gsub '\\', '/'
ind = inFilePath\find ("/[^/]*$")
inFileDir = inFilePath\sub 1, ind-1
ind = inFileDir\find ("/[^/]*$")
inFileDir = inFileDir\sub ind+1

outContent = 'local lib = {}\nlib.texLoader = framework.cjs.texLoader or function(path)return framework.Texture.fromFile(path) end\nlib.sourceFolder=\''..inFileDir..'\'\n'
patt = ((libObjPatt/objectProcessor)*middle)^1
for obj in *{patt\match(content)}
  outContent = outContent..obj..'\n\n'

outContent = outContent..'return lib'


io.open(inFilePath\gsub('%.js', '.lua'), 'w')\write(outContent)


