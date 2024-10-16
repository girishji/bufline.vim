if !has('vim9script') ||  v:version < 900
    " Needs Vim version 9.0 and above
    finish
endif

vim9script

# Statusline helper plugin for Vim to get a list of buffers appropriate for
# display in statusline.

g:loaded_bufline = true

var options: dict<any> = {
    showbufnr: false,
    emphasize: '<#', # <, [, %, #, or empty
    highlight: false,
}

def! g:BuflineSetup(opt: dict<any>)
    options->extend(opt)
enddef

def Bufstr(bufnr: number): string
    var bname = bufname(bufnr) != '' ? fnamemodify(bufname(bufnr), ":t") : '(No Name)'
    var mod = getbufvar(bufnr, "&mod") ? "[+]" : ""
    var altstr = options.emphasize =~ '#' && bufnr('#') == bufnr &&
        bufnr('%') != bufnr ? '#' : ''
    if options.showbufnr
        return $'{altstr}{bname}{mod},{bufnr}'
    else
        return $'{altstr}{bname}{mod}'
    endif
enddef

def! g:BuflineGetstr(maxwidth: number = 0): string
    var remaining = maxwidth <= 0 ? winwidth(0) - 50 : maxwidth
    var listedbufs = getbufinfo({buflisted: 1})
    var curbufnr = bufnr('%')
    var curbufidx = listedbufs->indexof((_, v) => v.bufnr == curbufnr)
    var curbufstr = Bufstr(curbufnr)
    var higr = options.highlight ? '%4*' : ''
    var empstrl = options.emphasize =~ '<' ? $'{higr}<%*' : ''
    var empstrr = options.emphasize =~ '<' ? $'{higr}>%*' : ''
    empstrl = options.emphasize =~ '[' ? $'{higr}[%*' : empstrl
    empstrr = options.emphasize =~ '[' ? $'{higr}]%*' : empstrr
    var empstr = options.emphasize =~ '%' ? $'{higr}%%%*' : ''
    higr = options.highlight ? '%1*' : ''
    var bufliststr = $'{empstr}{empstrl}{higr}{curbufstr}%*{empstrr}%*'
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
                bufliststr = forward ? $'{bufliststr} >' : $'< {bufliststr}'
                break
            endif
            higr = options.highlight ? bufnr('#') == itembufnr ? '%2*' : '%3*' : ''
            itemstr = $'{higr}{itemstr}%*'
            bufliststr = forward ? $'{bufliststr}  {itemstr}' : $'{itemstr}  {bufliststr}'
        endif
        idx += forward ? -hop : hop
        hop += 1
        forward = !forward
    endwhile
    return bufliststr
enddef
