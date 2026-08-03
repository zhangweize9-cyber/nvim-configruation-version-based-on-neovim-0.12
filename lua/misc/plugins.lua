local plugins_url = {
  -- colorscheme
  "https://github.com/catppuccin/nvim",
  -- lsp client
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  -- completion
  "https://github.com/saghen/blink.lib",
  "https://github.com/saghen/blink.cmp",
  -- format
  "https://github.com/lukas-reineke/lsp-format.nvim",
}

for _, plugins_link in ipairs(plugins_url) do
  vim.pack.add { { src = plugins_link } }
end

-- catppuccin
vim.cmd.colorscheme "catppuccin-nvim"

-- mason.nvim
require("mason").setup {
  firewall = {
    enabled = true
  },
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  },
}

-- mason-lspconfig.nvim
require("mason-lspconfig").setup {
    automatic_enable = true
}

-- nvim-lspconfig & neovim lsp api
vim.env.PATH = vim.fn.stdpath("data").. "/mason/bin:" .. vim.env.PATH
vim.lsp.config("*", {})
vim.lsp.config["lua_ls"] = {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luacheckrc", ".git" },
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
        },
      },
    },
  },
}
vim.lsp.enable("lua_ls")

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then return end
    -- inlayHint.
    pcall(vim.lsp.inlay_hint.enable, true, { bufnr = ev.buf })
  end,
})

vim.diagnostic.config({
  virtual_lines = {
    only_current_line = true,
  },
  virtual_text = false,
  signs = true,
  update_in_insert = false,
  severity_sort = true,
})

-- blink.cmp
local cmp = require('blink.cmp')
cmp.build():pwait()
cmp.setup({
keymap = {
  preset = 'default',
  ['<A-1>'] = { function(cmp) cmp.accept({ index = 1 }) end },
  ['<A-2>'] = { function(cmp) cmp.accept({ index = 2 }) end },
  ['<A-3>'] = { function(cmp) cmp.accept({ index = 3 }) end },
  ['<A-4>'] = { function(cmp) cmp.accept({ index = 4 }) end },
  ['<A-5>'] = { function(cmp) cmp.accept({ index = 5 }) end },
  ['<A-6>'] = { function(cmp) cmp.accept({ index = 6 }) end },
  ['<A-7>'] = { function(cmp) cmp.accept({ index = 7 }) end },
  ['<A-8>'] = { function(cmp) cmp.accept({ index = 8 }) end },
  ['<A-9>'] = { function(cmp) cmp.accept({ index = 9 }) end },
  ['<A-0>'] = { function(cmp) cmp.accept({ index = 10 }) end },
},
completion = {
  ghost_text = {
    enabled = true
  },
  menu = {
    direction_priority = function()
      local ctx = require('blink.cmp').get_context()
      local item = require('blink.cmp').get_selected_item()
      if ctx == nil or item == nil then return { 's', 'n' } end

      local item_text = item.textEdit ~= nil and item.textEdit.newText or item.insertText or item.label
      local is_multi_line = item_text:find('\n') ~= nil

      -- after showing the menu upwards, we want to maintain that direction
      -- until we re-open the menu, so store the context id in a global variable
      if is_multi_line or vim.g.blink_cmp_upwards_ctx_id == ctx.id then
        vim.g.blink_cmp_upwards_ctx_id = ctx.id
        return { 'n', 's' }
      end
      return { 's', 'n' }
    end,
    draw = {
      columns = { { 'item_idx' }, { 'kind_icon' }, { 'label', 'label_description', gap = 1 } },
      components = {
        item_idx = {
          text = function(ctx) return ctx.idx == 10 and '0' or ctx.idx >= 10 and ' ' or tostring(ctx.idx) end,
          highlight = 'BlinkCmpItemIdx' -- optional, only if you want to change its color
        }
      }
    }
  }
},
})

-- lsp-format
require("lsp-format").setup {}

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    require("lsp-format").on_attach(client, args.buf)
  end,
})
