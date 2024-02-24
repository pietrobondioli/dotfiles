return {
    {
        "catppuccin/nvim",
        config = function()
            require("catppuccin").setup({
                integrations = {
                    cmp = true,
                    gitsigns = true,
                    harpoon = true,
                    illuminate = true,
                    indent_blankline = {
                        enabled = false,
                        scope_color = "sapphire",
                        colored_indent_levels = false
                    },
                    mason = true,
                    native_lsp = {enabled = true},
                    notify = true,
                    nvimtree = true,
                    neotree = true,
                    symbols_outline = true,
                    telescope = true,
                    treesitter = true,
                    treesitter_context = true
                }
            })

            -- Hide all semantic highlights until upstream issues are resolved (https://github.com/catppuccin/nvim/issues/480)
            for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
                vim.api.nvim_set_hl(0, group, {})
            end
        end
    }, {"folke/tokyonight.nvim", opts = {style = "storm"}},
    {"joshdick/onedark.vim"}
    -- {"shaunsingh/nord.nvim", lazy = false},
    -- {"sainnhe/everforest", lazy = false},
    -- {"sainnhe/gruvbox-material", lazy = false},
    -- {"sainnhe/sonokai", lazy = false}, {"sainnhe/edge", lazy = false}
}
