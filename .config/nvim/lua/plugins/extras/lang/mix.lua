return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			if type(opts.ensure_installed) == "table" then
				vim.list_extend(opts.ensure_installed, {
					"bash",
					"c",
					"diff",
					"html",
					"javascript",
					"jsdoc",
					"json",
					"jsonc",
					"lua",
					"luadoc",
					"luap",
					"markdown",
					"markdown_inline",
					"python",
					"query",
					"regex",
					"toml",
					"tsx",
					"typescript",
					"vim",
					"vimdoc",
					"xml",
					"yaml",
					"css",
				})
			end
		end,
	},

	{
		"williamboman/mason.nvim",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, {
				"stylua",
				"shfmt",
				"azure-pipelines-language-server",
				"bash-language-server",
				"nginx-language-server",
				"css-lsp",
				"html-lsp",
				"htmx-lsp",
				"sqls",
				"sqlfmt",
				"grammarly-languageserver",
				"yamllint",
				"yamlfmt",
				"lemminx",
				"xmlformatter",
			})
		end,
	},

	{
		"mfussenegger/nvim-lint",
		opts = {
			linters_by_ft = {
				sh = { "shellcheck" },
				yaml = { "yamllint" },
			},
		},
	},

	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				azure_pipelines_ls = {},
				bashls = {},
				nginx_language_server = {},
				sqls = {},
				lemminx = {},
				grammarly = {},
				html = {},
				htmx = {},
				cssls = {},
			},
		},
	},

	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				fish = { "fish_indent" },
				sh = { "shfmt" },
				xml = { "xmlformatter" },
				sql = { "sqlfmt" },
				yaml = { "yamlfmt" },
			},
		},
	},
}
