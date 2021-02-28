local devicons = require('nvim-web-devicons')

local M = {}

M._get_icon = function (path)
  local filename = vim.fn.fnamemodify(path, ':t')
  local extension = vim.fn.fnamemodify(path, ':e')
  local icon = devicons.get_icon(filename, extension, { default = true })
  if icon then
    return icon
  else
    return ""
  end
end

return M
