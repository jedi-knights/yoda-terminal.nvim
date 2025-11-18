local M = {}

function M.basic()
  require("yoda-terminal").setup()
end

function M.custom()
  require("yoda-terminal").setup({
    width = 0.8,
    height = 0.7,
    border = "double",
    title_pos = "left",
    venv = {
      auto_detect = true,
      search_paths = { ".venv", "venv", "env", ".virtualenv" },
    },
    autocmds = true,
    commands = true,
  })
end

function M.minimal()
  require("yoda-terminal").setup({
    autocmds = false,
    commands = false,
  })
end

function M.with_keymaps()
  require("yoda-terminal").setup({
    commands = true,
  })

  local terminal = require("yoda-terminal")

  vim.keymap.set("n", "<leader>tt", terminal.open_floating, { desc = "Open terminal" })
  vim.keymap.set("n", "<leader>ts", terminal.open_simple, { desc = "Open simple terminal" })
  vim.keymap.set("n", "<leader>tv", function()
    terminal.venv.select_virtual_env(function(venv)
      if venv then
        terminal.open_floating({ venv_path = venv })
      end
    end)
  end, { desc = "Select venv" })
end

function M.lazy_nvim()
  return {
    "jedi-knights/yoda-terminal.nvim",
    dependencies = {
      "jedi-knights/yoda.nvim-adapters",
    },
    opts = {
      width = 0.9,
      height = 0.85,
      border = "rounded",
      commands = true,
      autocmds = true,
    },
    keys = {
      {
        "<leader>tt",
        function()
          require("yoda-terminal").open_floating()
        end,
        desc = "Terminal",
      },
      {
        "<leader>ts",
        function()
          require("yoda-terminal").open_simple()
        end,
        desc = "Simple terminal",
      },
      {
        "<leader>tv",
        function()
          require("yoda-terminal").venv.select_virtual_env(function(venv)
            if venv then
              require("yoda-terminal").open_floating({ venv_path = venv })
            end
          end)
        end,
        desc = "Terminal with venv",
      },
    },
  }
end

return M
