# nvim-configruation-version-based-on-neovim-0.12

## Manage plugins

Using vim.pack to plugin manager.

**Install plugins:** Edit `~/.config/nvim/lua/misc/plugins.lua` and save file. When appear install plugins toast, input `A` to install all plugins, input `Y` to install only once, input `N` to cancel install.

```txt
These plugins will be installed:

<plugins-name> from <url>

Proceed? [Y]es, (N)o, (A)lways:
```

**Uninstall plugins:** Remove plugins url and configruation from `~/.config/nvim/lua/misc/plugins.lua`, and input `:lua vim.pack.del('plugin_name')` to successfully delete it.

## File structure

```txt
.
├── init.lua
├── lsp
├── lua
│   └── misc
│       ├── keymaps.lua
│       └── plugins.lua
├── nvim-pack-lock.json
└── README.md
```
