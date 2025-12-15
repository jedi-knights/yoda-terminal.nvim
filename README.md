# yoda-terminal.nvim

<p align="center">
  <a href="https://github.com/jedi-knights/yoda-terminal.nvim/actions/workflows/ci.yml"><img src="https://github.com/jedi-knights/yoda-terminal.nvim/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <img src="https://img.shields.io/badge/tests-passing-brightgreen" alt="Tests">
  <img src="https://img.shields.io/badge/quality-high-gold" alt="Code Quality">
</p>

> **Smart Python virtual environment integration for Neovim terminals.**

Auto-detects `.venv`, cross-platform activation (bash/zsh/fish/PowerShell), interactive selection. Facade + Builder patterns.

---

## 📋 Features

- **🐍 Python Virtual Environment Support**: Auto-detect and activate `.venv` in terminals
- **🌍 Cross-Platform**: Works on Linux, macOS, and Windows
- **🔍 Smart Detection**: Automatically finds venv in current directory
- **🎯 Interactive Selection**: Choose from multiple venvs if needed
- **🛠️ Builder Pattern**: Fluent API for advanced terminal configuration
- **🐚 Shell Detection**: Bash, Zsh, Fish, PowerShell support
- **⚡ Zero Dependencies**: Only requires `yoda.nvim-adapters` for picker UI
- **🧪 Well-Tested**: Comprehensive test coverage

---

## 📦 Installation

### With [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "jedi-knights/yoda-terminal.nvim",
  dependencies = {
    "jedi-knights/yoda.nvim-adapters",
  },
  opts = {
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
  },
}
```

---

## 🚀 Quick Start

### Setup

The plugin follows centralized setup rules. Call `setup()` once in your config:

```lua
require("yoda-terminal").setup({
  width = 0.9,
  height = 0.85,
  border = "rounded",
  autocmds = true,
  commands = true,
})
```

### Basic Usage

```lua
local terminal = require("yoda-terminal")

terminal.open_floating()

terminal.open_simple()

terminal.venv.select_virtual_env(function(venv_path)
  print("Selected: " .. venv_path)
  terminal.open_floating({ venv_path = venv_path })
end)
```

### Commands

After setup, the following commands are available:

- `:YodaTerminal` - Open floating terminal
- `:YodaTerminal floating` - Open floating terminal
- `:YodaTerminal simple` - Open simple terminal
- `:YodaTerminalVenv` - Select venv and open terminal

### Auto-Detection

The plugin automatically searches for Python virtual environments:

1. Checks current directory for `.venv/`
2. Checks parent directories up to project root
3. If multiple found, prompts user to select
4. If none found, opens regular terminal

### Explicit Virtual Environment

```lua
-- Specify exact venv path
terminal.open_floating({
  venv_path = "/path/to/my-project/.venv"
})

-- Or use relative path
terminal.open_floating({
  venv_path = ".venv"
})
```

---

## 🛠️ Builder API

For advanced configuration, use the builder pattern:

```lua
local builder = require("yoda-terminal.builder")

-- Build custom terminal configuration
local config = builder
  :with_venv(".venv")
  :with_title("Python Dev")
  :with_shell("zsh")
  :with_size({ width = 0.8, height = 0.8 })
  :build()

-- Open terminal with custom config
terminal.open_simple(config)
```

### Builder Methods

| Method | Description | Example |
|--------|-------------|---------|
| `with_venv(path)` | Set virtual environment path | `.with_venv(".venv")` |
| `with_shell(name)` | Set shell type | `.with_shell("zsh")` |
| `with_title(title)` | Set terminal title | `.with_title("Dev Terminal")` |
| `with_size(opts)` | Set terminal size | `.with_size({ width = 0.9 })` |
| `build()` | Build configuration | `.build()` |

---

## ⚙️ Configuration

### Default Configuration

```lua
require("yoda-terminal").setup({
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
})
```

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `width` | number | 0.9 | Terminal width as percentage of screen |
| `height` | number | 0.85 | Terminal height as percentage of screen |
| `border` | string | "rounded" | Border style |
| `title_pos` | string | "center" | Title position |
| `shell` | string\|nil | nil | Shell to use (auto-detected if nil) |
| `venv.auto_detect` | boolean | true | Auto-detect virtual environments |
| `venv.search_paths` | table | {".venv", "venv", "env"} | Paths to search for venvs |
| `autocmds` | boolean | true | Enable autocmds |
| `commands` | boolean | true | Enable user commands |

### Shell-Specific Activation

The plugin automatically uses the correct activation script for each shell:

| Shell | Activation Command |
|-------|-------------------|
| **Bash** | `source /path/.venv/bin/activate` |
| **Zsh** | `source /path/.venv/bin/activate` |
| **Fish** | `source /path/.venv/bin/activate.fish` |
| **PowerShell** | `/path/.venv/Scripts/Activate.ps1` |
| **Windows** | `/path/.venv/Scripts/activate.bat` |

---

## 📚 API Reference

### Main Module (`yoda-terminal`)

#### `open_floating(opts)`
Open a floating terminal window with optional venv activation.

**Parameters:**
- `opts` (table|nil): Options
  - `venv_path` (string|nil): Path to virtual environment
  - `shell` (string|nil): Shell to use
  - `title` (string|nil): Terminal title

**Example:**
```lua
terminal.open_floating({
  venv_path = ".venv",
  title = "Python Development",
})
```

#### `open_simple(opts)`
Open a simple split terminal with optional venv activation.

**Parameters:**
- `opts` (table|nil): Same as `open_floating`

#### `select_virtual_env(callback)`
Interactively select a virtual environment.

**Parameters:**
- `callback` (function): Called with selected venv path

**Example:**
```lua
terminal.select_virtual_env(function(venv_path)
  if venv_path then
    print("User selected: " .. venv_path)
    terminal.open_floating({ venv_path = venv_path })
  end
end)
```

#### `setup(opts)`
Configure plugin (must be called once before using the plugin).

**Parameters:**
- `opts` (table|nil): Configuration options

**Example:**
```lua
require("yoda-terminal").setup({
  width = 0.9,
  height = 0.85,
  autocmds = true,
  commands = true,
})
```

#### `get_config()`
Get current configuration.

**Returns:**
- `table`: Current configuration

---

### Virtual Environment Module (`yoda-terminal.venv`)

#### `find_venv()`
Find virtual environment in current directory.

**Returns:**
- `string|nil`: Path to venv or nil if not found

#### `find_all_venvs()`
Find all virtual environments in current and parent directories.

**Returns:**
- `table`: Array of venv paths

#### `is_venv(path)`
Check if path is a valid virtual environment.

**Parameters:**
- `path` (string): Path to check

**Returns:**
- `boolean`: True if valid venv

#### `get_activation_command(venv_path, shell)`
Get shell-specific activation command.

**Parameters:**
- `venv_path` (string): Path to venv
- `shell` (string): Shell name

**Returns:**
- `string`: Activation command

---

### Builder Module (`yoda-terminal.builder`)

#### `new()`
Create a new builder instance.

**Returns:**
- `table`: Builder instance

#### `with_venv(path)`
Set virtual environment path.

#### `with_shell(name)`
Set shell type.

#### `with_title(title)`
Set terminal title.

#### `with_size(opts)`
Set terminal size.

#### `build()`
Build final configuration.

**Returns:**
- `table`: Terminal configuration

---

## 🏗️ Architecture

### Design Patterns

- **Facade Pattern**: Simple API (`open_floating`, `open_simple`) over complex subsystem
- **Builder Pattern**: Fluent API for configuration
- **Strategy Pattern**: Shell-specific activation strategies
- **Dependency Injection**: DI versions available for testing

### Module Structure

```
yoda-terminal/
├── init.lua          # Main facade
├── venv.lua          # Virtual environment detection
├── shell.lua         # Shell detection/activation
├── builder.lua       # Builder pattern implementation
├── config.lua        # Configuration management
└── utils.lua         # Platform/IO utilities
```

---

## 💡 Examples

### Python Development Workflow

```lua
require("yoda-terminal").setup({
  width = 0.9,
  height = 0.85,
  commands = true,
})

local terminal = require("yoda-terminal")

vim.keymap.set("n", "<leader>tt", function()
  terminal.open_floating()
end, { desc = "Open Python terminal" })

vim.keymap.set("n", "<leader>tv", function()
  terminal.venv.select_virtual_env(function(venv)
    if venv then
      terminal.open_floating({ venv_path = venv })
    end
  end)
end, { desc = "Select venv and open terminal" })
```

### Custom Terminal Configuration

```lua
local builder = require("yoda-terminal.builder")

-- Create specialized Python terminal
local function open_python_repl()
  local config = builder
    :with_venv(".venv")
    :with_title("Python REPL")
    :with_shell("zsh")
    :build()
  
  require("yoda-terminal").open_floating(config)
end

vim.keymap.set("n", "<leader>tp", open_python_repl, { desc = "Python REPL" })
```

### Multi-Project Workflow

```lua
-- Different venvs for different projects
local terminals = {
  api = { venv = "~/projects/api/.venv", title = "API Server" },
  web = { venv = "~/projects/web/.venv", title = "Web App" },
  ml = { venv = "~/projects/ml/.venv", title = "ML Training" },
}

for name, opts in pairs(terminals) do
  vim.keymap.set("n", "<leader>t" .. name:sub(1,1), function()
    require("yoda-terminal").open_floating(opts)
  end, { desc = "Open " .. opts.title })
end
```

---

## 🧪 Testing

```bash
# Run all tests
make test

# Check code style
make lint

# Format code
make format
```

---

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass (`make test`)
5. Format code (`make format`)
6. Submit a pull request

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

## 🔗 Related Projects

- **[yoda.nvim](https://github.com/jedi-knights/yoda.nvim)** - Comprehensive Neovim distribution
- **[yoda.nvim-adapters](https://github.com/jedi-knights/yoda.nvim-adapters)** - Notification and picker adapters (required)
- **[yoda-logging.nvim](https://github.com/jedi-knights/yoda-logging.nvim)** - Production logging framework

---

## 💬 Support

- **Issues**: [GitHub Issues](https://github.com/jedi-knights/yoda-terminal.nvim/issues)
- **Discussions**: [GitHub Discussions](https://github.com/jedi-knights/yoda-terminal.nvim/discussions)

---

**May the Force be with you! ⚡**
