" Plugin:      https://github.com/mgee/lightline-bufferline
" Description: A lightweight bufferline for the lightline vim plugin.
" Maintainer:  Markus Engelbrecht <https://github.com/mgee>

scriptencoding utf-8

if exists('g:loaded_lightline_bufferline')
  finish
endif
let g:loaded_lightline_bufferline = 1

let s:filename_modifier = get(g:, 'lightline#bufferline#filename_modifier', ':.')
let s:number_map        = get(g:, 'lightline#bufferline#number_map', {})
let s:shorten_path      = get(g:, 'lightline#bufferline#shorten_path', 1)
let s:show_number       = get(g:, 'lightline#bufferline#show_number', 0)
let s:unnamed           = get(g:, 'lightline#bufferline#unnamed', '*')
let s:unicode_symbols   = get(g:, 'lightline#bufferline#unicode_symbols', 0)
if s:unicode_symbols == 0
  let s:modified        = get(g:, 'lightline#bufferline#modified', '+')
  let s:read_only       = get(g:, 'lightline#bufferline#read_only', '-')
  let s:more_buffers    = get(g:, 'lightline#bufferline#more_buffers', '...')
else
  let s:modified        = get(g:, 'lightline#bufferline#modified', '✎')
  let s:read_only       = get(g:, 'lightline#bufferline#read_only', '')
  let s:more_buffers    = get(g:, 'lightline#bufferline#more_buffers', '…')
endif
let s:more_buffers_width = len(s:more_buffers) + 2

function! s:get_buffer_name(i, buffer)
  let l:name = bufname(a:buffer)
  if l:name ==# ''
    let l:name = s:unnamed
  else
    let l:name = fnamemodify(l:name, s:filename_modifier)
    if s:shorten_path
      let l:name = pathshorten(l:name)
    endif
  endif
  if s:is_read_only(a:buffer)
    let l:name .= ' ' . s:read_only
  endif
  if getbufvar(a:buffer, '&mod')
    let l:name .= ' ' . s:modified
  endif
  if s:show_number == 1
    let l:name = a:buffer . ' ' . l:name
  elseif s:show_number == 2
    let l:name = get(s:number_map, a:i + 1, (a:i + 1) . ' ') . l:name
  endif
  return substitute(l:name, '%', '%%', 'g')
endfunction

function! s:filter_buffer(i)
  return bufexists(a:i) && buflisted(a:i)
endfunction

function! s:filtered_buffers()
  return filter(range(1, bufnr('$')), 's:filter_buffer(v:val)')
endfunction

function! s:goto_nth_buffer(n)
  let l:buffers = s:filtered_buffers()
  if a:n < len(l:buffers)
    execute 'b' . l:buffers[a:n]
  endif
endfunction

function! s:get_buffer_names(buffers, from, to)
  let l:names = []
  for l:i in range(a:from, a:to - 1)
    call add(l:names, s:get_buffer_name(l:i, a:buffers[l:i]))
  endfor
  return l:names
endfunction

function! s:get_buffer_lengths(list)
  return map(copy(a:list), 'len(v:val) + 4')
endfunction

function! s:sum(list)
  let l:sum = 0
  for l:value in a:list
    let l:sum += l:value
  endfor
  return l:sum
endfunction

function! s:fit_lengths(list, available)
  let l:remaining = a:available
  let l:count = 0
  for l:length in a:list
    if l:remaining - l:length < 0
      break
    endif
    let l:count += 1
    let l:remaining -= l:length
  endfor
  return [l:remaining, l:count]
endfunction

function! s:select_buffers(before, current, after)
  let [l:before_lengths, l:after_lengths] = [s:get_buffer_lengths(a:before), s:get_buffer_lengths(a:after)]

  " The current buffer is always displayed
  let l:width = &columns - s:get_buffer_lengths(a:current[:0])[0]

  " Display all buffers if there is enough space to display them
  if s:sum(l:before_lengths) + s:sum(l:after_lengths) <= l:width
    return [a:before, a:current, a:after]
  endif

  " Try to fit as many buffers as possible
  let [l:before, l:current, l:after] = s:select_fitting_buffers(a:before, a:current, a:after, l:before_lengths, l:after_lengths, l:width)

  " See on which side buffers did not fit
  let l:more_before = len(a:before) > len(l:before)
  let l:more_after = len(a:after) > len(l:after)

  if l:more_before && l:more_after
    " Buffers on both sides don't fit. Recompute, but account for s:more_buffers to be visible on both sides
    let [l:before, l:current, l:after] = s:select_fitting_buffers(a:before, a:current, a:after, l:before_lengths, l:after_lengths, l:width - s:more_buffers_width*2)
    let l:before = [s:more_buffers] + l:before
    let l:after += [s:more_buffers]
  elseif l:more_before || l:more_after
    " Buffers on one side don't fit. Recompute, but account for s:more_buffers to be visible on that side
    let [l:before, l:current, l:after] = s:select_fitting_buffers(a:before, a:current, a:after, l:before_lengths, l:after_lengths, l:width - s:more_buffers_width)
    " With s:more_buffers visible it is possible that buffers on another side don't fit anymore
    let l:more_before = len(a:before) > len(l:before)
    let l:more_after = len(a:after) > len(l:after)
    if l:more_before && l:more_after
      " Indeed, buffers on both sides don't fit now. Recompute, but account for s:more_buffers to be visible on both sides
      let [l:before, l:current, l:after] = s:select_fitting_buffers(a:before, a:current, a:after, l:before_lengths, l:after_lengths, l:width - s:more_buffers_width*2)
      " Now add s:more_buffers on both sides
      let l:before = [s:more_buffers] + l:before
      let l:after += [s:more_buffers]
    elseif l:more_before
      " Buffers on the left side don't fit, add s:more_buffers to the left
      let l:before = [s:more_buffers] + l:before
    elseif l:more_after
      " Buffers on the right side don't fit, add s:more_buffers to the right
      let l:after += [s:more_buffers]
    end
  endif

  return [l:before, l:current, l:after]
endfunction

function! s:select_fitting_buffers(before, current, after, before_lengths, after_lengths, width)
  let l:width = a:width
  let l:initial_right = 0
  let l:right = 0
  let l:left = 0

  " Add one buffer on the right if there is enough space for it
  if len(a:after_lengths) > 0
    let [l:width, l:initial_right] = s:fit_lengths(a:after_lengths[:0], l:width)
  endif

  " Add as many buffers as possible on the left
  " Don't forget to use the 'before' list in reversed order
  let [l:width, l:left] = s:fit_lengths(reverse(a:before_lengths), l:width)
  " Handle empty list carefully, slices are inclusive
  let l:before = l:left == 0 ? [] : a:before[-l:left:]

  " If one buffer on the right was added, maybe more can fit?
  if l:initial_right > 0
    " Fill up the remaining space with buffers on the right
    let [l:width, l:right] = s:fit_lengths(a:after_lengths[l:initial_right:], l:width)
    " Keep track of the one buffer that was added earlier
    let l:right += l:initial_right
  endif

  " Subtract 1 to account for slices being inclusive, i.e. list[:1] returns two results.
  " Also handle empty lists carefully.
  let l:after = l:right == 0 ? [] : a:after[:l:right-1]

  return [l:before, a:current, l:after]
endfunction

function! s:is_read_only(buffer)
    let l:modifiable = getbufvar(a:buffer, '&modifiable')
    let l:readonly = getbufvar(a:buffer, '&readonly')
    return (l:readonly || !l:modifiable) && getbufvar(a:buffer, '&filetype') !=# 'help'
endfunction

function! lightline#bufferline#buffers()
  let l:buffers = s:filtered_buffers()
  let l:current_index = index(l:buffers, bufnr('%'))
  if l:current_index == -1
    return [s:get_buffer_names(l:buffers, 0, len(l:buffers)), [], []]
  endif
  let l:before = s:get_buffer_names(l:buffers, 0, l:current_index)
  let l:current = s:get_buffer_names(l:buffers, l:current_index, l:current_index + 1)
  let l:after = s:get_buffer_names(l:buffers, l:current_index + 1, len(l:buffers))
  return s:select_buffers(l:before, l:current, l:after)
endfunction

function! lightline#bufferline#buffer_count()
  return len(s:filtered_buffers())
endfunction

noremap <silent> <Plug>lightline#bufferline#go(1)  :call <SID>goto_nth_buffer(0)<CR>
noremap <silent> <Plug>lightline#bufferline#go(2)  :call <SID>goto_nth_buffer(1)<CR>
noremap <silent> <Plug>lightline#bufferline#go(3)  :call <SID>goto_nth_buffer(2)<CR>
noremap <silent> <Plug>lightline#bufferline#go(4)  :call <SID>goto_nth_buffer(3)<CR>
noremap <silent> <Plug>lightline#bufferline#go(5)  :call <SID>goto_nth_buffer(4)<CR>
noremap <silent> <Plug>lightline#bufferline#go(6)  :call <SID>goto_nth_buffer(5)<CR>
noremap <silent> <Plug>lightline#bufferline#go(7)  :call <SID>goto_nth_buffer(6)<CR>
noremap <silent> <Plug>lightline#bufferline#go(8)  :call <SID>goto_nth_buffer(7)<CR>
noremap <silent> <Plug>lightline#bufferline#go(9)  :call <SID>goto_nth_buffer(8)<CR>
noremap <silent> <Plug>lightline#bufferline#go(10) :call <SID>goto_nth_buffer(9)<CR>
