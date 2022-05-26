let s:ruby_expander = '/'.join(split(expand('<sfile>:p:h'), '/')[0:-2], '/').'/bin/expander.rb'

fu! s:expander()
  call append('.', systemlist('ruby '.s:ruby_expander.' "'.&ft.'.'.getline('.').'"'))
  .delete
endfu

ino jk <Esc>:call <SID>expander()<CR>

