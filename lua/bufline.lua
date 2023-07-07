local M = {}

M.opts = {
  showbufnr = false, -- display buffer number
  emphasize = '[#',  -- [, #, %, or empty
  highlight = false,
}

M.setup = function(opts)
  M.opts = vim.tbl_extend('force', M.opts, opts or {})
end

M.bufferstr = function(maxwidth)
  local curbuf = vim.api.nvim_get_current_buf()
  ---@diagnostic disable-next-line: param-type-mismatch
  local altbuf = vim.fn.bufnr('#')
  local bufs = {}
  local winwidth = maxwidth
  if maxwidth <= 0 then
    winwidth = vim.api.nvim_win_get_width(0) - 50
  end
  local spacer = "  "
  local insertbuf = function(buf, front)
    local bufname = vim.api.nvim_buf_get_name(buf)
    if not bufname or bufname == '' then
      bufname = '(No Name)'
    else
      local fragments = vim.split(bufname, "/", { plain = true, trimempty = true })
      bufname = fragments[#fragments]
      if not bufname then return end
    end
    winwidth = winwidth - string.len(bufname) - string.len(spacer)
    local pos = front and 1 or (#bufs + 1)
    local isbufmodified = function(bufnr)
      return vim.fn.getbufvar(bufnr, "&mod") == 1 and "[+]" or ""
    end
    if winwidth >= 0 then
      local bufnr = M.opts.showbufnr and ("," .. buf) or ""
      -- NOTE: %1* refers to User1 highlight group
      if buf == curbuf then
        local emphasizel = string.match(M.opts.emphasize, '%[') and "[" or ''
        local emphasizer = string.match(M.opts.emphasize, '%[') and "]" or ''
        local emphasize = string.match(M.opts.emphasize, '%%') and "%" or ''
        if M.opts.highlight then
          emphasizel = "%4*" .. emphasizel .. "%*"
          emphasizer = "%4*" .. emphasizer .. "%*"
          emphasize = "%4*" .. emphasize .. "%*"
        end
        local higrp = M.opts.highlight and "%1*" or ""
        table.insert(bufs, pos,
          emphasizel .. higrp .. bufname .. bufnr .. isbufmodified(buf) .. "%*" .. emphasizer .. emphasize)
      elseif buf == altbuf then
        local emphasize = string.match(M.opts.emphasize, '%#') and "#" or ''
        if M.opts.highlight then
          emphasize = "%4*" .. emphasize .. "%*"
        end
        local higrp = M.opts.highlight and "%2*" or ""
        table.insert(bufs, pos, higrp .. bufname .. bufnr .. isbufmodified(buf) .. "%*")
      else
        local higrp = M.opts.highlight and "%3*" or ""
        table.insert(bufs, pos, higrp .. bufname .. bufnr .. isbufmodified(buf) .. "%*")
      end
      return true
    end
    return false
  end

  local buflist = vim.api.nvim_list_bufs()
  local curbufidx = nil
  for i, bufnr in ipairs(buflist) do
    if bufnr == curbuf then
      curbufidx = i
      break
    end
  end
  insertbuf(curbuf)
  local left = curbufidx - 1
  local right = curbufidx + 1
  local left_excess = false
  local right_excess = false
  while left > 0 or right <= #buflist do
    if left > 0 and vim.api.nvim_buf_get_option(buflist[left], 'buflisted') and not left_excess then
      if not insertbuf(buflist[left], true) then left_excess = true end
    end
    if right <= #buflist and vim.api.nvim_buf_get_option(buflist[right], 'buflisted') and not right_excess then
      if not insertbuf(buflist[right]) then right_excess = true end
    end
    left = left - 1
    right = right + 1
  end

  local bufstr = " " .. table.concat(bufs, spacer)
  if left_excess then
    bufstr = " <" .. bufstr
  end
  if right_excess then
    bufstr = bufstr .. " >"
  end
  return bufstr
end

return M
