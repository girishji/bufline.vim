# bufline.vim

I have been using Vim's statusline to permanently display buffer list. While working
with many buffers it helps to know which other buffers are open, and if there
is an alternate buffer (`:b#`) to quickly switch to. This plugin does not set
the statusline (`:h 'statusline'`), but instead provides a buffer list suitable
for displaying in statusline. This way you can configure the statusline to your liking.
It is fully configurable with highlighting options to distinguish active and
alternate buffers. Since so much space is wasted on statusline why not put it
to good use?

Implemented in both Vim9script and Lua, and compatible with both Vim and Neovim.

### Screenshot

![image](https://raw.githubusercontent.com/girishji/bufline.vim/main/screenshots/lightbg.png)

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
and appropriate overflow indicators with highlighting. You have to include this in
Vim's `statusline` variable. It takes optional `maxwidth` argument which specifies
the length of returned string. If buffer list exceeds `maxwidth` then overflow is indicated
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

Function `bufferstr()` returns the string containing buffer names. Other
details are similar to Vim.

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

- `[`: Include parenthesis around active buffer name, ex., `buf1  [active buf]  buf2`
- `%`: Include a percent sign next to active buffer
- `#`: Include a pound sign next to alternate buffer

These characters can be combined. Default is `[#`. Empty string removes all
emphasis characters. You can still distinguish active buffer using highlight
groups.

Modified buffers are always shown with a `[+]` sign.

`g:BuflineSetup()` is used to set options. It takes a dictionary.

```vim
def! g:MyStatuslineSetup(isclear: bool)
    highlight user4 ctermfg=134 cterm=none
    g:BuflineSetup({ highlight: true })
enddef

autocmd VimEnter * g:MyStatuslineSetup(v:true)
```

### Nvim

Same as above except `setup()` function is used.

```lua
require("bufline").setup({
  opts = {
    showbufnr = false, -- displays buffer number next to buffer name
    emphasize = '[#',  -- [, %, #, or empty
    highlight = false, -- Use highlight groups if 'true'
  },
})
```

### Highlight Groups

Following highlight groups are available to set colors and style of text. If
you are using a colorscheme, set these highlights after you activate the colorscheme.

- `User1`: Active buffer
- `User2`: Alternate buffer
- `User3`: Other buffers
- `User4`: Emphasis characters if specified (see Options)
