" Copyright (c) 2019 Liu-Cheng Xu
" MIT License
" vim: ts=2 sw=2 sts=2 et

if exists('*bufwinid')
  function! s:GotoSourceWindow() abort
    let winid = t:vista.source.get_winid()
    if winid != -1
      noautocmd call win_gotoid(winid)
    else
      return vista#error#('Cannot find the source window id')
    endif
  endfunction
else
  function! s:GotoSourceWindow() abort
    " t:vista.source.winnr is not always correct.
    let winnr = t:vista.source.get_winnr()
    if winnr != -1
      noautocmd execute winnr.'wincmd w'
    else
      return vista#error#('Cannot find the target window')
    endif
  endfunction
endif

function! vista#source#GotoWin() abort
  call s:GotoSourceWindow()

  " Floating window relys on BufEnter event to be closed automatically.
  if exists('#VistaFloatingWin')
    doautocmd BufEnter VistaFloatingWin
  endif
endfunction

" Update the infomation of source file to be processed,
" including whose bufnr, winnr, fname, fpath
function! vista#source#Update(bufnr, winnr, ...) abort
  let t:vista.source.bufnr = a:bufnr
  let t:vista.source.winnr = a:winnr

  if a:0 == 1
    let t:vista.source.fname = a:1
  elseif a:0 == 2
    let t:vista.source.fname = a:1
    let t:vista.source.fpath = a:2
  endif
endfunction

function! s:ApplyPeek(lnum, tag) abort
  silent execute 'normal!' a:lnum.'z.'
  let [_, start, _] = matchstrpos(getline('.'), a:tag)
  call vista#util#Blink(1, 100, [a:lnum, start+1, strlen(a:tag)])
endfunction

if exists('*win_execute')
  function! vista#source#PeekSymbol(lnum, tag) abort
    call win_execute(t:vista.source.winid, 'noautocmd call s:ApplyPeek(a:lnum, a:tag)')
  endfunction
else
  function! vista#source#PeekSymbol(lnum, tag) abort
    call vista#win#Execute(t:vista.source.get_winnr(), function('s:ApplyPeek'), a:lnum, a:tag)
  endfunction
endif
