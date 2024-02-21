return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"ThePrimeagen/harpoon",
		"nvim-lua/plenary.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
			cond = vim.fn.executable("cmake") == 1,
		},
	},
	config = function()
		local actions = require("telescope.actions")

		require("telescope").setup({
			defaults = {
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous,
						["<C-j>"] = actions.move_selection_next,
						["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
						["<C-x>"] = actions.delete_buffer,
					},
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
					command = {
						"sg",
						"--json=stream",
					}, -- must have --json=stream
					grep_open_files = false, -- search in opened files
					lang = nil, -- string value, specify language for ast-grep `nil` for default
				}
			}
		})

		-- Enable telescope fzf native, if installed
		pcall(require("telescope").load_extension, "fzf")
	end,
}
