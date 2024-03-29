local Utils = require("utils")

local map = Utils.safe_keymap_set

return {
	{
		"kdheepak/lazygit.nvim",
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		-- optional for floating window border decoration
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		-- setting the keybinding for LazyGit with 'keys' is recommended in
		-- order to load the plugin when the command is run for the first time
		keys = {
			{ "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
		},
	},

	{
		"nvim-telescope/telescope.nvim",
		version = false,
		dependencies = {
			"ThePrimeagen/harpoon",
			"nvim-lua/plenary.nvim",
			"kkharji/sqlite.lua",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
				cond = vim.fn.executable("cmake") == 1,
			},
			"nvim-telescope/telescope-live-grep-args.nvim",
		},
		config = function()
			local actions = require("telescope.actions")
			local telescope = require("telescope")
			local lga_actions = require("telescope-live-grep-args.actions")

			telescope.setup({
				defaults = {
					windblend = 10,
					previewer = false,
					prompt_title = false,
					prompt_prefix = "🔍 ",
					theme = "cursor",
					layout_strategy = "vertical",
					layout_config = {
						width = 0.7,
						vertical = {
							prompt_position = "top",
							mirror = true,
						},
					},
					mappings = {
						i = {
							["<esc>"] = actions.close,
							["<C-Down>"] = require("telescope.actions").cycle_history_next,
							["<C-Up>"] = require("telescope.actions").cycle_history_prev,
							["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
							["<C-x>"] = actions.delete_buffer,
						},
					},
					history = {
						path = "~/.local/share/nvim/databases/telescope_history.sqlite3",
						limit = 100,
					},
					file_ignore_patterns = {
						"node_modules",
						"yarn.lock",
						".git",
						".sl",
						"_build",
						".next",
						"dist",
						"vendor",
						"*.min.*",
						"*.map",
						"bin",
						"obj",
						"*.o",
					},
					hidden = true,
				},
				extensions = {
					ast_grep = {
						command = { "sg", "--json=stream" }, -- must have --json=stream
						grep_open_files = false, -- search in opened files
						lang = nil, -- string value, specify language for ast-grep `nil` for default
					},
					live_grep_args = {
						auto_quoting = true,
						mappings = {
							i = {
								["<C-i>"] = lga_actions.quote_prompt(),
								["<C-k>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
							},
						},
					},
				},
			})

			-- Load Telescope extensions
			local extensions_to_load = { "fzf", "dap", "smart_history", "live_grep_args" }
			for _, extension in ipairs(extensions_to_load) do
				pcall(telescope.load_extension, extension)
			end

			map("n", "<leader>?", function()
				Utils.telescope("oldfiles")
			end, { desc = "Find recently opened files" })
			map("n", "<leader>:", function()
				Utils.telescope("command_history")
			end, { desc = "Command History" })
			map("n", "<leader>/", "<Cmd>Telescope live_grep_args<CR>", { desc = "Grep (root dir)" })
			map("n", "<leader><space>", Utils.telescope("files"), { desc = "Find File" })
			map("n", "<leader>.", function()
				require("telescope.builtin").current_buffer_fuzzy_find({ previewer = false })
			end, { desc = "Fuzzily search in current buffer" })

			map("n", "<leader>sf", function()
				Utils.telescope("find_files", { hidden = true })
			end, { desc = "Search Files" })
			map("n", "<leader>sh", function()
				Utils.telescope("help_tags")
			end, { desc = "Search Help" })
			map("n", "<leader>ss", function()
				Utils.telescope("spell_suggest", { previewer = false })
			end, { desc = "Search Spelling suggestions" })
			map(
				"n",
				"<leader>sb",
				Utils.telescope("buffers", { sort_mru = true, sort_lastused = true }),
				{ desc = "Buffers" }
			)
			map("n", "<leader>sc", Utils.telescope("find_files", { cwd = Utils.root() }), { desc = "Find Config File" })
			map("n", "<leader>sf", Utils.telescope("files"), { desc = "Find Files (root dir)" })
			map("n", "<leader>sF", Utils.telescope("files", { cwd = false }), { desc = "Find Files (cwd)" })
			map("n", "<leader>sg", Utils.telescope("git_files"), { desc = "Find Files (git-files)" })
			map("n", "<leader>s-", Utils.telescope("oldfiles"), { desc = "Recent" })
			map("n", "<leader>s_", Utils.telescope("oldfiles", { cwd = vim.loop.cwd() }), { desc = "Recent (cwd)" })
			map("n", '<leader>s"', Utils.telescope("registers"), { desc = "Registers" })
			map("n", "<leader>sa", Utils.telescope("autocommands"), { desc = "Auto Commands" })
			map("n", "<leader>sb", Utils.telescope("current_buffer_fuzzy_find"), { desc = "Buffer" })
			map("n", "<leader>sc", Utils.telescope("command_history"), { desc = "Command History" })
			map("n", "<leader>sC", Utils.telescope("commands"), { desc = "Commands" })
			map("n", "<leader>sd", Utils.telescope("diagnostics", { bufnr = 0 }), { desc = "Document diagnostics" })
			map("n", "<leader>sD", Utils.telescope("diagnostics"), { desc = "Workspace diagnostics" })
			map("n", "<leader>sg", Utils.telescope("live_grep"), { desc = "Grep (root dir)" })
			map("n", "<leader>sG", Utils.telescope("live_grep", { cwd = false }), { desc = "Grep (cwd)" })
			map("n", "<leader>sh", Utils.telescope("help_tags"), { desc = "Help Pages" })
			map("n", "<leader>sH", Utils.telescope("highlights"), { desc = "Search Highlight Groups" })
			map("n", "<leader>sk", Utils.telescope("keymaps"), { desc = "Key Maps" })
			map("n", "<leader>sM", Utils.telescope("man_pages"), { desc = "Man Pages" })
			map("n", "<leader>sm", Utils.telescope("marks"), { desc = "Jump to Mark" })
			map("n", "<leader>so", Utils.telescope("vim_options"), { desc = "Options" })
			map("n", "<leader>s.", Utils.telescope("resume"), { desc = "Resume" })
			map(
				"n",
				"<leader>uC",
				Utils.telescope("colorscheme", { enable_preview = true }),
				{ desc = "Colorscheme with preview" }
			)
		end,
	},

	{
		"nvim-pack/nvim-spectre",
		build = false,
		cmd = "Spectre",
		opts = { open_cmd = "noswapfile vnew" },
    -- stylua: ignore
    keys = {
      { "<leader>sr", function() require("spectre").open() end, desc = "Replace in files (Spectre)" },
    },
	},

	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		config = function()
			local harpoon = require("harpoon")

			harpoon:setup()

			map("n", "<leader>aa", function()
				harpoon:list():append()
			end, {
				desc = "Append to Harpoon",
			})

			map("n", "<leader>a1", function()
				harpoon:list():select(1)
			end, {
				desc = "Select Harpoon 1",
			})
			map("n", "<leader>a2", function()
				harpoon:list():select(2)
			end, {
				desc = "Select Harpoon 2",
			})
			map("n", "<leader>a3", function()
				harpoon:list():select(3)
			end, {
				desc = "Select Harpoon 3",
			})
			map("n", "<leader>a4", function()
				harpoon:list():select(4)
			end, {
				desc = "Select Harpoon 4",
			})

			-- Toggle previous & next buffers stored within Harpoon list
			map("n", "<leader>a[", function()
				harpoon:list():prev()
			end, { desc = "Previous Harpoon" })
			map("n", "<leader>a]", function()
				harpoon:list():next()
			end, { desc = "Next Harpoon" })
			map("n", "[a", function()
				harpoon:list():prev()
			end, { desc = "Previous Harpoon" })
			map("n", "]a", function()
				harpoon:list():next()
			end, { desc = "Next Harpoon" })

			-- basic telescope configuration
			local conf = require("telescope.config").values
			local function toggle_telescope(harpoon_files)
				local file_paths = {}
				for _, item in ipairs(harpoon_files.items) do
					table.insert(file_paths, item.value)
				end

				require("telescope.pickers")
					.new({}, {
						prompt_title = "Harpoon",
						finder = require("telescope.finders").new_table({
							results = file_paths,
						}),
						sorter = conf.generic_sorter({}),
					})
					:find()
			end

			map("n", "<C-e>", function()
				toggle_telescope(harpoon:list())
			end, { desc = "Open harpoon window" })
			map("n", "<leader>,", function()
				toggle_telescope(harpoon:list())
			end, { desc = "Open harpoon window" })
			map("n", "<leader>a,", function()
				toggle_telescope(harpoon:list())
			end, { desc = "Open harpoon window" })
		end,
	},

	{
		"folke/flash.nvim",
		event = "VeryLazy",
		---@type Flash.Config
		opts = {},
        -- stylua: ignore
        keys = {
            {
                "s",
                mode = {"n", "x", "o"},
                function() require("flash").jump() end,
                desc = "Flash"
            }, {
                "S",
                mode = {"n", "x", "o"},
                function() require("flash").treesitter() end,
                desc = "Flash Treesitter"
            }, {
                "r",
                mode = "o",
                function() require("flash").remote() end,
                desc = "Remote Flash"
            }, {
                "R",
                mode = {"o", "x"},
                function() require("flash").treesitter_search() end,
                desc = "Treesitter Search"
            }, {
                "<c-s>",
                mode = {"c"},
                function() require("flash").toggle() end,
                desc = "Toggle Flash Search"
            }
        }
,
	},
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
		end,
	},
	{
		"stevearc/oil.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local oil = require("oil")
			oil.setup({
				columns = {
					"icon",
				},
				default_file_explorer = true,
				experimental_watch_for_changes = true,
				use_default_keymaps = false,
				keymaps = {
					["g?"] = "actions.show_help",
					["<CR>"] = "actions.select",
					["<C-\\>"] = "actions.select_vsplit",
					["<C-enter>"] = "actions.select_split", -- this is used to navigate left
					["<C-t>"] = "actions.select_tab",
					["<C-p>"] = "actions.preview",
					["<C-c>"] = "actions.close",
					["<C-r>"] = "actions.refresh",
					["-"] = "actions.parent",
					["_"] = "actions.open_cwd",
					["`"] = "actions.cd",
					["~"] = "actions.tcd",
					["gs"] = "actions.change_sort",
					["gx"] = "actions.open_external",
					["g."] = "actions.toggle_hidden",
				},
				view_options = { show_hidden = true },
				preview = {
					max_width = 0.6,
				},
				float = {
					max_width = 100,
				},
			})

			map("n", "<leader>o", function()
				oil.toggle_float()
			end, { desc = "Open Oil" })
		end,
	},

	{
		"folke/persistence.nvim",
		event = "BufReadPre", -- this will only start session saving when an actual file was opened
		opts = { options = vim.opt.sessionoptions:get() },
    -- stylua: ignore
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
    },
	},

	{
		"akinsho/toggleterm.nvim",
		config = function()
			require("toggleterm").setup({
				open_mapping = [[<c-/>]],
				shade_terminals = false,
				-- add --login so ~/.zprofile is loaded
				-- https://vi.stackexchange.com/questions/16019/neovim-terminal-not-reading-bash-profile/16021#16021
				shell = "zsh --login",
				direction = "horizontal",
			})
		end,
	},

	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local trouble = require("trouble")
			trouble.setup({
				auto_preview = false,
				auto_fold = true,
				use_diagnostic_signs = true,
			})

			map("n", "<leader>xx", function()
				trouble.toggle()
			end, { desc = "Trouble Toggle" })

			map("n", "<leader>xw", function()
				trouble.toggle({ mode = "workspace" })
			end, { desc = "Trouble Workspace" })

			map("n", "<leader>xd", function()
				trouble.toggle({ mode = "document" })
			end, { desc = "Trouble Document" })

			map("n", "<leader>xl", function()
				trouble.toggle({ mode = "loclist" })
			end, { desc = "Trouble Loclist" })

			map("n", "<leader>xq", function()
				trouble.toggle({ mode = "quickfix" })
			end, { desc = "Trouble Quickfix" })

			map("n", "gR", function()
				trouble.toggle({ mode = "lsp_references" })
			end, { desc = "Trouble LSP References" })
		end,
	},

	{
		"kevinhwang91/nvim-ufo",
		event = "BufEnter",
		dependencies = { "kevinhwang91/promise-async" },
		config = function()
			--- @diagnostic disable: unused-local
			require("ufo").setup({
				provider_selector = function(_bufnr, _filetype, _buftype)
					return { "treesitter", "indent" }
				end,
			})
		end,
	},

	-- Automatically highlights other instances of the word under your cursor.
	-- This works with LSP, Treesitter, and regexp matching to find the other
	-- instances.
	{
		"RRethy/vim-illuminate",
		opts = {
			delay = 200,
			large_file_cutoff = 2000,
			large_file_overrides = { providers = { "lsp" } },
		},
		config = function(_, opts)
			require("illuminate").configure(opts)

			local function map(key, dir, buffer)
				vim.keymap.set("n", key, function()
					require("illuminate")["goto_" .. dir .. "_reference"](false)
				end, {
					desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference",
					buffer = buffer,
				})
			end

			map("]]", "next")
			map("[[", "prev")

			-- also set it after loading ftplugins, since a lot overwrite [[ and ]]
			vim.api.nvim_create_autocmd("FileType", {
				callback = function()
					local buffer = vim.api.nvim_get_current_buf()
					map("]]", "next", buffer)
					map("[[", "prev", buffer)
				end,
			})
		end,
		keys = {
			{ "]]", desc = "Next Reference" },
			{ "[[", desc = "Prev Reference" },
		},
	},

	-- buffer remove
	{
		"echasnovski/mini.bufremove",
		keys = {
			{
				"<leader>bd",
				function()
					local bd = require("mini.bufremove").delete
					if vim.bo.modified then
						local choice =
							vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
						if choice == 1 then -- Yes
							vim.cmd.write()
							bd(0)
						elseif choice == 2 then -- No
							bd(0, true)
						end
					else
						bd(0)
					end
				end,
				desc = "Delete Buffer",
			}, -- stylua: ignore
			{
				"<leader>bD",
				function()
					require("mini.bufremove").delete(0, true)
				end,
				desc = "Delete Buffer (Force)",
			},
		},
	},
}
