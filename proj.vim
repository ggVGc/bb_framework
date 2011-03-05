if !exists("s:didScript") 
  let s:didScript = 0
  exec "cd ".g:projectScriptDir

  set wildignore+=*deps_*
endif

function! RunJumpz()
  let curDir=getcwd()
  exec "cd ".g:projectScriptDir."/project_linux/"
  silent !xterm -e sh zipbuildrun.sh &
  silent exec "cd "curDir
endfun

map <buffer>  <F5> :call RunJumpz()<CR>


let cmd = "set path+=".fnamemodify(g:projectScriptDir, ":p")."/framework/deps_src/lua"
exec cmd
