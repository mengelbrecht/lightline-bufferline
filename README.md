# lightline-bufferline

This plugin provides bufferline functionality for the [lightline](https://github.com/itchyny/lightline.vim) vim plugin.

![](bufferline.png)

## Table Of Contents

- [Installation](#installation)
- [Integration](#integration)
- [Configuration](#configuration)
- [Example](#example)
- [License](#license)

## Installation

Installation can be easily done with a plugin manager of your choice. For example [vim-plug](https://github.com/junegunn/vim-plug):
```viml
Plug 'mgee/lightline-bufferline'
```

## Integration

1. Add `'buffers'` to `g:lightline.tabline`.
2. Add `'buffers': 'lightline#bufferline#buffers'` to `g:lightline.component_expand`.
3. Add `'buffers': 'tabsel'` to `g:lightline.component_type`.

The result looks for example like this:
```viml
let g:lightline.tabline          = {'left': [['buffers']], 'right': [['close']]}
let g:lightline.component_expand = {'buffers': 'lightline#bufferline#buffers'}
let g:lightline.component_type   = {'buffers': 'tabsel'}
```

## Configuration

##### `g:lightline#bufferline#filename_modifier`

The filename-modifier applied to each buffer name. Default is `':.'`.

##### `g:lightline#bufferline#modified`

The indicator to use for a modified buffer. Default is `'+'`.

##### `g:lightline#bufferline#shorten_path`

Defines whether to shorten the path using the `pathshorten` function. Default is `1`.

##### `g:lightline#bufferline#show_number`

Defines whether to add the buffer number to the buffer name. Default is `0`.

##### `g:lightline#bufferline#unnamed`

The name to use for unnamed buffers. Default is `'*'`.

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

## License

Released under the [MIT License](LICENSE)
