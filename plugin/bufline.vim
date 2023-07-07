if !has('vim9script') ||  v:version < 900
  " Needs Vim version 9.0 and above
  finish
endif

vim9script

# Statusline helper plugin for Vim to get a list of buffers appropriate for
# display in statusline.

g:loaded_bufline = true
g:bufline_linenr = true

def Bufstr(bufnr: number): string
    var bname = bufname(bufnr) != '' ? fnamemodify(bufname(bufnr), ":t") : '(No Name)'
    var mod = getbufvar(bufnr, "&mod") ? "[+]" : ""
    var bufnrstr = bufnr('#') == bufnr && bufnr('%') != bufnr ? $'{bufnr}#' : $'{bufnr}'
    return $'{bname}{mod}{g:bufline_linenr ? $',{bufnrstr}' : ""}'
enddef

def! g:Bufline(maxwidth: number): string
    var remaining = maxwidth
    var listedbufs = getbufinfo({buflisted: 1})
    var curbufnr = bufnr('%')
    var curbufidx = listedbufs->indexof("v:val.bufnr == curbufnr")
    var curbufstr = Bufstr(curbufnr)
    var bufliststr = $'%1*{curbufstr)}%*'
    remaining -= curbufstr->len()
    var idx = curbufidx - 1
    var hop = 2
    var forward = false
    var idxmax = max([listedbufs->len() - 1 - curbufidx, curbufidx])
    while idx >= curbufidx - idxmax && idx <= curbufidx + idxmax
	if idx >= 0 && idx < listedbufs->len()
	    var itembufnr = listedbufs[idx].bufnr
	    var itemstr = Bufstr(itembufnr)
	    remaining -= itemstr->len() + 2 # 2 space chars
	    if remaining < 0 
		bufliststr = forward ? $'{bufliststr}>' : $'<{bufliststr}'
		break
	    endif
	    itemstr = $'{bufnr("#") == itembufnr ? "%2*" : "%3*"}{itemstr}%*'
	    bufliststr = forward ? $'{bufliststr}  {itemstr}' : $'{itemstr}  {bufliststr}'
	endif
	idx += forward ? -hop : hop
	hop += 1
	forward = !forward
    endwhile
    return bufliststr
enddef

highlight user1 cterm=reverse   ctermbg=none ctermfg=none
highlight user2 cterm=italic    ctermbg=none ctermfg=none
highlight user3 cterm=none      ctermbg=none ctermfg=none
