vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

local python3_host = vim.fn.exepath("python3")
if python3_host ~= "" then
  vim.g.python3_host_prog = python3_host
end

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
