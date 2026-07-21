local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local function telescope_builtin(name)
  return function()
    local ok, builtin = pcall(require, "telescope.builtin")
    if ok then
      local cwd = vim.uv.cwd()
      if type(cwd) ~= "string" or cwd == "" or vim.fn.isdirectory(cwd) ~= 1 then
        local home = vim.uv.os_homedir()
        if type(home) == "string" and home ~= "" and vim.fn.isdirectory(home) == 1 then
          cwd = home
        else
          cwd = vim.fn.stdpath("config")
        end
      end

      builtin[name]({ cwd = cwd })
    else
      vim.notify("Telescope is not available", vim.log.levels.WARN)
    end
  end
end

local theme = require("themes")

local function patch_treesitter_query_all_option()
  local ok, query = pcall(require, "vim.treesitter.query")
  if not ok or query._compat_add_predicate_all_false then
    return
  end

  local function wrap_if_all_false(handler, opts)
    if type(opts) ~= "table" or opts.all ~= false then
      return handler
    end

    return function(match, pattern, source, predicate, metadata)
      local compat_match = {}
      for capture_id, captures in pairs(match) do
        if type(captures) == "table" then
          compat_match[capture_id] = captures[#captures] or captures[1]
        else
          compat_match[capture_id] = captures
        end
      end
      return handler(compat_match, pattern, source, predicate, metadata)
    end
  end

  local add_directive = query.add_directive
  query.add_directive = function(name, handler, opts)
    return add_directive(name, wrap_if_all_false(handler, opts), opts)
  end

  local add_predicate = query.add_predicate
  query.add_predicate = function(name, handler, opts)
    return add_predicate(name, wrap_if_all_false(handler, opts), opts)
  end

  query._compat_add_predicate_all_false = true
end

patch_treesitter_query_all_option()

require("lazy").setup({
  spec = {
    theme.plugin,
    {
      "nvim-tree/nvim-tree.lua",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      cmd = {
        "NvimTreeToggle",
        "NvimTreeFocus",
        "NvimTreeFindFile",
        "NvimTreeFindFileToggle",
      },
      init = function()
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
      end,
      opts = {
        hijack_netrw = true,
        sync_root_with_cwd = true,
        respect_buf_cwd = true,
        update_focused_file = {
          enable = true,
          update_root = true,
        },
        view = {
          width = 32,
          side = "left",
        },
        renderer = {
          highlight_git = true,
          root_folder_label = false,
        },
        filters = {
          dotfiles = false,
        },
        actions = {
          open_file = {
            quit_on_open = false,
            resize_window = true,
          },
        },
      },
      config = function(_, opts)
        require("nvim-tree").setup(opts)
      end,
    },
    {
      "nvim-telescope/telescope.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
      lazy = false,
      priority = 1100,
      config = function()
        local telescope = require("telescope")
        telescope.setup({
          defaults = {
            file_ignore_patterns = { "%.git/" },
            prompt_prefix = "❯ ",
            selection_caret = "▶ ",
            sorting_strategy = "ascending",
            layout_config = { prompt_position = "top" },
          },
          pickers = {
            find_files = { hidden = true },
          },
        })
      end,
    },
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      cond = function()
        return vim.fn.executable("make") == 1
      end,
      lazy = false,
      priority = 1090,
      config = function()
        pcall(require("telescope").load_extension, "fzf")
      end,
    },
    {
      "nvim-lualine/lualine.nvim",
      dependencies = {
        "nvim-tree/nvim-web-devicons",
        "linrongbin16/lsp-progress.nvim",
      },
      config = function()
        local lsp_progress = require("lsp-progress")
        lsp_progress.setup({
          spinner = { "⠋", "⠙", "⠚", "⠞", "⠖", "⠦", "⠴", "⠲", "⠳", "⠓" },
        })

        local function status_progress()
          local progress = lsp_progress.progress({ max_size = 80 })
          if progress and progress ~= "" and progress ~= "LSP" then
            return progress
          end

          local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
          if not clients or next(clients) == nil then
            return ""
          end

          local names = {}
          for _, client in ipairs(clients) do
            if client.name and client.name ~= "" then
              table.insert(names, client.name)
            end
          end

          if #names == 0 then
            return ""
          end

          return table.concat(names, ", ")
        end

        local function jump_diagnostic(count)
          local severity = { min = vim.diagnostic.severity.WARN }

          if vim.diagnostic.jump then
            vim.diagnostic.jump({ count = count, severity = severity })
            return
          end

          local jump = count > 0 and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
          jump({ severity = severity })
        end

        require("lualine").setup({
          options = {
            theme = theme.lualine_theme or "auto",
            globalstatus = true,
            component_separators = { left = "│", right = "│" },
            section_separators = { left = "", right = "" },
          },
          sections = {
            lualine_a = {
              { "mode", fmt = function(str) return str:upper() end },
            },
            lualine_b = {
              status_progress,
              { "filename", file_status = true, path = 1 },
            },
            lualine_c = {},
            lualine_x = {
              {
                "diagnostics",
                sources = { "nvim_diagnostic" },
                on_click = function(_, button)
                  if button == "r" then
                    jump_diagnostic(-1)
                    return
                  end

                  jump_diagnostic(1)
                end,
              },
              "selectioncount",
              "fileencoding",
            },
            lualine_y = { "progress" },
            lualine_z = { "location" },
          },
        })

        vim.api.nvim_create_autocmd("User", {
          pattern = "LspProgressStatusUpdated",
          callback = require("lualine").refresh,
        })
      end,
    },
    {
      "lukas-reineke/indent-blankline.nvim",
      main = "ibl",
      opts = {
        indent = { char = "┊" },
        scope = { enabled = false },
      },
    },
    {
      "lewis6991/gitsigns.nvim",
      opts = {
        signs = {
          add = { text = "▎" },
          change = { text = "▎" },
          delete = { text = "▁" },
          topdelete = { text = "▔" },
          changedelete = { text = "▎" },
        },
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,
        watch_gitdir = { follow_files = true },
        attach_to_untracked = true,
        current_line_blame = false,
      },
    },
    {
      "numToStr/Comment.nvim",
      event = "VeryLazy",
      config = function()
        local comment = require("Comment")
        comment.setup()

        local api = require("Comment.api")
        vim.keymap.set("n", "<C-c>", api.toggle.linewise.current, {
          desc = "Toggle comment",
        })
      end,
    },
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      opts = {
        highlight = { enable = true },
        indent = { enable = true },
      },
      config = function(_, opts)
        require("nvim-treesitter.configs").setup(opts)
      end,
    },
    {
      "nvim-treesitter/nvim-treesitter-context",
      dependencies = { "nvim-treesitter/nvim-treesitter" },
      opts = {
        enable = true,
        max_lines = 1,
        multiline_threshold = 1,
        trim_scope = "outer",
        mode = "cursor",
        on_attach = function(bufnr)
          local function_context_languages = {
            bash = true,
            c = true,
            cpp = true,
            cuda = true,
            go = true,
            javascript = true,
            lua = true,
            python = true,
            rust = true,
            tsx = true,
            typescript = true,
            vim = true,
          }

          local filetype = vim.bo[bufnr].filetype
          local language = vim.treesitter.language.get_lang(filetype) or filetype
          return function_context_languages[language] == true
        end,
      },
      config = function(_, opts)
        local context = require("treesitter-context")
        context.setup(opts)

        vim.keymap.set("n", "<leader>cc", context.go_to_context, { desc = "Go to context" })
      end,
    },
    {
      "williamboman/mason.nvim",
      build = ":MasonUpdate",
      opts = {},
    },
    {
      "neovim/nvim-lspconfig",
      dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
      },
      config = function()
        local servers = { "lua_ls", "pyright", "ts_ls", "clangd", "rust_analyzer", "texlab" }
        local cmp_cap = require("cmp_nvim_lsp").default_capabilities()
        local format_group = vim.api.nvim_create_augroup("HelixFormat", { clear = true })
        local clang_format_filetypes = {
          c = true,
          cpp = true,
          objc = true,
          objcpp = true,
          cuda = true,
          proto = true,
        }

        local function format_with_clang_format(bufnr)
          if vim.fn.executable("clang-format") ~= 1 then
            return false, "missing"
          end

          local filename = vim.api.nvim_buf_get_name(bufnr)
          local buffer_text = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
          local command = { "clang-format", "--style=file" }

          if filename ~= "" then
            table.insert(command, "--assume-filename")
            table.insert(command, filename)
          end

          local result = vim.system(command, { stdin = buffer_text, text = true }):wait()
          if result.code ~= 0 then
            local stderr = (result.stderr or ""):gsub("%s+$", "")
            local message = "clang-format failed"
            if stderr ~= "" then
              message = message .. ": " .. stderr
            end
            vim.notify(message, vim.log.levels.ERROR)
            return false, "failed"
          end

          local output = result.stdout or ""
          if output:sub(-1) == "\n" then
            output = output:sub(1, -2)
          end

          local formatted_lines = output == "" and {} or vim.split(output, "\n", { plain = true })
          vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted_lines)
          return true
        end

        local function format_buffer(bufnr)
          if clang_format_filetypes[vim.bo[bufnr].filetype] then
            local ok, reason = format_with_clang_format(bufnr)
            if ok then
              return
            end

            if reason == "missing" then
              vim.notify_once("clang-format is not available in PATH; falling back to LSP formatting", vim.log.levels.WARN)
            end
          end

          vim.lsp.buf.format({ async = false, bufnr = bufnr })
        end

        local function enable_inlay_hints(bufnr)
          if vim.lsp.inlay_hint and vim.lsp.inlay_hint.enable then
            local ok = pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
            if not ok and vim.lsp.inlay_hint then
              pcall(vim.lsp.inlay_hint, bufnr, true)
            end
          elseif vim.lsp.buf and vim.lsp.buf.inlay_hint then
            pcall(vim.lsp.buf.inlay_hint, bufnr, true)
          end
        end

        local function on_attach(client, bufnr)
          if client.server_capabilities.inlayHintProvider then
            enable_inlay_hints(bufnr)
          end

          local function lsp_map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
          end

          lsp_map("gd", vim.lsp.buf.definition, "Go to definition")
          lsp_map("<leader>ca", vim.lsp.buf.code_action, "Code actions")
          lsp_map("<leader>cf", function()
            vim.lsp.buf.code_action({
              apply = true,
              context = { only = { "quickfix" } },
            })
          end, "Apply quick fix")
          lsp_map("<leader>cF", function()
            vim.lsp.buf.code_action({
              apply = true,
              context = { only = { "source.fixAll" } },
            })
          end, "Apply fix all")

          vim.api.nvim_clear_autocmds({ group = format_group, buffer = bufnr })
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = format_group,
            buffer = bufnr,
            callback = function()
              format_buffer(bufnr)
            end,
          })
        end

        local mason_lspconfig = require("mason-lspconfig")

        mason_lspconfig.setup({
          ensure_installed = servers,
          automatic_enable = false,
        })

        local function configure(server, extra)
          local config = vim.tbl_deep_extend("force", {
            capabilities = cmp_cap,
            on_attach = on_attach,
          }, extra or {})

          vim.lsp.config(server, config)
          vim.lsp.enable(server)
        end

        configure("lua_ls", {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
            },
          },
        })

        configure("pyright")
        configure("ts_ls")
        configure("clangd")
        configure("rust_analyzer")
        configure("texlab")
      end,
    },
    {
      "hrsh7th/nvim-cmp",
      dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "saadparwaiz1/cmp_luasnip",
        "L3MON4D3/LuaSnip",
        "rafamadriz/friendly-snippets",
        {
          "zbirenbaum/copilot.lua",
          cmd = "Copilot",
          config = function()
            require("copilot").setup({
              suggestion = {
                enabled = true,
                auto_trigger = true,
                hide_during_completion = true,
                keymap = {
                  accept = false,
                  accept_word = false,
                  accept_line = false,
                  next = "<M-]>",
                  prev = "<M-[>",
                  dismiss = "<C-]>",
                  toggle_auto_trigger = false,
                },
              },
              panel = { enabled = false },
            })

            vim.defer_fn(function()
              local ok, auth = pcall(require, "copilot.auth")
              if ok then
                auth.is_authenticated()
              end
            end, 1000)
          end,
        },
      },
      config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        local has_copilot_suggestion, copilot_suggestion = pcall(require, "copilot.suggestion")

        require("luasnip.loaders.from_vscode").lazy_load()

        cmp.event:on("menu_opened", function()
          vim.b.copilot_suggestion_hidden = true
        end)

        cmp.event:on("menu_closed", function()
          vim.b.copilot_suggestion_hidden = false
        end)

        cmp.setup({
          completion = { keyword_length = 2 },
          snippet = {
            expand = function(args)
              luasnip.lsp_expand(args.body)
            end,
          },
          mapping = cmp.mapping.preset.insert({
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
            ["<Tab>"] = cmp.mapping(function(fallback)
              if has_copilot_suggestion and copilot_suggestion.is_visible() then
                copilot_suggestion.accept()
              elseif cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
              else
                fallback()
              end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end, { "i", "s" }),
          }),
          sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "path" },
          }, {
            { name = "buffer" },
          }),
        })
      end,
    },
    {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      config = function()
        local autopairs = require("nvim-autopairs")
        autopairs.setup({
          check_ts = true,
          fast_wrap = {},
        })

        local ok, cmp = pcall(require, "cmp")
        if ok then
          local cmp_autopairs = require("nvim-autopairs.completion.cmp")
          cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end
      end,
    },
    {
      "folke/which-key.nvim",
      event = "VeryLazy",
      config = function()
        local wk = require("which-key")
        wk.setup({
          notify = false,
          delay = 200,
          plugins = {
            spelling = { enabled = false },
            presets = {
              operators = true,
              motions = true,
              text_objects = true,
              windows = true,
              nav = true,
              z = true,
              g = true,
            },
          },
          triggers = {
            { "<leader>", mode = { "n", "v" } },
            { "g", mode = { "n", "v" } },
          },
        })

        wk.add({
          { "<leader>", group = "Leader", mode = { "n", "v" } },
          { "g", group = "goto / g", mode = { "n", "v" } },
        })
      end,
    },
  },
  defaults = { lazy = false },
  rocks = { enabled = false },
  install = { colorscheme = { theme.colorscheme or "default" } },
  checker = { enabled = false },
})

vim.keymap.set("n", "<leader>p", telescope_builtin("find_files"), { desc = "Telescope files" })
