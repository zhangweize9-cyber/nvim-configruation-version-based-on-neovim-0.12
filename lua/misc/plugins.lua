local plugins_url = {
	-- colorscheme
	-- NOTE:These are builtin interface.
	"https://github.com/catppuccin/nvim",
	"https://github.com/MunifTanjim/nui.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",
	-- plenary
	"https://github.com/nvim-lua/plenary.nvim",
	-- telescope
	"https://github.com/nvim-telescope/telescope.nvim",

	-- lsp client
	-- PERF:These are language servers.
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/mason-org/mason-lspconfig.nvim",
	"https://github.com/neovim/nvim-lspconfig",
	-- completion
	"https://github.com/saghen/blink.lib",
	"https://github.com/saghen/blink.cmp",
	-- format
	"https://github.com/stevearc/conform.nvim",
	-- treesitter
	"https://github.com/nvim-treesitter/nvim-treesitter",
	-- go to definition
	"https://github.com/rmagatti/goto-preview",
	"https://github.com/nvimdev/lspsaga.nvim",
	-- colorful-menu
	"https://github.com/xzbdmw/colorful-menu.nvim",

	-- pair
	-- NOTE:These including useful tools.
	"https://github.com/nvim-mini/mini.pairs",
	-- indent
	"https://github.com/saghen/blink.indent",
	-- gitsigns
	"https://github.com/lewis6991/gitsigns.nvim",
	-- todo-comments.nvim
	"https://github.com/folke/todo-comments.nvim",
	-- toggleterm
	"https://github.com/akinsho/toggleterm.nvim",
	-- neotree
	"https://github.com/nvim-neo-tree/neo-tree.nvim",
	-- edgy
	"https://github.com/folke/edgy.nvim",
	-- windows
	"https://github.com/nvim-zh/colorful-winsep.nvim",
}

for _, plugins_link in ipairs(plugins_url) do
	vim.pack.add({ { src = plugins_link } })
end

-- catppuccin
vim.cmd.colorscheme("catppuccin-nvim")

-- mason.nvim
require("mason").setup({
	firewall = {
		enabled = true,
	},
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
})

-- mason-lspconfig.nvim
require("mason-lspconfig").setup({
	automatic_enable = true,
})

-- nvim-lspconfig & neovim lsp api
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH
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

local base_on_attach = vim.lsp.config.eslint.on_attach
vim.lsp.config("eslint", {
	on_attach = function(client, bufnr)
		if not base_on_attach then
			return
		end

		base_on_attach(client, bufnr)
		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = bufnr,
			command = "LspEslintFixAll",
		})
	end,
})

vim.lsp.enable("lua_ls")
vim.lsp.enable("clangd")
vim.lsp.enable("eslint")

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if not client then
			return
		end
		-- inlayHint.
		pcall(vim.lsp.inlay_hint.enable, true, { bufnr = ev.buf })
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition", buffer = ev.buf })
	end,
})

vim.diagnostic.config({
	virtual_lines = {
		only_current_line = true,
	},
	virtual_text = true,
	signs = true,
	update_in_insert = false,
	severity_sort = true,
})

-- blink.cmp
local cmp = require("blink.cmp")
cmp.build():pwait()
cmp.setup({
	keymap = {
		preset = "super-tab",
		["<A-1>"] = {
			function(cmp)
				cmp.accept({ index = 1 })
			end,
		},
		["<A-2>"] = {
			function(cmp)
				cmp.accept({ index = 2 })
			end,
		},
		["<A-3>"] = {
			function(cmp)
				cmp.accept({ index = 3 })
			end,
		},
		["<A-4>"] = {
			function(cmp)
				cmp.accept({ index = 4 })
			end,
		},
		["<A-5>"] = {
			function(cmp)
				cmp.accept({ index = 5 })
			end,
		},
		["<A-6>"] = {
			function(cmp)
				cmp.accept({ index = 6 })
			end,
		},
		["<A-7>"] = {
			function(cmp)
				cmp.accept({ index = 7 })
			end,
		},
		["<A-8>"] = {
			function(cmp)
				cmp.accept({ index = 8 })
			end,
		},
		["<A-9>"] = {
			function(cmp)
				cmp.accept({ index = 9 })
			end,
		},
		["<A-0>"] = {
			function(cmp)
				cmp.accept({ index = 10 })
			end,
		},
	},
	completion = {
		ghost_text = {
			enabled = true,
		},
		menu = {
			direction_priority = function()
				local ctx = require("blink.cmp").get_context()
				local item = require("blink.cmp").get_selected_item()
				if ctx == nil or item == nil then
					return { "s", "n" }
				end

				local item_text = item.textEdit ~= nil and item.textEdit.newText or item.insertText or item.label
				local is_multi_line = item_text:find("\n") ~= nil

				-- after showing the menu upwards, we want to maintain that direction
				-- until we re-open the menu, so store the context id in a global variable
				if is_multi_line or vim.g.blink_cmp_upwards_ctx_id == ctx.id then
					vim.g.blink_cmp_upwards_ctx_id = ctx.id
					return { "n", "s" }
				end
				return { "s", "n" }
			end,
			draw = {
				columns = { { "item_idx" }, { "kind_icon" }, { "label", "label_description", gap = 1 } },
				components = {
					item_idx = {
						text = function(ctx)
							return ctx.idx == 10 and "0" or ctx.idx >= 10 and " " or tostring(ctx.idx)
						end,
						highlight = "BlinkCmpItemIdx", -- optional, only if you want to change its color
					},
					label = {
						text = function(ctx)
							return require("colorful-menu").blink_components_text(ctx)
						end,
						highlight = function(ctx)
							return require("colorful-menu").blink_components_highlight(ctx)
						end,
					},
				},
			},
		},
	},
})

-- comform.nvim
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
	},
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		require("conform").format({ bufnr = args.buf })
	end,
})

-- treesitter
require("nvim-treesitter").setup({
	highlight = {
		enable = true,
	},
	indent = {
		enable = false,
	},
})
require("nvim-treesitter").install({ "c", "cpp", "javascript", "lua" })

-- go to preview
require("goto-preview").setup({
	width = 120, -- Width of the floating window
	height = 15, -- Height of the floating window
	border = { " ", "─", "┐", "│", "┘", "─", "└", "│" }, -- Border characters of the floating window
	default_mappings = true, -- Bind default mappings
	debug = false, -- Print debug information
	opacity = nil, -- 0-100 opacity level of the floating window where 100 is fully transparent.
	resizing_mappings = false, -- Binds arrow keys to resizing the floating window.
	post_open_hook = nil, -- A function taking two arguments, a buffer and a window to be ran as a hook.
	post_close_hook = nil, -- A function taking two arguments, a buffer and a window to be ran as a hook.
	references = { -- Configure the telescope UI for slowing the references cycling window.
		provider = "telescope", -- telescope|fzf_lua|snacks|mini_pick|default
		telescope = require("telescope.themes").get_dropdown({ hide_preview = false }),
	},
	-- These two configs can also be passed down to the goto-preview definition and implementation calls for one off "peak" functionality.
	focus_on_open = true, -- Focus the floating window when opening it.
	dismiss_on_move = false, -- Dismiss the floating window when moving the cursor.
	force_close = true, -- passed into vim.api.nvim_win_close's second argument. See :h nvim_win_close
	bufhidden = "wipe", -- the bufhidden option to set on the floating window. See :h bufhidden
	stack_floating_preview_windows = true, -- Whether to nest floating windows
	same_file_float_preview = true, -- Whether to open a new floating window for a reference within the current file
	preview_window_title = { enable = true, position = "left" }, -- Whether to set the preview window title as the filename
	zindex = 1, -- Starting zindex for the stack of floating windows
	vim_ui_input = true, -- Whether to override vim.ui.input with a goto-preview floating window
})

-- pair
require("mini.pairs").setup()

-- indent
require("blink.indent").setup({
	-- filetypes where scopes are closed by dedenting, such as python and yaml
	-- set to true to treat all filetypes this way
	dedent_scoped_filetypes = { include_defaults = true },
	blocked = {
		-- default: 'terminal', 'quickfix', 'nofile', 'prompt'
		buftypes = { include_defaults = true },
		-- default: 'lspinfo', 'packer', 'checkhealth', 'help', 'man', 'gitcommit', 'dashboard', ''
		filetypes = { include_defaults = true },
	},
	mappings = {
		-- which lines around the scope are included for 'ai': 'top', 'bottom', 'both', or 'none'
		border = "both",
		-- set to '' to disable
		-- textobjects (e.g. `y2ii` to yank current and outer scope)
		object_scope = "ii",
		object_scope_with_border = "ai",
		-- motions
		goto_top = "[i",
		goto_bottom = "]i",
	},
	static = {
		enabled = true,
		char = "▎",
		whitespace_char = nil, -- inherits from `vim.opt.listchars:get().space` when `nil` (see `:h listchars`)
		priority = 1,
		-- specify multiple highlights here for rainbow-style indent guides
		-- highlights = { 'BlinkIndentRed', 'BlinkIndentOrange', 'BlinkIndentYellow', 'BlinkIndentGreen', 'BlinkIndentViolet', 'BlinkIndentCyan' },
		highlights = { "BlinkIndent" },
	},
	scope = {
		enabled = true, -- highlight highest level of indentation on the current line
		indent_at_cursor = false, -- clamp to indent level of cursor
		char = "▎",
		priority = 1000,
		-- set this to a single highlight, such as 'BlinkIndent' to disable rainbow-style indent guides
		-- highlights = { 'BlinkIndentScope' },
		-- optionally add: 'BlinkIndentRed', 'BlinkIndentCyan', 'BlinkIndentYellow', 'BlinkIndentGreen'
		highlights = { "BlinkIndentOrange", "BlinkIndentViolet", "BlinkIndentBlue" },
		-- enable to show underlines on the line above the current scope
		underline = {
			enabled = false,
			-- optionally add: 'BlinkIndentRedUnderline', 'BlinkIndentCyanUnderline', 'BlinkIndentYellowUnderline', 'BlinkIndentGreenUnderline'
			highlights = { "BlinkIndentOrangeUnderline", "BlinkIndentVioletUnderline", "BlinkIndentBlueUnderline" },
		},
	},
})

-- lspsaga
require("lspsaga").setup({})

-- gitsigns
require("gitsigns").setup({})

-- todo-comments
require("todo-comments").setup({})

vim.keymap.set("n", "]t", function()
	require("todo-comments").jump_next()
end, { desc = "Next todo comment" })

vim.keymap.set("n", "[t", function()
	require("todo-comments").jump_prev()
end, { desc = "Previous todo comment" })

-- toggleterm & neotree
require("neo-tree").setup({})
vim.keymap.set("n", "<leader>t", "<cmd>Neotree<cr>")
require("toggleterm").setup({})
vim.keymap.set("n", "<leader>ot", "<cmd>ToggleTerm size=10 direction=horizontal name=desktop<cr>")

-- edgy
require("edgy").setup({
	left = {
		{
			ft = "neo-tree",
			title = "Neo-Tree",
			filter = function(buf)
				return vim.b[buf].neo_tree_source == "filesystem"
			end,
		},
	},
})

-- windows
require("colorful-winsep").setup({})
