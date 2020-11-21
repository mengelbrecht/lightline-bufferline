" Plugin:      https://github.com/mengelbrecht/lightline-bufferline
" Description: A lightweight bufferline for the lightline vim plugin.
" Maintainer:  Markus Engelbrecht <https://github.com/mengelbrecht>

scriptencoding utf-8

let s:dirsep              = fnamemodify(getcwd(),':p')[-1:]
let s:filename_modifier   = get(g:, 'lightline#bufferline#filename_modifier', ':.')
let s:min_buffer_count    = get(g:, 'lightline#bufferline#min_buffer_count', 0)
let s:number_map          = get(g:, 'lightline#bufferline#number_map', {})
let s:composed_number_map = get(g:, 'lightline#bufferline#composed_number_map', {})
let s:shorten_path        = get(g:, 'lightline#bufferline#shorten_path', 1)
let s:smart_path          = get(g:, 'lightline#bufferline#smart_path', 1)
let s:show_number         = get(g:, 'lightline#bufferline#show_number', 0)
let s:number_separator    = get(g:, 'lightline#bufferline#number_separator', ' ')
let s:ordinal_separator   = get(g:, 'lightline#bufferline#ordinal_separator', '')
let s:unnamed             = get(g:, 'lightline#bufferline#unnamed', '*')
let s:reverse_buffers     = get(g:, 'lightline#bufferline#reverse_buffers', 0)
let s:right_aligned       = get(g:, 'lightline#bufferline#right_aligned', 0)
let s:enable_devicons     = get(g:, 'lightline#bufferline#enable_devicons', 0)
let s:enable_nerdfont     = get(g:, 'lightline#bufferline#enable_nerdfont', 0)
let s:icon_position       = get(g:, 'lightline#bufferline#icon_position', 'left')
let s:unicode_symbols     = get(g:, 'lightline#bufferline#unicode_symbols', 0)
if s:unicode_symbols == 0
  let s:modified          = get(g:, 'lightline#bufferline#modified', ' +')
  let s:read_only         = get(g:, 'lightline#bufferline#read_only', ' -')
  let s:more_buffers      = get(g:, 'lightline#bufferline#more_buffers', '...')
else
  let s:modified          = get(g:, 'lightline#bufferline#modified', ' ✎')
  let s:read_only         = get(g:, 'lightline#bufferline#read_only', ' ')
  let s:more_buffers      = get(g:, 'lightline#bufferline#more_buffers', '…')
endif
if exists('g:lightline.component_raw.buffers')
  let s:component_is_raw  = g:lightline.component_raw.buffers
else
  let s:component_is_raw  = 0
endif
let s:clickable           = has('tablineat') && s:component_is_raw ? get(g:, 'lightline#bufferline#clickable', 0) : 0
if s:component_is_raw
  let s:more_buffers = ' ' . s:more_buffers . ' '
  let s:more_buffers_width = len(s:more_buffers)
else
  let s:more_buffers_width = len(s:more_buffers) + 2
endif

function! lightline#bufferline#_click_handler(minwid, clicks, btn, modifiers)
  call s:goto_nth_buffer(a:minwid)
endfunction

if has('nvim-0.5') && exists('g:nvim_web_devicons')
  lua <<EOF
  function _G._bufferline_get_icon(path)
    local filename = vim.api.nvim_eval("fnamemodify('"..path.."', ':t')")
    local extension = vim.api.nvim_eval("fnamemodify('"..path.."', ':e')")
    local icon, hl_group = require'nvim-web-devicons'.get_icon(filename, extension, { default = true })
    if icon then
      return icon
    else
      return ""
    end
  end
EOF
endif

function! s:get_buffer_name(i, buffer, path)
  let l:name = a:path
  if l:name ==# ''
    let l:name = s:unnamed
  else
    let l:name = fnamemodify(l:name, s:filename_modifier)
    if s:shorten_path
      let l:name = pathshorten(l:name)
    endif
  endif

  let l:icon = s:get_icon(a:buffer)
  if l:icon != ''
    let l:name = s:icon_position ==? 'right' ?  (l:name . ' ' . l:icon) : (l:icon . ' ' . l:name)
  endif

  if s:is_read_only(a:buffer)
    let l:name .= s:read_only
  endif
  if getbufvar(a:buffer, '&mod')
    let l:name .= s:modified
  endif
  if s:show_number == 1
    let l:name = a:buffer . s:number_separator . l:name
  elseif s:show_number == 2
    let l:name = s:get_from_number_map(a:i + 1). s:number_separator . l:name
  elseif s:show_number == 3
    let l:name = a:buffer . s:ordinal_separator . s:get_from_number_map(a:i + 1) . s:number_separator . l:name
  elseif s:show_number == 4
    let l:name = s:get_from_number_map(a:i + 1) . s:ordinal_separator . a:buffer . s:number_separator . l:name
  endif
  let l:len = len(l:name)
  let l:name = substitute(l:name, '%', '%%', 'g')
  if s:component_is_raw
    let l:name = ' ' . l:name . ' '
  endif
  if s:clickable
    return ['%' . string(a:i) . '@lightline#bufferline#_click_handler@' . l:name . '%X', l:len]
  else
    return [l:name, l:len]
  endif
endfunction

function! s:get_icon(buffer)
  if s:enable_devicons == 1 && exists('*WebDevIconsGetFileTypeSymbol')
    return WebDevIconsGetFileTypeSymbol(fnamemodify(bufname(a:buffer), ':t'))
  endif

  if s:enable_devicons == 1 && has('nvim-0.5') && exists('g:nvim_web_devicons')
    return v:lua._bufferline_get_icon(bufname(a:buffer))
  endif

  if s:enable_nerdfont == 1
    try
      return nerdfont#find(fnamemodify(bufname(a:buffer), ':t'), 0)
    catch /^Vim\%((\a\+)\)\=:E117:/
    endtry
  endif

  return ''
endfunction

function! s:get_from_number_map(i)
  let l:number = a:i
  let l:result = get(s:composed_number_map, l:number, '')
  if l:result == ""
    for i in range(1, strlen(l:number))
      let l:result = get(s:number_map, l:number % 10, l:number % 10) . l:result
      let l:number = l:number / 10
    endfor
  endif
  return l:result
endfunction

function! s:filter_buffer(i)
  return bufexists(a:i) && buflisted(a:i) && !(getbufvar(a:i, '&filetype') ==# 'qf')
endfunction

function! s:filtered_buffers()
  let l:buffers = filter(range(1, bufnr('$')), 's:filter_buffer(v:val)')
  if s:reverse_buffers == 1
    let l:buffers = reverse(l:buffers)
  endif
  return l:buffers
endfunction

function! s:goto_nth_buffer(n)
  let l:buffers = s:filtered_buffers()
  if a:n < len(l:buffers)
    execute 'b' . l:buffers[a:n]
  endif
endfunction

function! s:delete_nth_buffer(n)
  let l:buffers = s:filtered_buffers()
  if a:n < len(l:buffers)
    execute 'bd' . l:buffers[a:n]
  endif
endfunction

function! s:get_buffer_paths(buffers)
  if (!s:smart_path)
    return map(copy(a:buffers), 'bufname(v:val)')
  endif

  let l:smart_buffers = []
  let l:buffer_count_per_tail = {}

  for l:buffer in a:buffers
    let l:smart_buffer = {}
    let l:name = bufname(l:buffer)

    if strlen(l:name)
      let l:smart_buffer.path = fnamemodify(l:name, ':p:~:.')
      let l:smart_buffer.sep = strridx(l:smart_buffer.path, s:dirsep, strlen(l:smart_buffer.path) - 2)
      let l:smart_buffer.label = l:smart_buffer.path[l:smart_buffer.sep + 1:]
      let l:buffer_count_per_tail[l:smart_buffer.label] = get(l:buffer_count_per_tail, l:smart_buffer.label, 0) + 1
    else
      let l:smart_buffer.path = l:name
      let l:smart_buffer.label = l:name
    endif

    call add(l:smart_buffers, l:smart_buffer)
  endfor

  while len(filter(l:buffer_count_per_tail, 'v:val > 1'))
    let [ambiguous, l:buffer_count_per_tail] = [l:buffer_count_per_tail, {}]

    for l:smart_buffer in l:smart_buffers
      if strlen(l:smart_buffer.path)
        if -1 < l:smart_buffer.sep && has_key(ambiguous, l:smart_buffer.label)
          let l:smart_buffer.sep = strridx(l:smart_buffer.path, s:dirsep, l:smart_buffer.sep - 1)
          let l:smart_buffer.label = l:smart_buffer.path[l:smart_buffer.sep + 1:]
        endif
        let l:buffer_count_per_tail[l:smart_buffer.label] = get(l:buffer_count_per_tail, l:smart_buffer.label, 0) + 1
      endif
    endfor
  endwhile

  return map(l:smart_buffers, 'v:val.label')
endfunction

function! s:get_buffer_names(buffers, from, to)
  let l:names = []
  let l:lengths = []
  let l:buffer_paths = s:get_buffer_paths(a:buffers)
  for l:i in range(a:from, a:to - 1)
    let [l:name, l:len] = s:get_buffer_name(l:i, a:buffers[l:i], l:buffer_paths[l:i])
    call add(l:names, l:name)
    call add(l:lengths, l:len + 4)
  endfor
  return [l:names, l:lengths]
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
  let [l:before_names, l:current_names, l:after_names] = [a:before[0], a:current[0], a:after[0]]
  let [l:before_lengths, l:current_lengths, l:after_lengths] = [a:before[1], a:current[1], a:after[1]]

  " The current buffer is always displayed
  let l:width = &columns - l:current_lengths[:0][0]

  " Display all buffers if there is enough space to display them
  if s:sum(l:before_lengths) + s:sum(l:after_lengths) <= l:width
    return [l:before_names, l:current_names, l:after_names]
  endif

  " Try to fit as many buffers as possible
  let [l:before, l:current, l:after] = s:select_fitting_buffers(l:before_names, l:current_names, l:after_names, l:before_lengths, l:after_lengths, l:width)

  " See on which side buffers did not fit
  let l:more_before = len(l:before_names) > len(l:before)
  let l:more_after = len(l:after_names) > len(l:after)

  if l:more_before && l:more_after
    " Buffers on both sides don't fit. Recompute, but account for s:more_buffers to be visible on both sides
    let [l:before, l:current, l:after] = s:select_fitting_buffers(l:before_names, l:current_names, l:after_names, l:before_lengths, l:after_lengths, l:width - s:more_buffers_width*2)
    let l:before = [s:more_buffers] + l:before
    let l:after += [s:more_buffers]
  elseif l:more_before || l:more_after
    " Buffers on one side don't fit. Recompute, but account for s:more_buffers to be visible on that side
    let [l:before, l:current, l:after] = s:select_fitting_buffers(l:before_names, l:current_names, l:after_names, l:before_lengths, l:after_lengths, l:width - s:more_buffers_width)
    " With s:more_buffers visible it is possible that buffers on another side don't fit anymore
    let l:more_before = len(l:before_names) > len(l:before)
    let l:more_after = len(l:after_names) > len(l:after)
    if l:more_before && l:more_after
      " Indeed, buffers on both sides don't fit now. Recompute, but account for s:more_buffers to be visible on both sides
      let [l:before, l:current, l:after] = s:select_fitting_buffers(l:before_names, l:current_names, l:after_names, l:before_lengths, l:after_lengths, l:width - s:more_buffers_width*2)
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

function! s:auto_tabline(buffer_count) abort
  if a:buffer_count >= s:min_buffer_count
    if &showtabline != 2 && &lines > 3
      set showtabline=2
    endif
  else
    if &showtabline != 0
      set showtabline=0
    endif
  endif
endfunction

function! lightline#bufferline#init()
  augroup lightline_bufferline
    autocmd!
    if s:min_buffer_count > 0
      autocmd BufEnter  * call <SID>auto_tabline(len(<SID>filtered_buffers()))
      autocmd BufUnload * call <SID>auto_tabline(len(<SID>filtered_buffers()) - 1)
    endif
  augroup END
endfunction

function! lightline#bufferline#buffers()
  let l:buffers = s:filtered_buffers()
  let l:current_index = index(l:buffers, bufnr('%'))
  if l:current_index == -1
    return [s:get_buffer_names(l:buffers, 0, len(l:buffers))[0], [], []]
  endif
  let l:before = s:get_buffer_names(l:buffers, 0, l:current_index)
  let l:current = s:get_buffer_names(l:buffers, l:current_index, l:current_index + 1)
  let l:after = s:get_buffer_names(l:buffers, l:current_index + 1, len(l:buffers))
  if s:right_aligned == 1
    return s:select_buffers(l:after, l:current, l:before)
  else
    return s:select_buffers(l:before, l:current, l:after)
  endif
endfunction

function! lightline#bufferline#go(n)
  call s:goto_nth_buffer(a:n - 1)
endfunction

function! lightline#bufferline#delete(n)
  call s:delete_nth_buffer(a:n - 1)
endfunction

noremap <silent> <Plug>lightline#bufferline#go(1)  :call lightline#bufferline#go(1)<CR>
noremap <silent> <Plug>lightline#bufferline#go(2)  :call lightline#bufferline#go(2)<CR>
noremap <silent> <Plug>lightline#bufferline#go(3)  :call lightline#bufferline#go(3)<CR>
noremap <silent> <Plug>lightline#bufferline#go(4)  :call lightline#bufferline#go(4)<CR>
noremap <silent> <Plug>lightline#bufferline#go(5)  :call lightline#bufferline#go(5)<CR>
noremap <silent> <Plug>lightline#bufferline#go(6)  :call lightline#bufferline#go(6)<CR>
noremap <silent> <Plug>lightline#bufferline#go(7)  :call lightline#bufferline#go(7)<CR>
noremap <silent> <Plug>lightline#bufferline#go(8)  :call lightline#bufferline#go(8)<CR>
noremap <silent> <Plug>lightline#bufferline#go(9)  :call lightline#bufferline#go(9)<CR>
noremap <silent> <Plug>lightline#bufferline#go(10) :call lightline#bufferline#go(10)<CR>

noremap <silent> <Plug>lightline#bufferline#delete(1)  :call lightline#bufferline#delete(1)<CR>
noremap <silent> <Plug>lightline#bufferline#delete(2)  :call lightline#bufferline#delete(2)<CR>
noremap <silent> <Plug>lightline#bufferline#delete(3)  :call lightline#bufferline#delete(3)<CR>
noremap <silent> <Plug>lightline#bufferline#delete(4)  :call lightline#bufferline#delete(4)<CR>
noremap <silent> <Plug>lightline#bufferline#delete(5)  :call lightline#bufferline#delete(5)<CR>
noremap <silent> <Plug>lightline#bufferline#delete(6)  :call lightline#bufferline#delete(6)<CR>
noremap <silent> <Plug>lightline#bufferline#delete(7)  :call lightline#bufferline#delete(7)<CR>
noremap <silent> <Plug>lightline#bufferline#delete(8)  :call lightline#bufferline#delete(8)<CR>
noremap <silent> <Plug>lightline#bufferline#delete(9)  :call lightline#bufferline#delete(9)<CR>
noremap <silent> <Plug>lightline#bufferline#delete(10) :call lightline#bufferline#delete(10)<CR>
