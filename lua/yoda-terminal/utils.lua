-- lua/yoda-terminal/utils.lua
-- Minimal utilities for yoda-terminal (inlined to avoid dependencies)

local M = {}

-- ============================================================================
-- NOTIFICATION
-- ============================================================================

--- Send notification using yoda-adapters or fallback to native
--- @param msg string Message to display
--- @param level string|number Log level
--- @param opts table|nil Options
function M.notify(msg, level, opts)
  local ok, adapter = pcall(require, "yoda-adapters.notification")
  if not ok then
    -- Fallback to native vim.notify if adapter fails to load
    local numeric_level = type(level) == "string" and vim.log.levels.INFO or level
    vim.notify(msg, numeric_level, opts)
    return
  end

  adapter.notify(msg, level, opts)
end

-- ============================================================================
-- PLATFORM
-- ============================================================================

M.platform = {}

--- Check if running on Windows
--- @return boolean
function M.platform.is_windows()
  return vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
end

--- Check if running on macOS
--- @return boolean
function M.platform.is_macos()
  return vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1
end

--- Check if running on Linux
--- @return boolean
function M.platform.is_linux()
  return vim.fn.has("unix") == 1 and not M.platform.is_macos()
end

--- Get platform name
--- @return string Platform name ("windows", "macos", "linux", "unknown")
function M.platform.get_platform()
  if M.platform.is_windows() then
    return "windows"
  elseif M.platform.is_macos() then
    return "macos"
  elseif M.platform.is_linux() then
    return "linux"
  end
  return "unknown"
end

--- Get path separator for current platform
--- @return string Path separator ("/" or "\\")
function M.platform.get_path_sep()
  return M.platform.is_windows() and "\\" or "/"
end

--- Join path components with platform-appropriate separator
--- @param ... string Path components
--- @return string Joined path
function M.platform.join_path(...)
  local parts = { ... }
  local sep = M.platform.get_path_sep()
  return table.concat(parts, sep)
end

-- ============================================================================
-- IO
-- ============================================================================

M.io = {}

--- Check if file exists and is readable
--- @param path string File path
--- @return boolean
function M.io.is_file(path)
  if type(path) ~= "string" or path == "" then
    return false
  end
  return vim.fn.filereadable(path) == 1
end

--- Check if directory exists
--- @param path string Directory path
--- @return boolean
function M.io.is_dir(path)
  if type(path) ~= "string" or path == "" then
    return false
  end
  return vim.fn.isdirectory(path) == 1
end

--- Check if path exists (file or directory)
--- @param path string Path to check
--- @return boolean
function M.io.exists(path)
  return M.io.is_file(path) or M.io.is_dir(path)
end

--- Legacy compatibility for file_exists
--- @param path string File path
--- @return boolean
function M.io.file_exists(path)
  local f = io.open(path, "r")
  if f then
    f:close()
    return true
  end
  return false
end

return M
