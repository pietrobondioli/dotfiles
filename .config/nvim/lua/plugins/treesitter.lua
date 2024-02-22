return {{
    "nvim-treesitter/nvim-treesitter",
    build = function()
        require("nvim-treesitter.install").update({
            with_sync = true
        })
    end,
    event = {"BufEnter"},
    dependencies = { -- Additional text objects for treesitter
    "nvim-treesitter/nvim-treesitter-textobjects", "windwp/nvim-ts-autotag"},
    config = function()
        ---@diagnostic disable: missing-fields
        require("nvim-treesitter.configs").setup({
            ensure_installed = {"html", "css", "scss", "json", "yaml", "xml", "dockerfile", "toml", "gitignore", "tmux",

                                "markdown", "markdown_inline", "lua", "vim", "bash", "c_sharp", "c", "go", "rust",
                                "java", "python", "sql", "javascript", "typescript", "tsx", "graphql", "prisma",
                                "jsdoc", "ssh_config", "regex"},
            sync_install = false,
            highlight = {
                enable = true
            },
            indent = {
                enable = true
            },
            autopairs = {
                enable = true
            },
            autotag = {
                enable = true
            },
            --[[ context_commentstring = {
					enable = true,
					enable_autocmd = false,
				}, ]]
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<c-space>",
                    node_incremental = "<c-space>",
                    scope_incremental = "<c-s>",
                    node_decremental = "<c-backspace>"
                }
            },
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
                    keymaps = {
                        -- You can use the capture groups defined in textobjects.scm
                        ["aa"] = "@parameter.outer",
                        ["ia"] = "@parameter.inner",
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",
                        ["ac"] = "@class.outer",
                        ["ic"] = "@class.inner"
                    }
                },
                move = {
                    enable = true,
                    set_jumps = true, -- whether to set jumps in the jumplist
                    goto_next_start = {
                        ["]m"] = "@function.outer",
                        ["]]"] = "@class.outer"
                    },
                    goto_next_end = {
                        ["]M"] = "@function.outer",
                        ["]["] = "@class.outer"
                    },
                    goto_previous_start = {
                        ["[m"] = "@function.outer",
                        ["[["] = "@class.outer"
                    },
                    goto_previous_end = {
                        ["[M"] = "@function.outer",
                        ["[]"] = "@class.outer"
                    }
                }
            }
        })
    end
}, -- Show context of the current function
{
    "nvim-treesitter/nvim-treesitter-context",
    event = "LazyFile",
    enabled = true,
    opts = {
        mode = "cursor",
        max_lines = 3
    },
    keys = {{
        "<leader>ut",
        function()
            local Utils = require("utils")
            local tsc = require("treesitter-context")
            tsc.toggle()
            if Utils.inject.get_upvalue(tsc.toggle, "enabled") then
                Utils.info("Enabled Treesitter Context", {
                    title = "Option"
                })
            else
                Utils.warn("Disabled Treesitter Context", {
                    title = "Option"
                })
            end
        end,
        desc = "Toggle Treesitter Context"
    }}
}, -- Automatically add closing tags for HTML and JSX
{
    "windwp/nvim-ts-autotag",
    event = "LazyFile",
    opts = {}
}}
