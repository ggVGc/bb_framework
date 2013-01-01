

let s:projectName = "skeleton"

""""""""""First load""""""""""""""""
if !exists("s:didScript") 
  let s:didScript = 1

  exec "lcd ".g:projectScriptDir
endif
""""""""""""""""""""""""""""""""""""

function! RUNN()
  let curDir=getcwd()
  exec "lcd ".g:projectScriptDir."/../framework/"
  if has('win32') || has('win64') 
    silent exec "!python zip_assets.py ".s:projectName
    silent exec "lcd bin"
    silent !framework.exe
    silent exec "lcd "curDir
  else
    silent exec "!xterm -e python zip_assets.py ../".s:projectName
    silent exec "lcd bin"
    silent !xterm -e ./framework &
    silent exec "lcd "curDir
  endif

  redraw!
endfun

map <buffer>  <F5> :call RUNN()<CR>


let s:p = fnamemodify(g:projectScriptDir, ":p")
let cmd = "set path+=".s:p."../framework/src/lua"
exec cmd

silent exec "!ctags -R ".s:p."*"
exec "set tags+=".s:p."../framework/src/lua/tags"
