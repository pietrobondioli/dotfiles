return {
	{
		"folke/which-key.nvim",
		opts = {
			defaults = {
				["<leader>d"] = "+[d]ebug",
				["<leader>h"] = "+[h]elp",
				["<leader>q"] = "+[q]uit",
				["<leader>w"] = "+[w]indows",
				["<leader>g"] = "+[g]it",
				["<leader><tab>"] = "+[t]abs",
				["<leader>s"] = "+[s]earch",
				["<leader>b"] = "+[b]uffers",
				["<leader>c"] = "+[c]ode",
				["<leader>u"] = "+[u]i",
				["<leader>x"] = "+[t]rouble",
				["<leader>a"] = "+h[a]rpoon",
			},
		},
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		config = function(_, opts)
			local wk = require("which-key")
			wk.setup(opts)
			wk.register(opts.defaults)
		end,
	},

	{
		"folke/neodev.nvim",
		opts = { library = { plugins = { "neotest" }, types = true } },
	},

	{
		"hrsh7th/cmp-cmdline",
		config = function()
			local cmp = require("cmp")
			-- `/` cmdline setup.
			cmp.setup.cmdline("/", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			-- `:` cmdline setup.
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{
						name = "cmdline",
						option = {
							ignore_cmds = { "Man", "!" },
						},
					},
				}),
			})
		end,
	},
}
