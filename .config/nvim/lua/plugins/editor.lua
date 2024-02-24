return {
    {"kdheepak/lazygit.nvim", dependencies = {"nvim-lua/plenary.nvim"}}, {
        "nvim-telescope/telescope.nvim",
        version = false,
        dependencies = {
            "ThePrimeagen/harpoon", "nvim-lua/plenary.nvim", {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
                cond = vim.fn.executable("cmake") == 1
            }
        },
        config = function()
            local actions = require("telescope.actions")

            require("telescope").setup({
                defaults = {
                    mappings = {
                        i = {
                            ["<C-k>"] = actions.move_selection_previous,
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-q>"] = actions.send_selected_to_qflist +
                                actions.open_qflist,
                            ["<C-x>"] = actions.delete_buffer
                        }
                    },
                    file_ignore_patterns = {
                        "node_modules", "yarn.lock", ".git", ".sl", "_build",
                        ".next", "dist", "vendor", "*.min.*", "*.map", "bin",
                        "obj", "*.o"
                    },
                    hidden = true
                },
                extensions = {
                    ast_grep = {
                        command = {"sg", "--json=stream"}, -- must have --json=stream
                        grep_open_files = false, -- search in opened files
                        lang = nil -- string value, specify language for ast-grep `nil` for default
                    }
                }
            })

            -- Enable telescope fzf native, if installed
            pcall(require("telescope").load_extension, "fzf")
            pcall(require("telescope").load_extension, "dap")
        end
    }, {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        config = function()
            local harpoon = require("harpoon")

            harpoon:setup()

            vim.keymap.set("n", "<leader>a",
                           function() harpoon:list():append() end)

            vim.keymap.set("n", "<C-h>", function()
                harpoon:list():select(1)
            end)
            vim.keymap.set("n", "<C-t>", function()
                harpoon:list():select(2)
            end)
            vim.keymap.set("n", "<C-n>", function()
                harpoon:list():select(3)
            end)
            vim.keymap.set("n", "<C-s>", function()
                harpoon:list():select(4)
            end)

            -- Toggle previous & next buffers stored within Harpoon list
            vim.keymap.set("n", "<C-S-P>", function()
                harpoon:list():prev()
            end)
            vim.keymap.set("n", "<C-S-N>", function()
                harpoon:list():next()
            end)

            -- basic telescope configuration
            local conf = require("telescope.config").values
            local function toggle_telescope(harpoon_files)
                local file_paths = {}
                for _, item in ipairs(harpoon_files.items) do
                    table.insert(file_paths, item.value)
                end

                require("telescope.pickers").new({}, {
                    prompt_title = "Harpoon",
                    finder = require("telescope.finders").new_table({
                        results = file_paths
                    }),
                    previewer = conf.file_previewer({}),
                    sorter = conf.generic_sorter({})
                }):find()
            end

            vim.keymap.set("n", "<C-e>",
                           function()
                toggle_telescope(harpoon:list())
            end, {desc = "Open harpoon window"})
        end
    }, {
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
    }, {
        "lewis6991/gitsigns.nvim",
        event = "VeryLazy",
        config = function() require("gitsigns").setup() end
    }, {"ahmedkhalf/project.nvim"}, {
        "stevearc/oil.nvim",
        opts = {},
        -- Optional dependencies
        dependencies = {"nvim-tree/nvim-web-devicons"},
        config = function()
            require("oil").setup({
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
                    ["g."] = "actions.toggle_hidden"
                },
                view_options = {show_hidden = true}
            })
        end
    }, {
        "folke/persistence.nvim",
        event = "BufReadPre" -- this will only start session saving when an actual file was opened
    }, {
        "nvim-pack/nvim-spectre",
        lazy = true,
        cmd = {"Spectre"},
        dependencies = {"nvim-lua/plenary.nvim", "catppuccin/nvim"},
        config = function()
            local theme =
                require("catppuccin.palettes").get_palette("macchiato")

            vim.api.nvim_set_hl(0, "SpectreSearch",
                                {bg = theme.red, fg = theme.base})
            vim.api.nvim_set_hl(0, "SpectreReplace",
                                {bg = theme.green, fg = theme.base})

            require("spectre").setup({
                highlight = {
                    search = "SpectreSearch",
                    replace = "SpectreReplace"
                },
                mapping = {
                    ["send_to_qf"] = {
                        map = "<C-q>",
                        cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
                        desc = "send all items to quickfix"
                    }
                }
            })
        end
    }, {
        "akinsho/toggleterm.nvim",
        config = function()
            require("toggleterm").setup({
                open_mapping = [[<c-/>]],
                shade_terminals = false,
                -- add --login so ~/.zprofile is loaded
                -- https://vi.stackexchange.com/questions/16019/neovim-terminal-not-reading-bash-profile/16021#16021
                shell = "zsh --login",
                direction = "horizontal"
            })
        end
    }, {
        "folke/trouble.nvim",
        dependencies = {"nvim-tree/nvim-web-devicons"},
        opts = {}
    }, {
        "kevinhwang91/nvim-ufo",
        event = "BufEnter",
        dependencies = {"kevinhwang91/promise-async"},
        config = function()
            --- @diagnostic disable: unused-local
            require("ufo").setup({
                provider_selector = function(_bufnr, _filetype, _buftype)
                    return {"treesitter", "indent"}
                end
            })
        end
    },
    -- Automatically highlights other instances of the word under your cursor.
    -- This works with LSP, Treesitter, and regexp matching to find the other
    -- instances.
    {
        "RRethy/vim-illuminate",
        event = "LazyFile",
        opts = {
            delay = 200,
            large_file_cutoff = 2000,
            large_file_overrides = {providers = {"lsp"}}
        },
        config = function(_, opts)
            require("illuminate").configure(opts)

            local function map(key, dir, buffer)
                vim.keymap.set("n", key, function()
                    require("illuminate")["goto_" .. dir .. "_reference"](false)
                end, {
                    desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference",
                    buffer = buffer
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
                end
            })
        end,
        keys = {
            {"]]", desc = "Next Reference"}, {"[[", desc = "Prev Reference"}
        }
    }, -- buffer remove
    {
        "echasnovski/mini.bufremove",

        keys = {
            {
                "<leader>bd",
                function()
                    local bd = require("mini.bufremove").delete
                    if vim.bo.modified then
                        local choice = vim.fn.confirm(
                                           ("Save changes to %q?"):format(vim.fn
                                                                              .bufname()),
                                           "&Yes\n&No\n&Cancel")
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
                desc = "Delete Buffer"
            }, -- stylua: ignore
            {
                "<leader>bD",
                function()
                    require("mini.bufremove").delete(0, true)
                end,
                desc = "Delete Buffer (Force)"
            }
        }
    }
}
