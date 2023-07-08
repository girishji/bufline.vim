# bufline.vim

I have been using statusline to permanently display buffer list. While
switching buffers it helps to know what other buffers are open and which is the
alternate buffer (`:b#`). This plugin does not set the statusline, but instead provides
a buffer list suitable for including in statusline. There are some useful
highlighting options to distinguish active and alternate buffers. Since so much
space is wasted on statusline why not put it to good use?

Implemented in both Vim9script and Lua.

### Screenshot

![image](https://raw.githubusercontent.com/girishji/bufstatusline.nvim/main/screenshots/light.png)

### Demo

[![asciicast](https://asciinema.org/a/zmJIdk2aDeiTLXhYE3b8qvHwy.svg)](https://asciinema.org/a/zmJIdk2aDeiTLXhYE3b8qvHwy)

# Requirements

- Vim >= 9.0
- Neovim >= 0.8

# Installation

Vim users can install using [vim-plug](https://github.com/junegunn/vim-plug)

```
vim9script
plug#begin()
Plug 'girishji/bufline.vim'
plug#end()
```

Or use Vim's builtin package manager.

Nvim users could use [Lazy](https://github.com/folke/lazy.nvim)

```lua
require("lazy").setup({
  { "girishji/bufline.vim", opts = {} },
})
```

# Configuration

### Vim

Global function `g:BuflineGetstr()` returns the string containing buffer names
with appropriate ellipsis and highlighting. You have to include this in
`statusline` variable. It takes optional `maxwidth` argument which specifies
string length. If buffer list exceeds `maxwidth` then overflow is indicated
by `<` on the left and/or `>` on the right.

Here is an example how you might use this. Configuration is in vim9script but
you could easily convert this into legacy script.

```vim
vim9script
def! g:MyActiveStatusline(): string
    var width = winwidth(0) - 50
    return $'{g:BuflineGetstr(width)} %=%y %P (%l:%c) %*'
enddef

augroup MyStatusLine | autocmd!
    autocmd WinEnter,BufEnter,BufAdd * setl statusline=%{%g:MyActiveStatusline()%}
    autocmd WinLeave,BufLeave * setl statusline=\ %F\
augroup END
```

### Nvim

Function `bufferstr()` is used instead of `g:BuflineGetstr()`.

Here is an example.

```lua
Statusline = {}
Statusline.active = function()
  return table.concat { require('bufline').bufferstr(), "%=%y %P %l:%c %*" }
end
Statusline.inactive = function()
  return " %F"
end

local aucmd_group = vim.api.nvim_create_augroup('StatuslineAutocmds', { clear = true })
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "BufAdd" }, {
  group = aucmd_group,
  pattern = "*",
  callback = function()
    vim.wo.statusline = "%!v:lua.Statusline.active()"
  end,
})
vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
  group = aucmd_group,
  pattern = "*",
  callback = function()
    vim.wo.statusline = "%!v:lua.Statusline.inactive()"
  end,
})
```

# Options

### Vim

Following options are available.

```vim
var options: dict<any> = {
    showbufnr: false, # display buffer number next to name
    emphasize: '[#',  # [, %, #, or empty
    highlight: false, # Use highlight groups if 'true'
}
```

Emphasis characters have following meaning:

- `[`: Include parenthesis around active buffer name, `buf1 [active buf]  buf2`
- `%`: Include a percent sign next to active buffer
- `#`: Include a pound sign next to alternate buffer

These characters can be combined. Default is `[#`. Empty string removes all
emphasis characters. You can still distinguish active buffer using highlight
groups.

`g:BuflineSetup()` is used to set options. It takes a dictionary.

```vim
def! g:MyStatuslineSetup(isclear: bool)
    highlight user4 ctermfg=134 cterm=none
    g:BuflineSetup({ highlight: true })
enddef

autocmd VimEnter * g:MyStatuslineSetup(v:true)
```

### Nvim

Same as above except `setup()` is used.

```lua
require("bufline").setup({
  opts = {
    showbufnr = false, -- displays buffer number next to buffer name
    emphasize = '[#',  -- [, %, #, or empty
    highlight = false, -- Use highlight groups if 'true'
  },
})
```

Same explanation as above for emphasis characters.

### Highlight Groups

Following highlight groups are available. If you are using any colorscheme set
these highlights after you activate the colorscheme.

- `User1`: Active buffer
- `User2`: Alternate buffer
- `User3`: Other buffers
- `User4`: Emphasis characters if specified (see Options)
