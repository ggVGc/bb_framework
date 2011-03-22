if !exists("s:didScript") 
  let s:didScript = 0
  exec "cd ".g:projectScriptDir

python<<EOF

import vim
import os
exts = 'c h cpp lua py sh vim sh'.split()
ig = []
p = vim.eval("g:projectScriptDir")
for root, dirs, files in os.walk(p):
  for f in files:
    _, e = os.path.splitext(f)
    e = e[1:]
    if e!="" and not e in exts and not e in ig:
      ig.append(e)

ig = map(lambda x: "*."+x, ig)
cmd = "setlocal wildignore+=%s" % (",".join(ig))
vim.command(cmd)

EOF
setlocal wildignore+=deps_*

CommandTFlush

endif

function! RunJumpz()
  let curDir=getcwd()
  exec "cd ".g:projectScriptDir."/project_linux/"
  silent !xterm -e sh zipbuildrun.sh &
  silent exec "cd "curDir
endfun

map <buffer>  <F5> :call RunJumpz()<CR>


let s:x = fnamemodify(g:projectScriptDir, ":p")
exec "set path+=".s:x."src/common/"
exec "set path+=".s:x."src/lua/"
exec "set path+=".s:x."src/android/"
exec "set path+=".s:x."src/linux/"
exec "set path+=".s:x."src/win3/"
exec "set path+=".s:x."/deps_src/lua"
