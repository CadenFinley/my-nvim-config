vim.g.mapleader = " "
vim.g.maplocalleader = " "

if not vim.uv.cwd() then
  local fallback = vim.uv.os_homedir() or vim.fn.stdpath("config")
  if type(fallback) == "string" and fallback ~= "" and vim.fn.isdirectory(fallback) == 1 then
    vim.api.nvim_set_current_dir(fallback)
  end
end

require("config.options")
require("config.keymaps")
-- require("config.intro")
require("config.lazy")
