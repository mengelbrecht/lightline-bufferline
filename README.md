# lightline-bufferline

This plugin provides bufferline functionality for the [lightline](https://github.com/itchyny/lightline.vim) vim plugin.

<p align="center"><img src="https://raw.githubusercontent.com/wiki/mengelbrecht/lightline-bufferline/images/bufferline.png" width="843"></p>

## Table Of Contents

- [Installation](#installation)
- [Integration](#integration)
- [Configuration](#configuration)
  - [General](#general)
  - [Filename](#filename)
  - [Indicators](#indicators)
  - [More Buffers](#more-buffers)
  - [Numbering](#numbering)
  - [Icons](#icons)
  - [Hiding](#hiding)
  - [Filtering](#filtering)
- [Mappings](#mappings)
- [Example](#example)
- [License](#license)

## Installation

Installation can be easily done with a plugin manager of your choice. For example [vim-plug](https://github.com/junegunn/vim-plug):

```viml
Plug 'mengelbrecht/lightline-bufferline'
```

## Integration

1. Add `'buffers'` to `g:lightline.tabline`.
2. Add `'buffers': 'lightline#bufferline#buffers'` to `g:lightline.component_expand`.
3. Add `'buffers': 'tabsel'` to `g:lightline.component_type`.

The result looks for example like this:

```viml
let g:lightline = {
      \ 'colorscheme': 'one',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ], [ 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'tabline': {
      \   'left': [ ['buffers'] ],
      \   'right': [ ['close'] ]
      \ },
      \ 'component_expand': {
      \   'buffers': 'lightline#bufferline#buffers'
      \ },
      \ 'component_type': {
      \   'buffers': 'tabsel'
      \ }
      \ }
```

If you are using neovim with a lua configuration the above example looks like this:
```lua
vim.g['lightline'] = {
  colorscheme = 'one',
  active = {
    left = {{'mode', 'paste'}, {'readonly', 'filename', 'modified'}}
  },
  tabline = {
    left = {{'buffers'}},
    right = {{'close'}}
  },
  component_expand = {
    buffers = 'lightline#bufferline#buffers'
  },
  component_type = {
    buffers = 'tabsel'
  }
}
```

If you're adding the buffers to the bottom statusbar, the `modified` indicator will not be updated immediately. To work around this, add this autocmd to your vim config:

```viml
autocmd BufWritePost,TextChanged,TextChangedI * call lightline#update()
```

## Configuration

### General

##### `g:lightline#bufferline#unnamed`

The name to use for unnamed buffers. Default is `'*'`.

##### `g:lightline#bufferline#margin_left`

The number of spaces to add on the left side of the buffer name. Default is `0`.

##### `g:lightline#bufferline#margin_right`

The number of spaces to add on the right side of the buffer name. Default is `0`.

##### `g:lightline#bufferline#reverse_buffers`

If enabled the buffers will be displayed in a reversed order.
Default is `0` (buffers are not reversed).

##### `g:lightline#bufferline#right_aligned`

If the bufferline is used in the `right` component of the tabline this should be set to `1` to ensure the correct order of the buffers.
Default is `0`.

##### `g:lightline#bufferline#clickable`

If set to `1` the bufferline is clickable when using Neovim versions with `tablineat` feature. To enable this feature, you must also set the bufferline component to be raw in your `vimrc`:

```viml
let g:lightline.component_raw = {'buffers': 1}
```

Before the click handler for the buffer is executed a custom event `LightlineBufferlinePreClick` is emitted.
To perform an operation before the buffer is switched via the click handler you can define an autocommand:
```viml
autocmd User LightlineBufferlinePreClick :echom "test"
```

### Filename

##### `g:lightline#bufferline#filename_modifier`

The filename-modifier applied to each buffer name. Default is `':.'`.
To see the available options use the command `:help filename-modifiers` in vim.

##### `g:lightline#bufferline#shorten_path`

Defines whether to shorten the path using the `pathshorten` function. Default is `1`.

##### `g:lightline#bufferline#smart_path`

If enabled, when two files have the same name the distinguishing sections of each file's path are added. Default is `1`.

### Indicators

##### `g:lightline#bufferline#modified`

The indicator to use for a modified buffer. Default is `' +'`.

##### `g:lightline#bufferline#read_only`

The indicator to use for a read-only buffer. Default is `' -'`.

##### `g:lightline#bufferline#more_buffers`

The indicator to use when there are buffers that are not shown on the bufferline because they didn't fit the available space. Default is `...`.

##### `g:lightline#bufferline#unicode_symbols`

Use unicode symbols for modified and read-only buffers as well as the more buffers indicator. Default is `0`.

If set to `1` the symbols `+`, `-` and `...` are replaced by `✎`, `` and `…`.

_Note: The symbols are only correctly displayed if your font supports these characters._

### More Buffers

##### `g:lightline#bufferline#disable_more_buffers_indicator`

Disables the more buffers indicator so that all buffers are always shown on the bufferline even if they don't fit the available space. Default is `0`.

##### `g:lightline#bufferline#max_width`

The *more buffers* functionality determines the available space for the bufferline and calculates
how many buffers can be shown until the *more buffers* indicator is displayed.
The default function to calculate the available space for the buffers returns the number of columns: `&columns`.
To customize the available space calculation this option can be set to the name of a custom function which will be used instead.

The function receives no parameters and should return the amount of available space for the bufferline.
For example if you know that you have exactly 80 columns space for the bufferline you can specify the following function:
```viml
function LightlineBufferlineMaxWidth()
  return 80
endfunction

let g:lightline#bufferline#max_width = "LightlineBufferlineMaxWidth"
```

### Numbering

##### `g:lightline#bufferline#show_number`

Defines whether to add the buffer number to the buffer name. Default is `0`.
Valid values are:

- `0`: No numbers
- `1`: Buffer number as shown by the `:ls` command
- `2`: Ordinal number (buffers are numbered from _1_ to _n_ sequentially)
- `3`: Buffer number followed by ordinal number
- `4`: Ordinal number followed by buffer number

The separator between ordinal and regular buffer number can be configured using the option `g:lightline#bufferline#ordinal_separator`.
The separator between the buffer numbers and the buffer name can be configured using the option `g:lightline#bufferline#number_separator`.

For option `2`, `3` and `4` the number maps `g:lightline#bufferline#ordinal_number_map` and `g:lightline#bufferline#composed_ordinal_number_map` are used for ordinal numbers. For regular buffer numbers the number maps `g:lightline#bufferline#buffer_number_map` and `g:lightline#bufferline#composed_buffer_number_map` are used. The number maps are described below.

##### `g:lightline#bufferline#composed_ordinal_number_map`

Dictionary mapping ordinal numbers to their alternative character representations. Default is `{}`.

For example, to use parenthesized unicode numbers taken from [Enclosed Alphanumerics Unicode block](https://unicode.org/charts/nameslist/c_2460.html):

```viml
let g:lightline#bufferline#composed_ordinal_number_map = {
\ 1:  '⑴ ', 2:  '⑵ ', 3:  '⑶ ', 4:  '⑷ ', 5:  '⑸ ',
\ 6:  '⑹ ', 7:  '⑺ ', 8:  '⑻ ', 9:  '⑼ ', 10: '⑽ ',
\ 11: '⑾ ', 12: '⑿ ', 13: '⒀ ', 14: '⒁ ', 15: '⒂ ',
\ 16: '⒃ ', 17: '⒄ ', 18: '⒅ ', 19: '⒆ ', 20: '⒇ '}
```

_Note: The option only applies when `g:lightline#bufferline#show_number` is set to `2`, `3` or `4`._

##### `g:lightline#bufferline#ordinal_number_map`

Fallback dictionary mapping digits (0-9) which are used in ordinal number composing if the number is not mapped in `g:lightline#bufferline#composed_ordinal_number_map`. Default is `{}`.

For example, to use unicode superscript numerals:

```viml
let g:lightline#bufferline#ordinal_number_map = {
\ 0: '⁰', 1: '¹', 2: '²', 3: '³', 4: '⁴',
\ 5: '⁵', 6: '⁶', 7: '⁷', 8: '⁸', 9: '⁹'}
```

... or unicode subscript numerals:

```viml
let g:lightline#bufferline#ordinal_number_map = {
\ 0: '₀', 1: '₁', 2: '₂', 3: '₃', 4: '₄',
\ 5: '₅', 6: '₆', 7: '₇', 8: '₈', 9: '₉'}
```

_Note: The option only applies when `g:lightline#bufferline#show_number` is set to `2`, `3` or `4`._

##### `g:lightline#bufferline#composed_buffer_number_map`

Dictionary mapping regular buffer numbers to their alternative character representations. Default is `{}`.

See `g:lightline#bufferline#composed_ordinal_number_map` for example values.

_Note: The option only applies when `g:lightline#bufferline#show_number` is set to `2`, `3` or `4`._

##### `g:lightline#bufferline#buffer_number_map`

Fallback dictionary mapping digits (0-9) which are used in regular buffer number composing if the number is not mapped in `g:lightline#bufferline#composed_buffer_number_map`. Default is `{}`.

See `g:lightline#bufferline#ordinal_number_map` for example values.

_Note: The option only applies when `g:lightline#bufferline#show_number` is set to `2`, `3` or `4`._

##### `g:lightline#bufferline#number_separator`

Defines the string which is used to separate the buffer number (if enabled) and the buffer name. Default is `' '`.

##### `g:lightline#bufferline#ordinal_separator`

Defines the string which is used to separate the buffer number and the ordinal number. Default is `''`.

### Icons

##### `g:lightline#bufferline#enable_devicons`

Enables the usage of [vim-devicons](https://github.com/ryanoasis/vim-devicons) or [nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons) to display a filetype icon for the buffer.
Default is `0`.

##### `g:lightline#bufferline#enable_nerdfont`

Enables the usage of [nerdfont.vim](https://github.com/lambdalisue/nerdfont.vim) to display a filetype icon for the buffer.
Default is `0`.

##### `g:lightline#bufferline#icon_position`

Defines the position of the filetype icon. Default is `left`.
Valid values are:

- `left`: Left of the buffer name and after the buffer number
- `right`: Right of the buffer name
- `first`: Left of the buffer name and number

### Hiding

##### `g:lightline#bufferline#auto_hide`

Automatically hides the bufferline `n` milliseconds after switching the buffer.
For example to show the bufferline for 4 seconds when switching the buffer and hide it afterwards use the following setting:
```viml
let g:lightline#bufferline#auto_hide = 4000
```

Default is `0` and disables the auto-hide behaviour.

##### `g:lightline#bufferline#min_buffer_count`

Hides the bufferline by default and shows it if there are `n` or more buffers. Default is `0` and the bufferline is always shown.
If `min_tab_count` is also specified the bufferline will be shown if one of the conditions is met.

##### `g:lightline#bufferline#min_tab_count`

Hides the bufferline by default and shows it if there are `n` or more tabs. Default is `0` and the bufferline is always shown.
If `min_buffer_count` is also specified the bufferline will be shown if one of the conditions is met.
This option can be useful if you are also displaying tabs in the lightline tabline.

### Filtering

##### `g:lightline#bufferline#filter_by_tabpage`

When more than one tab is opened, only buffers that are open in a window within the current tab are shown. When there
is only one tab, all buffers are shown. Default is `0`.
This option can be useful if you are also displaying tabs in the lightline tabline.

##### `g:lightline#bufferline#buffer_filter`

This can be set to the name of a custom buffer filter function which will be used in addition to the standard buffer filtering.
The function receives the buffer number as parameter and should return `1` to include the buffer and `0` to hide the buffer in the bufferline.
For example to hide all neovim terminal buffers use this code in your vim config:
```viml
function LightlineBufferlineFilter(buffer)
  return getbufvar(a:buffer, '&buftype') !=# 'terminal'
endfunction

let g:lightline#bufferline#buffer_filter = "LightlineBufferlineFilter"
```

Instead of just `1` or `0`, you can also return a string with a custom category name.
The bufferline will only display the buffers with the same category as the active one.
If the active buffer is hidden (empty string `''` or `0`) it will instead display category `'default'` (equivalent to `1`).
This may be useful if you want to display different categories of buffers in different splits, and be able to jump between buffers without mixing categories.
For example, if you want to keep all your terminals in a separate split, you can modify the function above:
```viml
function LightlineBufferlineFilter(buffer)
  return getbufvar(a:buffer, '&buftype') ==# 'terminal' ? 'terminal' : 1
endfunction
```

## Mappings

This plugin provides Plug mappings to switch to buffers using their ordinal number in the bufferline.
To display the ordinal numbers in the bufferline use the setting `g:lightline#bufferline#show_number = 2`.

To use the Plug mappings to navigate to buffers you can use e.g. these mappings:

```viml
nmap <Leader>1 <Plug>lightline#bufferline#go(1)
nmap <Leader>2 <Plug>lightline#bufferline#go(2)
nmap <Leader>3 <Plug>lightline#bufferline#go(3)
nmap <Leader>4 <Plug>lightline#bufferline#go(4)
nmap <Leader>5 <Plug>lightline#bufferline#go(5)
nmap <Leader>6 <Plug>lightline#bufferline#go(6)
nmap <Leader>7 <Plug>lightline#bufferline#go(7)
nmap <Leader>8 <Plug>lightline#bufferline#go(8)
nmap <Leader>9 <Plug>lightline#bufferline#go(9)
nmap <Leader>0 <Plug>lightline#bufferline#go(10)

nmap <Tab>   <Plug>lightline#bufferline#go_next()
nmap <S-Tab> <Plug>lightline#bufferline#go_previous()
nmap <Leader><Tab>   <Plug>lightline#bufferline#go_next_category()
nmap <Leader><S-Tab> <Plug>lightline#bufferline#go_previous_category()
```

For reordering buffers, you can use e.g. these mappings:

```viml
nmap <Leader>bl <Plug>lightline#bufferline#move_next()
nmap <Leader>bh <Plug>lightline#bufferline#move_previous()
nmap <Leader>bk <Plug>lightline#bufferline#move_first()
nmap <Leader>bj <Plug>lightline#bufferline#move_last()
nmap <Leader>bb <Plug>lightline#bufferline#reset_order()
```

Additionally you can use the following e.g. to delete buffers by their ordinal number.

```viml
nmap <Leader>c1 <Plug>lightline#bufferline#delete(1)
nmap <Leader>c2 <Plug>lightline#bufferline#delete(2)
nmap <Leader>c3 <Plug>lightline#bufferline#delete(3)
nmap <Leader>c4 <Plug>lightline#bufferline#delete(4)
nmap <Leader>c5 <Plug>lightline#bufferline#delete(5)
nmap <Leader>c6 <Plug>lightline#bufferline#delete(6)
nmap <Leader>c7 <Plug>lightline#bufferline#delete(7)
nmap <Leader>c8 <Plug>lightline#bufferline#delete(8)
nmap <Leader>c9 <Plug>lightline#bufferline#delete(9)
nmap <Leader>c0 <Plug>lightline#bufferline#delete(10)
```

## Functions

This plugin provides some public functions to interact with the plugin.

#### `lightline#bufferline#reload()`

This function reloads the plugin configuration (e.g. when you have modified the configuration after vim is already running) and refreshes lightline.

#### `lightline#bufferline#get_ordinal_number_for_buffer(buffer)`

This function returns the ordinal number for the given `buffer` or `-1` if the buffer is not found.

#### `lightline#bufferline#get_buffer_for_ordinal_number(n)`

This function returns the buffer for the ordinal number specified by parameter `n` or `-1` if no buffer is found.

#### `lightline#bufferline#go(n)`

This function switches to the buffer with the ordinal number specified by parameter `n`.
To switch to the first buffer using a mapping you can use the function like this:

```viml
nmap <Leader>1 :call lightline#bufferline#go(1)<CR>
```

#### `lightline#bufferline#go_relative(offset)`

This function switches to the buffer `offset` positions relative to the current buffer.
Passing a value of `1` for `offset` would switch to the next buffer, while a value of `-1` would switch to the previous buffer.

#### `lightline#bufferline#go_next()`

This function switches to the next buffer in the bufferline.

#### `lightline#bufferline#go_previous()`

This function switches to the previous buffer in the bufferline.

#### `lightline#bufferline#go_next_category()`

This function switches to the first buffer in the next category.

#### `lightline#bufferline#go_previous_category()`

This function switches to the first buffer in the previous category.

#### `lightline#bufferline#move(target)`

This function moves current buffer to given ordinal position.

#### `lightline#bufferline#move_relative(offset)`

This function moves current buffer by given number of positions.
Passing a value of `1` for `offset` would move current buffer one position to right,
while a value of `-1` would move it one position to left.

#### `lightline#bufferline#move_next()`

This function moves current buffer one position to the right.

#### `lightline#bufferline#move_previous()`

This function moves current buffer one position to the left.

#### `lightline#bufferline#move_first()`

This function moves current buffer one position to the first position.

#### `lightline#bufferline#move_last()`

This function moves current buffer one position to the last position.

#### `lightline#bufferline#reset_order()`

This function resets the order of all buffers to default, which is the order buffers were created.

#### `lightline#bufferline#delete(n)`

This function deletes the buffer with the ordinal number specified by parameter `n`.
To delete the first buffer using a mapping you can use the function like this:

```viml
nmap <D-1> :call lightline#bufferline#delete(1)<CR>
```

## Example

The following minimal example adds the bufferline to the lightline tabline and demonstrates a few custom bufferline options:

```viml
let g:lightline#bufferline#show_number  = 1
let g:lightline#bufferline#shorten_path = 0
let g:lightline#bufferline#unnamed      = '[No Name]'

let g:lightline                  = {}
let g:lightline.tabline          = {'left': [['buffers']], 'right': [['close']]}
let g:lightline.component_expand = {'buffers': 'lightline#bufferline#buffers'}
let g:lightline.component_type   = {'buffers': 'tabsel'}
```

## FAQ

**Q:** I can't see the tabline!<br/>
**A:** Add `set showtabline=2` to your configuration. This forces the tabline to always show.

**Q:** My vim GUI (MacVim, gVim, etc.) displays a graphical tabline and not the lightline tabline!<br/>
**A:** Add `set guioptions-=e` to your configuration (and guard it with `if has('gui_running') ... endif`).
This will disable the GUI tabline and enable the lightline tabline.

**Q:** How can I hide the path and show only the filename?<br/>
**A:** Add `let g:lightline#bufferline#filename_modifier = ':t'` to your configuration.

**Q:** My buffer filter behaves oddly when trying to use filetype!<br/>
**A:** `getbufvar(a:buffer, '&filetype')` return an empty string before buffer is loaded, e.g. when opening multiple files. You can use file extension `fnamemodify(bufname(a:buffer), ':e')` as a fallback.

**Q:** How to dynamically change how a single buffer is filtered?<br/>
**A:** You can declare a buffer local variable (e.g. `let b:buffer_filter_override = 0`) and check if it exists at the entry of your filter function.

## License

Released under the [MIT License](LICENSE)
