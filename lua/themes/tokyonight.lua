local M = {
  colorscheme = "tokyonight-night",
  lualine_theme = "tokyonight",
  plugin = {
    "folke/tokyonight.nvim",
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
        transparent = false,
        styles = {
          comments = { italic = true },
          keywords = { italic = false },
          functions = { bold = true },
        },
        dim_inactive = true,
      })
      vim.cmd.colorscheme("tokyonight-night")
    end,
  },
}

return M
