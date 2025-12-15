local M = {}

local _initialized = false
local _config = nil
local _modules = {}

local DEFAULT_CONFIG = {
  width = 0.9,
  height = 0.85,
  border = "rounded",
  title_pos = "center",
  shell = nil,
  venv = {
    auto_detect = true,
    search_paths = { ".venv", "venv", "env" },
  },
  autocmds = true,
  commands = true,
}

local function lazy_require(module_name)
  return function()
    if not _modules[module_name] then
      _modules[module_name] = require(module_name)
    end
    return _modules[module_name]
  end
end

local get_config = lazy_require("yoda-terminal.config")
local get_shell = lazy_require("yoda-terminal.shell")
local get_venv = lazy_require("yoda-terminal.venv")
local get_builder = lazy_require("yoda-terminal.builder")
local get_utils = lazy_require("yoda-terminal.utils")

local function merge_config(user_config)
  user_config = user_config or {}
  local merged = vim.tbl_deep_extend("force", DEFAULT_CONFIG, user_config)

  vim.g.yoda_terminal_width = merged.width
  vim.g.yoda_terminal_height = merged.height
  vim.g.yoda_terminal_border = merged.border
  vim.g.yoda_terminal_title_pos = merged.title_pos

  return merged
end

local function setup_autocmds()
  local autocmds = require("yoda-terminal.autocmds")
  autocmds.setup_all(vim.api.nvim_create_autocmd, vim.api.nvim_create_augroup)
end

local function setup_commands()
  vim.api.nvim_create_user_command("YodaTerminal", function(opts)
    if opts.args == "floating" then
      M.open_floating()
    elseif opts.args == "simple" then
      M.open_simple()
    else
      M.open_floating()
    end
  end, {
    nargs = "?",
    complete = function()
      return { "floating", "simple" }
    end,
    desc = "Open Yoda terminal",
  })

  vim.api.nvim_create_user_command("YodaTerminalVenv", function()
    get_venv().select_virtual_env(function(venv)
      if venv then
        M.open_floating({ venv_path = venv })
      end
    end)
  end, {
    desc = "Select and open terminal with venv",
  })
end

function M.setup(user_config)
  if _initialized then
    return
  end

  _config = merge_config(user_config)

  if _config.autocmds then
    setup_autocmds()
  end

  if _config.commands then
    setup_commands()
  end

  _initialized = true
end

function M.get_config()
  return _config or DEFAULT_CONFIG
end

setmetatable(M, {
  __index = function(t, k)
    if k == "config" then
      local config = get_config()
      rawset(t, k, config)
      return config
    elseif k == "shell" then
      local shell = get_shell()
      rawset(t, k, shell)
      return shell
    elseif k == "venv" then
      local venv = get_venv()
      rawset(t, k, venv)
      return venv
    elseif k == "builder" then
      local builder = get_builder()
      rawset(t, k, builder)
      return builder
    end
  end,
})

function M.open_floating(opts)
  opts = opts or {}
  local notify = get_utils().notify

  local ok, err = pcall(function()
    M._open_floating_impl(opts)
  end)

  if not ok then
    notify("Failed to open terminal: " .. tostring(err), "error")
    notify("Falling back to simple terminal", "warn")
    get_shell().open_simple({})
  end
end

function M._open_floating_impl(opts)
  local notify = get_utils().notify
  local venv = get_venv()
  local shell = get_shell()

  if opts.venv_path then
    local activate_script = venv.get_activate_script_path(opts.venv_path)
    if activate_script then
      local shell_cmd = shell.get_default()
      local shell_type = shell.get_type(shell_cmd)

      local cmd
      if shell_type == "bash" or shell_type == "zsh" then
        cmd = { shell_cmd, "-i", "-c", string.format("source '%s' && exec %s -i", activate_script, shell_cmd) }
      else
        cmd = { shell_cmd, "-i" }
      end

      opts.cmd = cmd
      opts.title = opts.title or string.format(" Terminal (venv: %s) ", vim.fn.fnamemodify(opts.venv_path, ":t"))

      notify("Activating venv: " .. opts.venv_path, "info")
      shell.open_simple(opts)
    else
      notify("No activate script found for: " .. opts.venv_path, "warn")
      shell.open_simple(opts)
    end
    return
  end

  local cwd = vim.fn.getcwd()
  local default_venv = cwd .. "/.venv"
  local io = get_utils().io

  if io.is_dir(default_venv) and venv.get_activate_script_path(default_venv) then
    opts.venv_path = default_venv
    M._open_floating_impl(opts)
    return
  end

  venv.select_virtual_env(function(venv_path)
    if venv_path then
      opts.venv_path = venv_path
      M._open_floating_impl(opts)
    else
      shell.open_simple(opts)
    end
  end)
end

function M.open_simple(opts)
  get_shell().open_simple(opts)
end

M.find_virtual_envs = function(...)
  return get_venv().find_virtual_envs(...)
end
M.get_activate_script_path = function(...)
  return get_venv().get_activate_script_path(...)
end
M.make_terminal_win_opts = function(...)
  return get_config().make_win_opts(...)
end

return M
