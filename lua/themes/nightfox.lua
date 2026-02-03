local M = {
  colorscheme = "nightfox",
  lualine_theme = "nightfox",
  plugin = {
    "EdenEast/nightfox.nvim",
    priority = 1000,
    config = function()
      require("nightfox").setup({
        options = {
          dim_inactive = true,
          terminal_colors = true,
          styles = {
            comments = "italic",
            keywords = "bold",
          },
        },
      })
      vim.cmd.colorscheme("nightfox")
    end,
  },
}

return M
