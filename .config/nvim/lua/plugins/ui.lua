return {
    {
        "karb94/neoscroll.nvim",
        config = function() require('neoscroll').setup {} end
    }, {
        'nvimdev/dashboard-nvim',
        event = 'VimEnter',
        dependencies = {{'nvim-tree/nvim-web-devicons'}},
        opts = function()
            local logo = [[
┬  ┌─┐┌─┐┌─┐  ┬┌─┐  ┌┬┐┌─┐┬─┐┌─┐
│  ├┤ └─┐└─┐  │└─┐  ││││ │├┬┘├┤
┴─┘└─┘└─┘└─┘  ┴└─┘  ┴ ┴└─┘┴└─└─┘
            ]]

            logo = string.rep("\n", 8) .. logo .. "\n\n"

            local opts = {
                theme = "doom",
                hide = {
                    -- this is taken care of by lualine
                    -- enabling this messes up the actual laststatus setting after loading a file
                    statusline = true
                },
                config = {
                    header = vim.split(logo, "\n"),
                    -- stylua: ignore
                    center = {
                        {
                            action = "Telescope find_files",
                            desc = " Find file",
                            icon = " ",
                            key = "f"
                        },
                        {
                            action = "ene | startinsert",
                            desc = " New file",
                            icon = " ",
                            key = "n"
                        }, {
                            action = "Telescope oldfiles",
                            desc = " Recent files",
                            icon = " ",
                            key = "r"
                        },
                        {
                            action = "Telescope live_grep",
                            desc = " Find text",
                            icon = " ",
                            key = "g"
                        }, {
                            action = [[lua require("utils").telescope.config_files()()]],
                            desc = " Config",
                            icon = " ",
                            key = "c"
                        }, {
                            action = 'lua require("persistence").load()',
                            desc = " Restore Session",
                            icon = " ",
                            key = "s"
                        },
                        {
                            action = "LazyExtras",
                            desc = " Lazy Extras",
                            icon = " ",
                            key = "x"
                        },
                        {
                            action = "Lazy",
                            desc = " Lazy",
                            icon = "󰒲 ",
                            key = "l"
                        },
                        {
                            action = "qa",
                            desc = " Quit",
                            icon = " ",
                            key = "q"
                        }
                    },
                    footer = function()
                        local stats = require("lazy").stats()
                        local ms = (math.floor(stats.startuptime * 100 + 0.5) /
                                       100)
                        return {
                            "⚡ Neovim loaded " .. stats.loaded .. "/" ..
                                stats.count .. " plugins in " .. ms .. "ms"
                        }
                    end
                }
            }

            for _, button in ipairs(opts.config.center) do
                button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
                button.key_format = "  %s"
            end

            -- close Lazy and re-open when the dashboard is ready
            if vim.o.filetype == "lazy" then
                vim.cmd.close()
                vim.api.nvim_create_autocmd("User", {
                    pattern = "DashboardLoaded",
                    callback = function()
                        require("lazy").show()
                    end
                })
            end

            return opts
        end
    }, {
        "nvim-lualine/lualine.nvim",
        init = function()
            vim.g.lualine_laststatus = vim.o.laststatus
            if vim.fn.argc(-1) > 0 then
                -- set an empty statusline till lualine loads
                vim.o.statusline = " "
            else
                -- hide the statusline on the starter page
                vim.o.laststatus = 0
            end
        end,
        opts = function(_, opts)
            -- PERF: we don't need this lualine require madness 🤷
            local lualine_require = require("lualine_require")
            lualine_require.require = require

            local icons = require("config.defaults").icons

            vim.o.laststatus = vim.g.lualine_laststatus

            local Utils = require("utils")
            local colors = {
                [""] = Utils.ui.fg("Special"),
                ["Normal"] = Utils.ui.fg("Special"),
                ["Warning"] = Utils.ui.fg("DiagnosticError"),
                ["InProgress"] = Utils.ui.fg("DiagnosticWarn")
            }

            return {
                options = {
                    theme = "auto",
                    globalstatus = true,
                    disabled_filetypes = {
                        statusline = {"dashboard", "alpha", "starter"}
                    }
                },
                sections = {
                    lualine_a = {"mode"},
                    lualine_b = {"branch"},
                    lualine_c = {
                        Utils.lualine.root_dir(), {
                            "diagnostics",
                            symbols = {
                                error = icons.diagnostics.Error,
                                warn = icons.diagnostics.Warn,
                                info = icons.diagnostics.Info,
                                hint = icons.diagnostics.Hint
                            }
                        },
                        {
                            "filetype",
                            icon_only = true,
                            separator = "",
                            padding = {left = 1, right = 0}
                        }, {Utils.lualine.pretty_path()}
                    },
                    lualine_x = { -- stylua: ignore
                        {
                            function()
                                return require("noice").api.status.command.get()
                            end,
                            cond = function()
                                return package.loaded["noice"] and
                                           require("noice").api.status.command
                                               .has()
                            end,
                            color = Utils.ui.fg("Statement")
                        }, -- stylua: ignore
                        {
                            function()
                                local icon =
                                    require("config.defaults").icons.kinds
                                        .Copilot
                                local status =
                                    require("copilot.api").status.data
                                return icon .. (status.message or "")
                            end,
                            cond = function()
                                if not package.loaded["copilot"] then
                                    return
                                end
                                local ok, clients = pcall(
                                                        require("utils").lsp
                                                            .get_clients, {
                                        name = "copilot",
                                        bufnr = 0
                                    })
                                if not ok then
                                    return false
                                end
                                return ok and #clients > 0
                            end,
                            color = function()
                                if not package.loaded["copilot"] then
                                    return
                                end
                                local status =
                                    require("copilot.api").status.data
                                return colors[status.status] or colors[""]
                            end
                        }, {
                            function()
                                return require("noice").api.status.mode.get()
                            end,
                            cond = function()
                                return package.loaded["noice"] and
                                           require("noice").api.status.mode
                                               .has()
                            end,
                            color = Utils.ui.fg("Constant")
                        }, -- stylua: ignore
                        {
                            function()
                                return "  " .. require("dap").status()
                            end,
                            cond = function()
                                return package.loaded["dap"] and
                                           require("dap").status() ~= ""
                            end,
                            color = Utils.ui.fg("Debug")
                        }, {
                            require("lazy.status").updates,
                            cond = require("lazy.status").has_updates,
                            color = Utils.ui.fg("Special")
                        }, {
                            "diff",
                            symbols = {
                                added = icons.git.added,
                                modified = icons.git.modified,
                                removed = icons.git.removed
                            },
                            source = function()
                                local gitsigns = vim.b.gitsigns_status_dict
                                if gitsigns then
                                    return {
                                        added = gitsigns.added,
                                        modified = gitsigns.changed,
                                        removed = gitsigns.removed
                                    }
                                end
                            end
                        }
                    },
                    lualine_y = {
                        {
                            "progress",
                            separator = " ",
                            padding = {left = 1, right = 0}
                        }, {"location", padding = {left = 0, right = 1}}
                    },
                    lualine_z = {function()
                        return " " .. os.date("%R")
                    end}
                },
                extensions = {"neo-tree", "lazy"}
            }
        end
    }, -- better vim.ui
    {
        "stevearc/dressing.nvim",
        lazy = true,
        init = function()
            ---@diagnostic disable-next-line: duplicate-set-field
            vim.ui.select = function(...)
                require("lazy").load({plugins = {"dressing.nvim"}})
                return vim.ui.select(...)
            end
            ---@diagnostic disable-next-line: duplicate-set-field
            vim.ui.input = function(...)
                require("lazy").load({plugins = {"dressing.nvim"}})
                return vim.ui.input(...)
            end
        end
    }, -- This is what powers LazyVim's fancy-looking
    -- tabs, which include filetype icons and close buttons.
    {
        "akinsho/bufferline.nvim",
        keys = {
            {"<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle pin"},
            {
                "<leader>bP",
                "<Cmd>BufferLineGroupClose ungrouped<CR>",
                desc = "Delete non-pinned buffers"
            },
            {
                "<leader>bo",
                "<Cmd>BufferLineCloseOthers<CR>",
                desc = "Delete other buffers"
            }, {
                "<leader>br",
                "<Cmd>BufferLineCloseRight<CR>",
                desc = "Delete buffers to the right"
            }, {
                "<leader>bl",
                "<Cmd>BufferLineCloseLeft<CR>",
                desc = "Delete buffers to the left"
            }, {"<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer"},
            {"<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer"},
            {"[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer"},
            {"]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer"}
        },
        opts = {
            options = {
                -- stylua: ignore
                close_command = function(n)
                    require("mini.bufremove").delete(n, false)
                end,
                -- stylua: ignore
                right_mouse_command = function(n)
                    require("mini.bufremove").delete(n, false)
                end,
                diagnostics = "nvim_lsp",
                always_show_bufferline = true,
                diagnostics_indicator = function(_, _, diag)
                    local icons = require("config.defaults").icons.diagnostics
                    local ret =
                        (diag.error and icons.Error .. diag.error .. " " or "") ..
                            (diag.warning and icons.Warn .. diag.warning or "")
                    return vim.trim(ret)
                end,
                offsets = {
                    {
                        filetype = "neo-tree",
                        text = "Neo-tree",
                        highlight = "Directory",
                        text_align = "left"
                    }
                }
            }
        },
        config = function(_, opts)
            require("bufferline").setup(opts)
            -- Fix bufferline when restoring a session
            vim.api.nvim_create_autocmd("BufAdd", {
                callback = function()
                    vim.schedule(function()
                        pcall(nvim_bufferline)
                    end)
                end
            })
        end
    }, {
        "lukas-reineke/indent-blankline.nvim",
        event = "BufEnter",
        main = "ibl",
        config = function()
            require("ibl").setup({
                indent = {char = "│", tab_char = "│"},
                scope = {enabled = false},
                exclude = {
                    filetypes = {
                        "help", "alpha", "dashboard", "neo-tree", "Trouble",
                        "trouble", "lazy", "mason", "notify", "toggleterm",
                        "lazyterm"
                    }
                }
            })
        end
    }, {
        "rcarriga/nvim-notify",
        config = function()
            local notify = require("notify")

            local filtered_message = {"No information available"}

            -- Override notify function to filter out messages
            ---@diagnostic disable-next-line: duplicate-set-field
            vim.notify = function(message, level, opts)
                local merged_opts = vim.tbl_extend("force", {
                    on_open = function(win)
                        local buf = vim.api.nvim_win_get_buf(win)
                        vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
                    end
                }, opts or {})

                for _, msg in ipairs(filtered_message) do
                    if message == msg then return end
                end
                return notify(message, level, merged_opts)
            end

            -- Update colors to use catpuccino colors
            vim.cmd([[
        highlight NotifyERRORBorder guifg=#ed8796
        highlight NotifyERRORIcon guifg=#ed8796
        highlight NotifyERRORTitle  guifg=#ed8796
        highlight NotifyINFOBorder guifg=#8aadf4
        highlight NotifyINFOIcon guifg=#8aadf4
        highlight NotifyINFOTitle guifg=#8aadf4
        highlight NotifyWARNBorder guifg=#f5a97f
        highlight NotifyWARNIcon guifg=#f5a97f
        highlight NotifyWARNTitle guifg=#f5a97f
        ]])
        end
    }, {"folke/noice.nvim", dependencies = {"MunifTanjim/nui.nvim"}}, -- Active indent guide and indent text objects. When you're browsing
    -- code, this highlights the current level of indentation, and animates
    -- the highlighting.
    {
        "echasnovski/mini.indentscope",
        opts = {
            -- symbol = "▏",
            symbol = "│",
            options = {try_as_border = true}
        },
        init = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = {
                    "help", "alpha", "dashboard", "neo-tree", "Trouble",
                    "trouble", "lazy", "mason", "notify", "toggleterm",
                    "lazyterm"
                },
                callback = function()
                    vim.b.miniindentscope_disable = true
                end
            })
        end
    }
}
