local M = {
  colorscheme = "kanagawa-dragon",
  lualine_theme = "kanagawa",
  plugin = {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    config = function()
      require("kanagawa").setup({
        dimInactive = true,
        keywordStyle = { italic = false },
        statementStyle = { bold = false },
      })
      vim.cmd.colorscheme("kanagawa-dragon")
    end,
  },
}

return M
