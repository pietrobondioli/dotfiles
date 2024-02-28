local Utils = require("utils")

local map = Utils.safe_keymap_set

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

            map("n", "<leader>?",
                function() require("telescope.builtin").oldfiles() end,
                {desc = "Find recently opened files"})
            map("n", "<leader>:", "<cmd>Telescope command_history<cr>",
                {desc = "Command History"})
            map("n", "<leader>/", Utils.telescope("live_grep"),
                {desc = "Grep (root dir)"})
            map("n", "<leader><space>", Utils.telescope("files"),
                {desc = "Find Files (root dir)"})
            map("n", "<leader>.", function()
                require("telescope.builtin").current_buffer_fuzzy_find(require(
                                                                           "telescope.themes").get_dropdown(
                                                                           {
                        previewer = false
                    }))
            end, {desc = "Fuzzily search in current buffer"})

            map("n", "<leader>sf", function()
                require("telescope.builtin").find_files({hidden = true})
            end, {desc = "Search Files"})
            map("n", "<leader>sh",
                function() require("telescope.builtin").help_tags() end,
                {desc = "Search Help"})
            map("n", "<leader>ss", function()
                require("telescope.builtin").spell_suggest(require(
                                                               "telescope.themes").get_dropdown(
                                                               {
                        previewer = false
                    }))
            end, {desc = "Search Spelling suggestions"})
            map("n", "<leader>sb",
                "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",
                {desc = "Buffers"})
            map("n", "<leader>sc", Utils.telescope.config_files(),
                {desc = "Find Config File"})
            map("n", "<leader>sf", Utils.telescope("files"),
                {desc = "Find Files (root dir)"})
            map("n", "<leader>sF", Utils.telescope("files", {cwd = false}),
                {desc = "Find Files (cwd)"})
            map("n", "<leader>sg", "<cmd>Telescope git_files<cr>",
                {desc = "Find Files (git-files)"})
            map("n", "<leader>sr", "<cmd>Telescope oldfiles<cr>",
                {desc = "Recent"})
            map("n", "<leader>sR",
                Utils.telescope("oldfiles", {cwd = vim.loop.cwd()}),
                {desc = "Recent (cwd)"})
            map("n", '<leader>s"', "<cmd>Telescope registers<cr>",
                {desc = "Registers"})
            map("n", "<leader>sa", "<cmd>Telescope autocommands<cr>",
                {desc = "Auto Commands"})
            map("n", "<leader>sb",
                "<cmd>Telescope current_buffer_fuzzy_find<cr>",
                {desc = "Buffer"})
            map("n", "<leader>sc", "<cmd>Telescope command_history<cr>",
                {desc = "Command History"})
            map("n", "<leader>sC", "<cmd>Telescope commands<cr>",
                {desc = "Commands"})
            map("n", "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>",
                {desc = "Document diagnostics"})
            map("n", "<leader>sD", "<cmd>Telescope diagnostics<cr>",
                {desc = "Workspace diagnostics"})
            map("n", "<leader>sg", Utils.telescope("live_grep"),
                {desc = "Grep (root dir)"})
            map("n", "<leader>sG", Utils.telescope("live_grep", {cwd = false}),
                {desc = "Grep (cwd)"})
            map("n", "<leader>sh", "<cmd>Telescope help_tags<cr>",
                {desc = "Help Pages"})
            map("n", "<leader>sH", "<cmd>Telescope highlights<cr>",
                {desc = "Search Highlight Groups"})
            map("n", "<leader>sk", "<cmd>Telescope keymaps<cr>",
                {desc = "Key Maps"})
            map("n", "<leader>sM", "<cmd>Telescope man_pages<cr>",
                {desc = "Man Pages"})
            map("n", "<leader>sm", "<cmd>Telescope marks<cr>",
                {desc = "Jump to Mark"})
            map("n", "<leader>so", "<cmd>Telescope vim_options<cr>",
                {desc = "Options"})
            map("n", "<leader>sR", "<cmd>Telescope resume<cr>",
                {desc = "Resume"})
            map("n", "<leader>sw",
                Utils.telescope("grep_string", {word_match = "-w"}),
                {desc = "Word (root dir)"})
            map("n", "<leader>sW", Utils.telescope("grep_string", {
                cwd = false,
                word_match = "-w"
            }), {desc = "Word (cwd)"})
            map("v", "<leader>sw", Utils.telescope("grep_string"),
                {desc = "Selection (root dir)"})
            map("v", "<leader>sW",
                Utils.telescope("grep_string", {cwd = false}),
                {desc = "Selection (cwd)"})
            map("n", "<leader>uC",
                Utils.telescope("colorscheme", {enable_preview = true}),
                {desc = "Colorscheme with preview"})
        end
    }, {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        config = function()
            local harpoon = require("harpoon")

            harpoon:setup()

            map("n", "<leader>aa", function() harpoon:list():append() end)

            map("n", "<leader>a1", function()
                harpoon:list():select(1)
            end)
            map("n", "<leader>a2", function()
                harpoon:list():select(2)
            end)
            map("n", "<leader>a3", function()
                harpoon:list():select(3)
            end)
            map("n", "<leader>a4", function()
                harpoon:list():select(4)
            end)

            -- Toggle previous & next buffers stored within Harpoon list
            map("n", "<C-S-P>", function() harpoon:list():prev() end)
            map("n", "<leader>a[", function() harpoon:list():prev() end)
            map("n", "<C-S-N>", function() harpoon:list():next() end)
            map("n", "<leader>a]", function() harpoon:list():next() end)

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

            map("n", "<C-e>", function()
                toggle_telescope(harpoon:list())
            end, {desc = "Open harpoon window"})
            map("n", "<leader>,",
                function() toggle_telescope(harpoon:list()) end,
                {desc = "Open harpoon window"})
            map("n", "<leader>a,",
                function() toggle_telescope(harpoon:list()) end,
                {desc = "Open harpoon window"})

        end
    }, {
        "folke/flash.nvim",
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
        config = function() require("gitsigns").setup() end
    }, {"ahmedkhalf/project.nvim"}, {
        "stevearc/oil.nvim",
        dependencies = {"nvim-tree/nvim-web-devicons"},
        config = function()
            local oil = require("oil")
            oil.setup({
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
                    ["g."] = "actions.toggle_hidden"
                },
                view_options = {show_hidden = true}
            })

            -- Map Oil to <leader>e
            map("n", "<leader>e", function() oil.toggle_float() end,
                {desc = "Open Oil"})
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

            local spectre = require("spectre")

            spectre.setup({
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

            -- Open Spectre for global find/replace
            map("n", "<leader>sw",
                function() spectre.open_visual({select_word = true}) end,
                {desc = "Search current word"})

            -- Open Spectre for global find/replace for the word under the cursor in normal mode
            -- TODO Fix, currently being overriden by Telescope
            map("n", "<leader>ss", function()
                spectre.open_file_search()
            end, {desc = "Search in file"})
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
        config = function()
            local trouble = require("trouble")
            trouble.setup({
                auto_preview = false,
                auto_fold = true,
                use_diagnostic_signs = true
            })

            map("n", "<leader>xx", function() trouble.toggle() end,
                {desc = "Trouble Toggle"})

            map("n", "<leader>xw",
                function() trouble.toggle({mode = "workspace"}) end,
                {desc = "Trouble Workspace"})

            map("n", "<leader>xd",
                function() trouble.toggle({mode = "document"}) end,
                {desc = "Trouble Document"})

            map("n", "<leader>xl",
                function() trouble.toggle({mode = "loclist"}) end,
                {desc = "Trouble Loclist"})

            map("n", "<leader>xq",
                function() trouble.toggle({mode = "quickfix"}) end,
                {desc = "Trouble Quickfix"})

            map("n", "gR",
                function() trouble.toggle({mode = "lsp_references"}) end,
                {desc = "Trouble LSP References"})
        end
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
