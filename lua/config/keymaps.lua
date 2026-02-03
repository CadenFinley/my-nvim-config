local map = vim.keymap.set
local function telescope_pick(name)
  return function()
    local ok, builtin = pcall(require, "telescope.builtin")
    if ok then
      builtin[name]()
    else
      vim.notify("Telescope is not available", vim.log.levels.WARN)
    end
  end
end

map({ "n", "i" }, "<C-s>", "<Cmd>w<CR>", { desc = "Save file" })
map("n", "<C-q>", "<Cmd>q<CR>", { desc = "Quit window" })
map("n", "<leader>l", "<Cmd>Lazy<CR>", { desc = "Open Lazy" })
map("n", "<leader>e", "<Cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })

map("n", "<leader>f", telescope_pick("find_files"), { desc = "Find files" })
map("n", "<leader>g", telescope_pick("live_grep"), { desc = "Search project" })
map("n", "<leader>b", telescope_pick("buffers"), { desc = "List buffers" })
map("n", "<leader>hf", telescope_pick("help_tags"), { desc = "Search help" })
