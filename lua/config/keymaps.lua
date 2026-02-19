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

local function open_last_buffer_or_file()
  local alt_buf = vim.fn.bufnr("#")
  if alt_buf > 0 and vim.fn.buflisted(alt_buf) == 1 then
    vim.cmd("buffer #")
    return
  end

  local oldfiles = vim.v.oldfiles or {}
  for _, file in ipairs(oldfiles) do
    if file ~= "" and vim.fn.filereadable(file) == 1 then
      vim.cmd("edit " .. vim.fn.fnameescape(file))
      return
    end
  end

  vim.notify("No previous buffer or recent file found", vim.log.levels.WARN)
end

map({ "n", "i" }, "<C-s>", "<Cmd>w<CR>", { desc = "Save file" })
map("n", "<C-q>", "<Cmd>q<CR>", { desc = "Quit window" })
map("n", "<leader><leader>", open_last_buffer_or_file, { desc = "Last buffer or recent file" })
map("n", "<leader>l", "<Cmd>Lazy<CR>", { desc = "Open Lazy" })
map("n", "<leader>e", "<Cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
map("n", "<leader>vs", "<Cmd>vsplit<CR>", { desc = "Vertical split" })

map("n", "<leader>f", telescope_pick("find_files"), { desc = "Find files" })
map("n", "<leader>g", telescope_pick("live_grep"), { desc = "Search project" })
map("n", "<leader>b", telescope_pick("buffers"), { desc = "List buffers" })
map("n", "<leader>hf", telescope_pick("help_tags"), { desc = "Search help" })

map("n", "m", "10j", { desc = "Scroll down 10 lines" })
map("n", ",", "10k", { desc = "Scroll up 10 lines" })
