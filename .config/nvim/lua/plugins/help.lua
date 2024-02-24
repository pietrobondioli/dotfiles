return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            defaults = {
                ["<leader>d"] = "Debug",
                ["<leader>h"] = "Help",
                ["<leader>q"] = "Quit",
                ["<leader>w"] = "Windows",
                ["<leader>g"] = "Git",
                ["<leader><tab>"] = "Tabs",
                ["<leader>s"] = "Search",
                ["<leader>f"] = "Files",
                ["<leader>b"] = "Buffers",
                ["<leader>c"] = "Code",
                ["<leader>u"] = "Toggle",
                ["<leader>x"] = "Trouble"
            }
        },
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
        config = function(_, opts)
            local wk = require("which-key")
            wk.setup(opts)
            wk.register(opts.defaults)
        end
    },
    {
        "folke/neodev.nvim",
        opts = {library = {plugins = {"neotest"}, types = true}}
    }, {
        "gelguy/wilder.nvim",
        keys = {":", "/", "?"},
        dependencies = {"catppuccin/nvim"},
        config = function()
            local wilder = require("wilder")
            local macchiato = require("catppuccin.palettes").get_palette(
                                  "macchiato")

            -- Create a highlight group for the popup menu
            local text_highlight = wilder.make_hl("WilderText", {
                {a = 1}, {a = 1}, {foreground = macchiato.text}
            })
            local mauve_highlight = wilder.make_hl("WilderMauve", {
                {a = 1}, {a = 1}, {foreground = macchiato.mauve}
            })

            -- Enable wilder when pressing :, / or ?
            wilder.setup({modes = {":", "/", "?"}})

            -- Enable fuzzy matching for commands and buffers
            wilder.set_option("pipeline", {
                wilder.branch(wilder.cmdline_pipeline({fuzzy = 1}),
                              wilder.vim_search_pipeline({fuzzy = 1}))
            })

            wilder.set_option("renderer",
                              wilder.popupmenu_renderer(
                                  wilder.popupmenu_border_theme({
                    highlighter = wilder.basic_highlighter(),
                    highlights = {
                        default = text_highlight,
                        border = mauve_highlight,
                        accent = mauve_highlight
                    },
                    pumblend = 5,
                    min_width = "100%",
                    min_height = "25%",
                    max_height = "25%",
                    border = "rounded",
                    left = {" ", wilder.popupmenu_devicons()},
                    right = {" ", wilder.popupmenu_scrollbar()}
                })))
        end
    }
}
