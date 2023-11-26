" Plugin:      https://github.com/mengelbrecht/lightline-bufferline
" Description: A lightweight bufferline for the lightline vim plugin.
" Maintainer:  Markus Engelbrecht <https://github.com/mengelbrecht>

scriptencoding utf-8

function! lightline#bufferline#load()
  let s:dirsep              = fnamemodify(getcwd(),':p')[-1:]
  let s:filename_modifier   = get(g:, 'lightline#bufferline#filename_modifier', ':.')
  let s:min_buffer_count    = get(g:, 'lightline#bufferline#min_buffer_count', 0)
  let s:min_tab_count       = get(g:, 'lightline#bufferline#min_tab_count', 0)
  let s:filter_by_tabpage   = get(g:, 'lightline#bufferline#filter_by_tabpage', 0)
  let s:buffer_filter       = get(g:, 'lightline#bufferline#buffer_filter', 's:buffer_filter_noop')
  let s:auto_hide           = get(g:, 'lightline#bufferline#auto_hide', 0)
  let s:max_width_function  = get(g:, 'lightline#bufferline#max_width', 's:max_width')
  let s:disable_more_buffers_indicator = get(g:, 'lightline#bufferline#disable_more_buffers_indicator', 0)
  let s:margin_left         = get(g:, 'lightline#bufferline#margin_left', 0)
  let s:margin_right        = get(g:, 'lightline#bufferline#margin_right', 0)
  let s:ordinal_number_map  = get(g:, 'lightline#bufferline#ordinal_number_map', get(g:, 'lightline#bufferline#number_map', {}))
  let s:buffer_number_map   = get(g:, 'lightline#bufferline#buffer_number_map', {})
  let s:composed_ordinal_number_map = get(g:, 'lightline#bufferline#composed_ordinal_number_map', get(g:, 'lightline#bufferline#composed_number_map', {}))
  let s:composed_buffer_number_map = get(g:, 'lightline#bufferline#composed_buffer_number_map', {})
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
  let s:maxWidthFunc = function(s:max_width_function)

  function! s:get_separator(sub, def)
    " Cannot use `get()` as it doesn't support dict deep indexing
    let l:align = s:right_aligned ? 'right' : 'left'
    if exists('g:lightline.tabline_' .. a:sub .. 'separator.' .. l:align)
      return g:lightline['tabline_' .. a:sub .. 'separator'][l:align]
    elseif exists('g:lightline.' .. a:sub .. 'separator.' .. l:align)
      return g:lightline[a:sub .. 'separator'][l:align]
    else
      return a:def
    endif
  endfunction

  let s:separator_len = len(s:get_separator('', ''))
  let s:subseparator_len = len(s:get_separator('sub', '|'))
endfunction

function! lightline#bufferline#reload()
  call lightline#bufferline#load()
  call s:force_update()
endfunction

function! s:pre_click_handler()
endfunction

function! lightline#bufferline#_click_handler(minwid, clicks, btn, modifiers)
  doautocmd User LightlineBufferlinePreClick
  call s:goto_nth_buffer(a:minwid)
endfunction

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
  let l:number = s:get_number(a:i, a:buffer)
  if l:number != '' && l:icon != ''
    if s:icon_position ==? 'first'
      let l:name = l:icon . ' ' . l:number . l:name
    elseif s:icon_position ==? 'right'
      let l:name = l:number . l:name . ' ' . l:icon
    else
      let l:name = l:number . l:icon . ' ' . l:name
    endif
  elseif l:number != ''
    let l:name = l:number . l:name
  elseif l:icon != ''
    let l:name = s:icon_position ==? 'right' ?  (l:name . ' ' . l:icon) : (l:icon . ' ' . l:name)
  endif

  if s:is_read_only(a:buffer)
    let l:name .= s:read_only
  endif
  if getbufvar(a:buffer, '&mod')
    let l:name .= s:modified
  endif

  let l:name = repeat(' ', s:margin_left) . l:name . repeat(' ', s:margin_right)

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
  elseif s:enable_devicons == 1 && has('nvim-0.5') && exists('g:nvim_web_devicons')
    return luaeval("require('bufferline')._get_icon(vim.fn.bufname(" . a:buffer . "))")
  endif

  if s:enable_nerdfont == 1
    try
      return nerdfont#find(fnamemodify(bufname(a:buffer), ':t'), 0)
    catch /^Vim\%((\a\+)\)\=:E117:/
    endtry
  endif

  return ''
endfunction

function! s:get_number(i, buffer)
  if s:show_number == 1
    return s:get_from_number_map(a:buffer, s:composed_buffer_number_map, s:buffer_number_map) . s:number_separator
  elseif s:show_number == 2
    return s:get_from_number_map(a:i + 1, s:composed_ordinal_number_map, s:ordinal_number_map). s:number_separator
  elseif s:show_number == 3
    return s:get_from_number_map(a:buffer, s:composed_buffer_number_map, s:buffer_number_map) . s:ordinal_separator . s:get_from_number_map(a:i + 1, s:composed_ordinal_number_map, s:ordinal_number_map) . s:number_separator
  elseif s:show_number == 4
    return s:get_from_number_map(a:i + 1, s:composed_ordinal_number_map, s:ordinal_number_map) . s:ordinal_separator . s:get_from_number_map(a:buffer, s:composed_buffer_number_map, s:buffer_number_map) . s:number_separator
  endif

  return ''
endfunction

function! s:get_from_number_map(i, composed_number_map, number_map)
  let l:number = a:i
  let l:result = get(a:composed_number_map, l:number, '')
  if l:result == ""
    for i in range(1, strlen(l:number))
      let l:result = get(a:number_map, l:number % 10, l:number % 10) . l:result
      let l:number = l:number / 10
    endfor
  endif
  return l:result
endfunction

function! s:tabpage_filter(i)
  if s:filter_by_tabpage && tabpagenr('$') > 1
    return index(tabpagebuflist(tabpagenr()), a:i) != -1
  endif
  return 1
endfunc

function! s:buffer_filter_noop(buffer)
  return 1
endfunction

function! s:buffer_category(buffer)
  let l:value = function(s:buffer_filter)(a:buffer)
  if type(l:value) == v:t_number
    return l:value ? 'default' : ''
  endif
  return l:value
endfunction

function! s:filter_buffer(i)
  return bufexists(a:i) && buflisted(a:i) && getbufvar(a:i, '&filetype') !=# 'qf'
       \ && s:tabpage_filter(a:i) && s:buffer_category(a:i) != ''
endfunction

" Inserting only identity (f(x) == x), not removing values and just swapping
" combined with Vim's lack of number reuse forms a symmetric group,
" i.e. invariant sorted(keys(s:order)) == sorted(values(s:order)).
" This also automagically handles opening new buffers and deleting old ones,
" switching between categories and even moving buffers between them.
let s:order = {}
function! s:get_order(buffer) abort
  if !has_key(s:order, a:buffer)
    let s:order[a:buffer] = a:buffer
  endif
  return s:order[a:buffer]
endfunction

function! s:order_comparator(first, second) abort
  return s:get_order(a:first) - s:get_order(a:second)
endfunction

function! s:filtered_buffers(...)
  let l:category = get(a:, 1, s:buffer_category(bufnr('%')))
  if l:category == ''
    let l:category = 'default'
  endif
  let l:filter_expr = 's:filter_buffer(v:val) && s:buffer_category(v:val) == l:category'
  let l:buffers = filter(range(1, bufnr('$')), l:filter_expr)
  if s:reverse_buffers == 1
    let l:buffers = reverse(l:buffers)
  endif
  if len(s:order)
    call sort(l:buffers, 's:order_comparator')
  endif
  return l:buffers
endfunction

function! s:get_all_categories()
  let l:unique = {}
  for l:val in range(1, bufnr('$'))
    if s:filter_buffer(l:val)
      let l:unique[s:buffer_category(l:val)] = 1
    endif
  endfor
  return sort(keys(l:unique))
endfunction

function! s:get_buffer_for_ordinal_number(n)
  let l:buffers = s:filtered_buffers()
  if a:n >= 0 && a:n < len(l:buffers)
    return l:buffers[a:n]
  endif
  return -1
endfunction

function! s:get_ordinal_number_for_buffer(buffer)
  let l:buffers = s:filtered_buffers()
  let l:i = index(l:buffers, a:buffer)
  if l:i >= 0
    return l:i + 1
  endif
  return -1
endfunction

function! s:goto_nth_buffer(n)
  let l:buffer = s:get_buffer_for_ordinal_number(a:n)
  if l:buffer >= 0
    execute 'b' . l:buffer
  endif
endfunction

function! s:delete_nth_buffer(n)
  let l:buffer = s:get_buffer_for_ordinal_number(a:n)
  if l:buffer >= 0
    execute 'bd' . l:buffer
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

      let sep = strridx(l:smart_buffer.path, s:dirsep)
      if sep != -1 && l:smart_buffer.path[sep :] ==# s:dirsep
        let sep = strridx(l:smart_buffer.path, s:dirsep, sep - 1)
      endif

      " On Windows consider UNIX directory separators as well because
      " for example neovim converts \ to / upon :mksession

      if sep == -1 && has('win32')
        let sep = strridx(l:smart_buffer.path, '/')
        if sep != -1 && l:smart_buffer.path[sep :] ==# '/'
          let sep = strridx(l:smart_buffer.path, sep - 1)
        endif
      endif

      let l:smart_buffer.sep = sep
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

function! s:get_buffer_names(buffers, from, to, section)
  let l:names = []
  let l:lengths = []
  let l:buffer_paths = s:get_buffer_paths(a:buffers)
  for l:i in range(a:from, a:to - 1)
    let [l:name, l:len] = s:get_buffer_name(l:i, a:buffers[l:i], l:buffer_paths[l:i])

    " Adjust name length by padding whitespace and separator
    let l:len += 2
    if a:section == 'before'
      let l:len += l:i == a:to - 1 ? s:separator_len : s:subseparator_len
    elseif a:section == 'after'
      let l:len += l:i == a:from ? s:separator_len : s:subseparator_len
    endif

    call add(l:names, l:name)
    call add(l:lengths, l:len)
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

function! s:max_width()
  return &columns
endfunction

function! s:select_buffers(before, current, after)
  let [l:before_names, l:current_names, l:after_names] = [a:before[0], a:current[0], a:after[0]]
  let [l:before_lengths, l:current_lengths, l:after_lengths] = [a:before[1], a:current[1], a:after[1]]

  " The current buffer is always displayed
  let l:width = call(s:maxWidthFunc, []) - l:current_lengths[:0][0]

  " Display all buffers if there is enough space to display them
  if s:disable_more_buffers_indicator || s:sum(l:before_lengths) + s:sum(l:after_lengths) <= l:width
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
    if len(l:before_names) > len(l:before)
      let l:before = [s:more_buffers] + l:before
    endif
    if len(l:after_names) > len(l:after)
      let l:after += [s:more_buffers]
    endif
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
  let [l:width, l:left] = s:fit_lengths(reverse(copy(a:before_lengths)), l:width)
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

function! s:auto_tabline_timer(...) abort
  unlet s:auto_tabline_timer

  if s:auto_hide > 0
    if exists('s:auto_hide_timer')
      call timer_stop(s:auto_hide_timer)
    endif
    if &showtabline != 2
      set showtabline=2
    endif
    let s:auto_hide_timer = timer_start(s:auto_hide, function('s:hide_timer'))
  elseif s:min_buffer_count > 0 || s:min_tab_count > 0
    if (s:min_tab_count > 0 && tabpagenr('$') >= s:min_tab_count) || (s:min_buffer_count > 0 && len(s:filtered_buffers()) >= s:min_buffer_count)
      if &showtabline != 2 && &lines > 3
        set showtabline=2
      endif
    else
      if &showtabline != 0
        set showtabline=0
      endif
    endif
  endif
endfunction

function! s:auto_tabline() abort
  if !exists('s:auto_tabline_timer')
      let s:auto_tabline_timer = timer_start(10, function('s:auto_tabline_timer'))
  endif
endfunction

function! s:hide_timer(...) abort
  if &showtabline != 0
    set showtabline=0
  endif
  unlet s:auto_hide_timer
endfunction

function! lightline#bufferline#init()
  augroup lightline_bufferline
    autocmd!
    if s:auto_hide > 0 || s:min_buffer_count > 0
      autocmd BufEnter,BufLeave,BufDelete  * call <SID>auto_tabline()
    endif
    if s:min_tab_count > 0
      autocmd TabEnter  * call <SID>auto_tabline()
    endif
  augroup END
endfunction

function! lightline#bufferline#buffers()
  let l:buffers = s:filtered_buffers()
  let l:current_index = index(l:buffers, bufnr('%'))
  if l:current_index == -1
    return [s:get_buffer_names(l:buffers, 0, len(l:buffers), 'before')[0], [], []]
  endif
  let l:before = s:get_buffer_names(l:buffers, 0, l:current_index, 'before')
  let l:current = s:get_buffer_names(l:buffers, l:current_index, l:current_index + 1, 'current')
  let l:after = s:get_buffer_names(l:buffers, l:current_index + 1, len(l:buffers), 'after')
  if s:right_aligned == 1
    return s:select_buffers(l:after, l:current, l:before)
  else
    return s:select_buffers(l:before, l:current, l:after)
  endif
endfunction

function! lightline#bufferline#go(n)
  call s:goto_nth_buffer(a:n - 1)
endfunction

function! s:clamp(val, count)
  if a:val < 0
    return a:count - 1
  elseif a:val >= a:count
    return 0
  endif
  return a:val
endfunction

function lightline#bufferline#go_relative(offset)
  let l:buffers = s:filtered_buffers()
  let l:current_index = index(l:buffers, bufnr('%'))
  if l:current_index == -1
      return
  endif

  let l:new_index = s:clamp(l:current_index + a:offset, len(l:buffers))
  execute 'b' .. l:buffers[l:new_index]
endfunction

function! lightline#bufferline#go_next()
  call lightline#bufferline#go_relative(1)
endfunction

function! lightline#bufferline#go_previous()
  call lightline#bufferline#go_relative(-1)
endfunction

function! lightline#bufferline#go_relative_category(offset)
  let l:categories = s:get_all_categories()
  if len(l:categories) < 2
    return
  endif

  let l:current_category = s:buffer_category(bufnr('%'))
  let l:current_index = index(l:categories, l:current_category)
  if l:current_index < 0
    return
  endif

  let l:new_index = s:clamp(l:current_index + a:offset, len(l:categories))
  let l:new_category = l:categories[l:new_index]
  let l:buffer = s:filtered_buffers(l:new_category)[0]
  execute 'b' .. l:buffer
endfunction

function! lightline#bufferline#go_next_category()
  call lightline#bufferline#go_relative_category(1)
endfunction

function! lightline#bufferline#go_previous_category()
  call lightline#bufferline#go_relative_category(-1)
endfunction

function! lightline#bufferline#delete(n)
  call s:delete_nth_buffer(a:n - 1)
endfunction

function! lightline#bufferline#get_ordinal_number_for_buffer(buffer)
  return s:get_ordinal_number_for_buffer(a:buffer)
endfunction

function! lightline#bufferline#get_buffer_for_ordinal_number(n)
  return s:get_buffer_for_ordinal_number(a:n - 1)
endfunction

  " lightline#update() does not always work
function! s:force_update() abort
  call lightline#toggle()
  call lightline#toggle()
endfunction

function! lightline#bufferline#reset_order() abort
  let s:order = {}
  call s:force_update()
endfunction

" Avoid repeated calls to s:filtered_buffers() in callers
function! s:move(target, buffers) abort
  let l:target = a:target - 1
  let l:buffers = s:filtered_buffers()
  if l:target < 0 || target >= len(l:buffers)
    return
  endif

  let l:current = index(l:buffers, bufnr('%'))
  if l:current < 0
    return
  endif

  " Cannot just swap current and target, need to offset everything on the way.
  " From target to current exclusive, keep stealing order from next,
  " then give the target's order to current at the end.
  "
  " E.g.: for buffers ABC, current = C, target = A
  " onew = o[A]   A: 1, B: 2, C: 3
  " o[A] = o[B]   A: 2, B: 2: C: 3
  " o[B] = o[C]   A: 2, B: 3, C: 3
  " o[C] = onew   A: 2, B: 3, C: 1
  " Sorted by order, gives CAB, so A moved to C like we wanted.
  let l:new_order = s:get_order(l:buffers[l:target])
  let l:direction = l:current > l:target ? 1 : -1
  for l:pivot in range(l:target, l:current - l:direction, l:direction)
    let s:order[l:buffers[l:pivot]] =
      \ s:get_order(l:buffers[l:pivot + l:direction])
  endfor

  let s:order[l:buffers[l:current]] = l:new_order
  call s:force_update()
endfunction

function! lightline#bufferline#move(target) abort
  return s:move(a:target, s:filtered_buffers())
endfunction

function! lightline#bufferline#move_relative(offset) abort
  let l:buffers = s:filtered_buffers()
  let l:current = index(l:buffers, bufnr('%'))
  let l:target = s:clamp(l:current + a:offset, len(l:buffers)) + 1
  return s:move(l:target, l:buffers)
endfunction

function! lightline#bufferline#move_next() abort
  return lightline#bufferline#move_relative(1)
endfunction

function! lightline#bufferline#move_previous() abort
  return lightline#bufferline#move_relative(-1)
endfunction

function! lightline#bufferline#move_first() abort
  return lightline#bufferline#move(1)
endfunction

function! lightline#bufferline#move_last() abort
  let l:buffers = s:filtered_buffers()
  return s:move(len(l:buffers), l:buffers)
endfunction

call lightline#bufferline#load()

autocmd User LightlineBufferlinePreClick call s:pre_click_handler()

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

noremap <silent> <Plug>lightline#bufferline#go_next()     :call lightline#bufferline#go_next()<CR>
noremap <silent> <Plug>lightline#bufferline#go_previous() :call lightline#bufferline#go_previous()<CR>
noremap <silent> <Plug>lightline#bufferline#go_next_category()     :call lightline#bufferline#go_next_category()<CR>
noremap <silent> <Plug>lightline#bufferline#go_previous_category() :call lightline#bufferline#go_previous_category()<CR>

noremap <silent> <Plug>lightline#bufferline#move_next()     :call lightline#bufferline#move_next()<CR>
noremap <silent> <Plug>lightline#bufferline#move_previous() :call lightline#bufferline#move_previous()<CR>
noremap <silent> <Plug>lightline#bufferline#move_first()    :call lightline#bufferline#move_first()<CR>
noremap <silent> <Plug>lightline#bufferline#move_last()     :call lightline#bufferline#move_last()<CR>
noremap <silent> <Plug>lightline#bufferline#reset_order()   :call lightline#bufferline#reset_order()<CR>

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
