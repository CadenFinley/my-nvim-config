local M = {
  colorscheme = "vscode",
  lualine_theme = "vscode",
  plugin = {
    "Mofiqul/vscode.nvim",
    priority = 1000,
    config = function()
      require("vscode").setup({
        style = "dark",
        italic_comments = true,
        disable_nvimtree_bg = true,
      })
      vim.cmd.colorscheme("vscode")
    end,
  },
}

return M
