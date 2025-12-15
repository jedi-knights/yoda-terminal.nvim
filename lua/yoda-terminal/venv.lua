-- lua/yoda/terminal/venv.lua
-- Python virtual environment utilities (extracted from functions.lua for better SRP)

local M = {}

-- ============================================================================
-- Constants
-- ============================================================================

local ACTIVATE_PATHS = {
  UNIX = "/bin/activate",
  WINDOWS = "/Scripts/activate",
}

-- ============================================================================
-- Memoization Cache
-- ============================================================================

local _venv_cache = setmetatable({}, { __mode = "kv" })

local function get_cache_key(path)
  local stat = vim.loop.fs_stat(path)
  if not stat then
    return nil
  end
  return path .. ":" .. stat.mtime.sec .. ":" .. stat.size
end

-- ============================================================================
-- Helper Functions (consolidated)
-- ============================================================================

-- Use consolidated platform utilities
local platform = require("yoda-terminal.utils").platform

-- ============================================================================
-- Public API
-- ============================================================================

--- Get activate script path for virtual environment
--- @param venv_path string Virtual environment directory path
--- @return string|nil Activate script path or nil if not found
function M.get_activate_script_path(venv_path)
  -- Skip caching in test environment
  local use_cache = not vim.env.YODA_TEST
  local cache_key = use_cache and get_cache_key(venv_path) or nil

  if cache_key and _venv_cache[cache_key] ~= nil then
    return _venv_cache[cache_key]
  end

  local subpath = platform.is_windows() and ACTIVATE_PATHS.WINDOWS or ACTIVATE_PATHS.UNIX
  local activate_path = venv_path .. subpath
  local io = require("yoda-terminal.utils").io

  local result = nil
  if io.is_file(activate_path) then
    result = activate_path
  end

  if cache_key then
    _venv_cache[cache_key] = result
  end

  return result
end

--- Find all virtual environments in current directory
--- @return table Array of venv paths
function M.find_virtual_envs()
  -- Skip caching in test environment
  local use_cache = not vim.env.YODA_TEST
  local cwd = vim.fn.getcwd()
  local cache_key = use_cache and get_cache_key(cwd) or nil

  if cache_key and _venv_cache["find:" .. cache_key] then
    return _venv_cache["find:" .. cache_key]
  end

  local entries = vim.fn.readdir(cwd)
  local venvs = {}
  local io = require("yoda-terminal.utils").io

  for _, entry in ipairs(entries) do
    local dir_path = cwd .. "/" .. entry
    if io.is_dir(dir_path) then
      if M.get_activate_script_path(dir_path) then
        venvs[#venvs + 1] = dir_path
      end
    end
  end

  if cache_key then
    _venv_cache["find:" .. cache_key] = venvs
  end

  return venvs
end

--- Select virtual environment with picker (uses adapter for DIP)
--- @param callback function Callback receiving selected venv path or nil
function M.select_virtual_env(callback)
  local venvs = M.find_virtual_envs()
  local notify = require("yoda-terminal.utils").notify

  if #venvs == 0 then
    notify("No Python virtual environments found in project root.", "warn", { title = "Virtualenv" })
    callback(nil)
  elseif #venvs == 1 then
    callback(venvs[1])
  else
    -- Use picker adapter for plugin independence
    local picker = require("yoda-adapters.picker")
    picker.select(venvs, { prompt = "Select a Python virtual environment:" }, function(choice)
      callback(choice)
    end)
  end
end

--- Clear venv cache (useful for testing)
function M._clear_cache()
  _venv_cache = setmetatable({}, { __mode = "kv" })
end

return M
