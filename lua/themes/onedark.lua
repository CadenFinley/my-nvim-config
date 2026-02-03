local M = {
  colorscheme = "onedark",
  lualine_theme = "onedark",
  plugin = {
    "navarasu/onedark.nvim",
    priority = 1000,
    config = function()
      local onedark = require("onedark")
      onedark.setup({
        style = "darker",
        code_style = {
          comments = "italic",
          keywords = "bold",
        },
        diagnostics = {
          background = true,
        },
      })
      onedark.load()
    end,
  },
}

return M
