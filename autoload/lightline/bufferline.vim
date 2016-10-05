" vim: et sw=2 sts=2

" Plugin:      https://github.com/mgee/lightline-bufferline
" Description: A lightweight bufferline for the lightline vim plugin.
" Maintainer:  Markus Engelbrecht <https://github.com/mgee>

if exists('g:loaded_lightline_bufferline')
  finish
endif
let g:loaded_lightline_bufferline = 1

let s:filename_modifier = get(g:, 'lightline#bufferline#filename_modifier', ':.')
let s:modified          = get(g:, 'lightline#bufferline#modified', '+')
let s:shorten_path      = get(g:, 'lightline#bufferline#shorten_path', 1)
let s:show_number       = get(g:, 'lightline#bufferline#show_number', 0)
let s:unnamed           = get(g:, 'lightline#bufferline#unnamed', '*')

function! s:get_buffer_name(i)
  let l:name = fnamemodify(bufname(a:i), s:filename_modifier)
  if l:name == ''
    let l:name = s:unnamed
  elseif s:shorten_path
    let l:name = pathshorten(l:name)
  endif
  if getbufvar(a:i, '&mod')
    let l:name .= s:modified
  endif
  if s:show_number
    let l:name = a:i . ' ' . l:name
  endif
  return substitute(l:name, '%', '%%', 'g')
endfunction

function! s:get_buffer_names(from, to)
  let l:i = a:from
  let l:buffers = []
  while l:i <= a:to
    if bufexists(l:i) && buflisted(l:i)
      call add(l:buffers, s:get_buffer_name(l:i))
    endif
    let l:i += 1
  endwhile
  return l:buffers
endfunction

function! lightline#bufferline#buffers()
  let l:current = bufnr('%')
  return [s:get_buffer_names(1, l:current - 1),
        \ s:get_buffer_names(l:current, l:current),
        \ s:get_buffer_names(l:current + 1, bufnr('$'))]
endfunction
