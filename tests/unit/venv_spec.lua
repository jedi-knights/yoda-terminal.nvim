-- Tests for terminal/venv.lua
local venv = require("yoda-terminal.venv")

describe("terminal.venv", function()
  -- Save originals
  local original_getcwd = vim.fn.getcwd
  local original_readdir = vim.fn.readdir

  after_each(function()
    vim.fn.getcwd = original_getcwd
    vim.fn.readdir = original_readdir
    package.loaded["yoda-terminal.utils"] = nil
    package.loaded["yoda-adapters.picker"] = nil
    package.loaded["yoda-terminal.venv"] = nil
    venv._clear_cache()
  end)

  describe("get_activate_script_path()", function()
    it("returns Unix activate script path", function()
      package.loaded["yoda-terminal.utils"] = {
        platform = {
          is_windows = function()
            return false
          end,
        },
        io = {
          is_file = function(path)
            return path == "/venv/bin/activate"
          end,
        },
      }

      package.loaded["yoda-terminal.venv"] = nil
      local venv_mod = require("yoda-terminal.venv")
      local path = venv_mod.get_activate_script_path("/venv")
      assert.equals("/venv/bin/activate", path)
    end)

    it("returns Windows activate script path", function()
      package.loaded["yoda-terminal.utils"] = {
        platform = {
          is_windows = function()
            return true
          end,
        },
        io = {
          is_file = function(path)
            return path == "/venv/Scripts/activate"
          end,
        },
      }

      package.loaded["yoda-terminal.venv"] = nil
      local venv_mod = require("yoda-terminal.venv")
      local path = venv_mod.get_activate_script_path("/venv")
      assert.equals("/venv/Scripts/activate", path)
    end)

    it("returns nil when activate script not found", function()
      package.loaded["yoda-terminal.utils"] = {
        platform = {
          is_windows = function()
            return false
          end,
        },
        io = {
          is_file = function()
            return false
          end,
        },
      }

      package.loaded["yoda-terminal.venv"] = nil
      local venv_mod = require("yoda-terminal.venv")
      local path = venv_mod.get_activate_script_path("/nonexistent")
      assert.is_nil(path)
    end)
  end)

  describe("find_virtual_envs()", function()
    it("finds virtual environments in current directory", function()
      vim.fn.getcwd = function()
        return "/project"
      end

      vim.fn.readdir = function(dir)
        return { "venv", "env", "node_modules", "src" }
      end

      package.loaded["yoda-terminal.utils"] = {
        platform = {
          is_windows = function()
            return false
          end,
        },
        io = {
          is_dir = function(path)
            return true
          end,
          is_file = function(path)
            return path == "/project/venv/bin/activate" or path == "/project/env/bin/activate"
          end,
        },
      }

      package.loaded["yoda-terminal.venv"] = nil
      local venv_mod = require("yoda-terminal.venv")
      local venvs = venv_mod.find_virtual_envs()
      assert.equals(2, #venvs)
      assert.same({ "/project/venv", "/project/env" }, venvs)
    end)

    it("returns empty array when no venvs found", function()
      vim.fn.getcwd = function()
        return "/project"
      end

      vim.fn.readdir = function()
        return { "src", "docs" }
      end

      package.loaded["yoda-terminal.utils"] = {
        platform = {
          is_windows = function()
            return false
          end,
        },
        io = {
          is_dir = function()
            return true
          end,
          is_file = function()
            return false
          end,
        },
      }

      package.loaded["yoda-terminal.venv"] = nil
      local venv_mod = require("yoda-terminal.venv")
      local venvs = venv_mod.find_virtual_envs()
      assert.same({}, venvs)
    end)

    it("handles empty directory", function()
      vim.fn.getcwd = function()
        return "/empty"
      end

      vim.fn.readdir = function()
        return {}
      end

      package.loaded["yoda-terminal.utils"] = {
        platform = {
          is_windows = function()
            return false
          end,
        },
        io = {
          is_dir = function()
            return true
          end,
          is_file = function()
            return false
          end,
        },
      }

      package.loaded["yoda-terminal.venv"] = nil
      local venv_mod = require("yoda-terminal.venv")
      local venvs = venv_mod.find_virtual_envs()
      assert.same({}, venvs)
    end)

    it("only includes directories with activate scripts", function()
      vim.fn.getcwd = function()
        return "/project"
      end

      vim.fn.readdir = function()
        return { "venv", "fake_venv" }
      end

      package.loaded["yoda-terminal.utils"] = {
        platform = {
          is_windows = function()
            return false
          end,
        },
        io = {
          is_dir = function()
            return true
          end,
          is_file = function(path)
            return path == "/project/venv/bin/activate"
          end,
        },
      }

      package.loaded["yoda-terminal.venv"] = nil
      local venv_mod = require("yoda-terminal.venv")
      local venvs = venv_mod.find_virtual_envs()
      assert.equals(1, #venvs)
      assert.equals("/project/venv", venvs[1])
    end)
  end)

  describe("select_virtual_env()", function()
    it("calls callback with nil when no venvs found", function()
      vim.fn.getcwd = function()
        return "/project"
      end
      vim.fn.readdir = function()
        return {}
      end

      package.loaded["yoda-terminal.utils"] = {
        platform = {
          is_windows = function()
            return false
          end,
        },
        io = {
          is_dir = function()
            return true
          end,
          is_file = function()
            return false
          end,
        },
        notify = function() end,
      }

      package.loaded["yoda-terminal.venv"] = nil
      local venv_mod = require("yoda-terminal.venv")
      local callback_result = nil
      venv_mod.select_virtual_env(function(result)
        callback_result = result
      end)

      assert.is_nil(callback_result)
    end)

    it("auto-selects single venv without picker", function()
      vim.fn.getcwd = function()
        return "/project"
      end
      vim.fn.readdir = function()
        return { "venv" }
      end

      package.loaded["yoda-terminal.utils"] = {
        platform = {
          is_windows = function()
            return false
          end,
        },
        io = {
          is_dir = function()
            return true
          end,
          is_file = function(path)
            return path == "/project/venv/bin/activate"
          end,
        },
        notify = function() end,
      }

      package.loaded["yoda-terminal.venv"] = nil
      local venv_mod = require("yoda-terminal.venv")
      local callback_result = nil
      venv_mod.select_virtual_env(function(result)
        callback_result = result
      end)

      assert.equals("/project/venv", callback_result)
    end)

    it("shows picker when multiple venvs found", function()
      vim.fn.getcwd = function()
        return "/project"
      end
      vim.fn.readdir = function()
        return { "venv", "env" }
      end

      local picker_called = false
      local captured_items = nil
      package.loaded["yoda-adapters.picker"] = {
        select = function(items, opts, callback)
          picker_called = true
          captured_items = items
          callback(items[2])
        end,
      }

      package.loaded["yoda-terminal.utils"] = {
        platform = {
          is_windows = function()
            return false
          end,
        },
        io = {
          is_dir = function()
            return true
          end,
          is_file = function(path)
            return path:match("/bin/activate$") ~= nil
          end,
        },
        notify = function() end,
      }

      package.loaded["yoda-terminal.venv"] = nil
      local venv_mod = require("yoda-terminal.venv")
      local callback_result = nil
      venv_mod.select_virtual_env(function(result)
        callback_result = result
      end)

      assert.is_true(picker_called)
      assert.equals(2, #captured_items)
      assert.equals("/project/env", callback_result)
    end)

    it("notifies when no venvs found", function()
      vim.fn.getcwd = function()
        return "/project"
      end
      vim.fn.readdir = function()
        return {}
      end

      local notified = false
      package.loaded["yoda-terminal.utils"] = {
        platform = {
          is_windows = function()
            return false
          end,
        },
        io = {
          is_dir = function()
            return true
          end,
          is_file = function()
            return false
          end,
        },
        notify = function(msg, level)
          if msg:match("No Python virtual environments") then
            notified = true
          end
        end,
      }

      package.loaded["yoda-terminal.venv"] = nil
      local venv_mod = require("yoda-terminal.venv")
      venv_mod.select_virtual_env(function() end)
      assert.is_true(notified)
    end)

    it("uses picker prompt for venv selection", function()
      vim.fn.getcwd = function()
        return "/project"
      end
      vim.fn.readdir = function()
        return { "venv1", "venv2" }
      end

      local captured_opts = nil
      package.loaded["yoda-adapters.picker"] = {
        select = function(items, opts, callback)
          captured_opts = opts
          callback(nil)
        end,
      }

      package.loaded["yoda-terminal.utils"] = {
        platform = {
          is_windows = function()
            return false
          end,
        },
        io = {
          is_dir = function()
            return true
          end,
          is_file = function(path)
            return path:match("/bin/activate$") ~= nil
          end,
        },
        notify = function() end,
      }

      package.loaded["yoda-terminal.venv"] = nil
      local venv_mod = require("yoda-terminal.venv")
      venv_mod.select_virtual_env(function() end)
      assert.matches("Python virtual environment", captured_opts.prompt)
    end)
  end)
end)
