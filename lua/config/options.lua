local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.cursorline = true
opt.cursorcolumn = false
opt.scrolloff = 5
opt.signcolumn = "yes"
opt.termguicolors = true
opt.updatetime = 400
opt.fillchars:append({ eob = "~" })

opt.wrap = true
opt.linebreak = true
opt.showbreak = "↪ "

opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4

opt.list = true
opt.listchars = {
  space = "·",
  tab = "→ ",
  trail = "•",
  nbsp = "⍽",
  extends = "›",
  precedes = "‹",
  eol = "⏎",
}

opt.splitbelow = true
opt.splitright = true
opt.completeopt = { "menu", "menuone", "noselect" }

opt.guicursor = {
  "n-v-c:block",
  "i-ci:ver25",
  "r-cr:hor20",
  "o:hor50",
  "sm:hor10",
}

local severity = vim.diagnostic.severity
local severity_prefix = {
  [severity.ERROR] = "E",
  [severity.WARN] = "W",
  [severity.INFO] = "I",
  [severity.HINT] = "H",
}

vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  signs = false,
  virtual_text = {
    spacing = 4,
    source = "if_many",
    prefix = function(diagnostic)
      return severity_prefix[diagnostic.severity] or "·"
    end,
  },
  float = {
    border = "rounded",
    source = "always",
  },
})

local eob_group = vim.api.nvim_create_augroup("VisibleEndOfBuffer", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
  group = eob_group,
  callback = function()
    vim.api.nvim_set_hl(0, "EndOfBuffer", { link = "NonText" })
  end,
})

vim.api.nvim_set_hl(0, "EndOfBuffer", { link = "NonText" })
