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
    emphasize: '%#', # <, [, %, #, or empty
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
        return $'{bname}{mod},{bufnr}{altstr}'
    else
        return $'{bname}{mod}{altstr}'
    endif
enddef

def HL(grp: number): string
    return options.highlight ? (!hlget('user' .. grp)->empty() ? $'%{grp}*' : '') : ''
enddef

# Assign default highlight attributes if option is set but highlight groups are undefined.
def DefaultHL()
    def Defined(grp: number): bool
        return !hlget($'user{grp}')->empty()
    enddef
    if options.highlight &&
            range(1, 4)->map((_, v) => Defined(v)) == repeat([false], 4)
        var hlattr = hlget('StatusLine', true)
        highlight user1 cterm=bold,underline
        if !hlattr->empty()
            var fg = hlattr[0]->get("ctermfg", "None")
            var bg = hlattr[0]->get("ctermbg", "None")
            var ct = hlattr[0]->get("cterm", {})->items()->map((_, v) => v[1] ? v[0] : '')
            var cterm = ct->copy()->filter((_, v) => v != '')->join(',')
            for grp in ['user1', 'user2', 'user3', 'user4']
                exec 'highlight' grp $'ctermfg={fg} ctermbg={bg} {cterm != "" ? ("cterm=" .. cterm) : ""}'
            endfor
            exec $'highlight user1 cterm={cterm != "" ? (cterm .. ",") : ""}bold,underline'
        endif
    endif
enddef

def! g:BuflineGetstr(maxwidth: number = 0): string
    DefaultHL()
    var remaining = maxwidth <= 0 ? winwidth(0) - 50 : maxwidth
    var listedbufs = getbufinfo({buflisted: 1})
    var curbufnr = bufnr('%')
    var curbufidx = listedbufs->indexof((_, v) => v.bufnr == curbufnr)
    var curbufstr = Bufstr(curbufnr)
    var higr = HL(4)
    var empstrl = options.emphasize =~ '<' ? $'{higr}<%*' : ''
    var empstrr = options.emphasize =~ '<' ? $'{higr}>%*' : ''
    empstrl = options.emphasize =~ '[' ? $'{higr}[%*' : empstrl
    empstrr = options.emphasize =~ '[' ? $'{higr}]%*' : empstrr
    var empstr = options.emphasize =~ '%' ? $'{higr}%%%*' : ''
    var bufliststr = $'{empstrl}{HL(1)}{curbufstr}%*{empstrr}%*{empstr}%*'
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
            higr = bufnr('#') == itembufnr ? HL(2) : HL(3)
            itemstr = $'{higr}{itemstr}%*'
            bufliststr = forward ? $'{bufliststr}  {itemstr}' : $'{itemstr}  {bufliststr}'
        endif
        idx += forward ? -hop : hop
        hop += 1
        forward = !forward
    endwhile
    return bufliststr
enddef
