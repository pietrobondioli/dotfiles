local Utils = require("utils")

return {
    {
        "neovim/nvim-lspconfig",
        event = {"BufReadPost"},
        cmd = {"LspInfo", "LspInstall", "LspUninstall", "Mason"},
        dependencies = {
            {
                "folke/neoconf.nvim",
                cmd = "Neoconf",
                config = false,
                dependencies = {"nvim-lspconfig"}
            }, {"folke/neodev.nvim", opts = {}}, "mason.nvim",
            "williamboman/mason-lspconfig.nvim"
        },
        ---@class PluginLspOpts
        opts = {
            -- options for vim.diagnostic.config()
            diagnostics = {
                underline = true,
                update_in_insert = false,
                virtual_text = {
                    spacing = 4,
                    source = "if_many",
                    prefix = "●"
                    -- this will set set the prefix to a function that returns the diagnostics icon based on the severity
                    -- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
                    -- prefix = "icons",
                },
                severity_sort = true,
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = require(
                            "config.defaults").icons.diagnostics.Error,
                        [vim.diagnostic.severity.WARN] = require(
                            "config.defaults").icons.diagnostics.Warn,
                        [vim.diagnostic.severity.HINT] = require(
                            "config.defaults").icons.diagnostics.Hint,
                        [vim.diagnostic.severity.INFO] = require(
                            "config.defaults").icons.diagnostics.Info
                    }
                }
            },
            -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
            -- Be aware that you also will need to properly configure your LSP server to
            -- provide the inlay hints.
            inlay_hints = {enabled = false},
            -- add any global capabilities here
            capabilities = {},
            -- options for vim.lsp.buf.format
            -- `bufnr` and `filter` is handled by the LazyVim formatter,
            -- but can be also overridden when specified
            format = {formatting_options = nil, timeout_ms = nil},
            -- LSP Server Settings
            ---@type lspconfig.options
            servers = {
                lua_ls = {
                    -- mason = false, -- set to false if you don't want this server to be installed with mason
                    -- Use this to add any additional keymaps
                    -- for specific lsp servers
                    ---@type LazyKeysSpec[]
                    -- keys = {},
                    settings = {
                        Lua = {
                            workspace = {checkThirdParty = false},
                            completion = {callSnippet = "Replace"}
                        }
                    }
                }
            },
            setup = {
                -- example to setup with typescript.nvim
                -- tsserver = function(_, opts)
                --   require("typescript").setup({ server = opts })
                --   return true
                -- end,
                -- Specify * to use this function as a fallback for any server
                -- ["*"] = function(server, opts) end,
            },
            ensure_installed = {},
            highlight = {disable = {}},
            sorting = {comparators = {}}
        },
        config = function(_, opts)
            if Utils.has("neoconf.nvim") then
                local plugin =
                    require("lazy.core.config").spec.plugins["neoconf.nvim"]
                require("neoconf").setup(
                    require("lazy.core.plugin").values(plugin, "opts", false))
            end

            -- setup autoformat
            Utils.format.register(Utils.lsp.formatter())

            -- deprecated options
            if opts.autoformat ~= nil then
                vim.g.autoformat = opts.autoformat
                Utils.deprecate("nvim-lspconfig.opts.autoformat",
                                "vim.g.autoformat")
            end

            -- setup keymaps
            Utils.lsp.on_attach(function(client, buffer)
                require("plugins.lsp.keymaps").on_attach(client, buffer)
            end)

            local register_capability =
                vim.lsp.handlers["client/registerCapability"]

            vim.lsp.handlers["client/registerCapability"] = function(err, res,
                                                                     ctx)
                local ret = register_capability(err, res, ctx)
                local client_id = ctx.client_id
                ---@type lsp.Client
                local client = vim.lsp.get_client_by_id(client_id)
                local buffer = vim.api.nvim_get_current_buf()
                require("plugins.lsp.keymaps").on_attach(client, buffer)
                return ret
            end

            -- diagnostics
            for name, icon in
                pairs(require("config.defaults").icons.diagnostics) do
                name = "DiagnosticSign" .. name
                vim.fn.sign_define(name,
                                   {text = icon, texthl = name, numhl = ""})
            end

            if opts.inlay_hints.enabled then
                Utils.lsp.on_attach(function(client, buffer)
                    if client.supports_method("textDocument/inlayHint") then
                        Utils.toggle.inlay_hints(buffer, true)
                    end
                end)
            end

            if type(opts.diagnostics.virtual_text) == "table" and
                opts.diagnostics.virtual_text.prefix == "icons" then
                opts.diagnostics.virtual_text.prefix =
                    vim.fn.has("nvim-0.10.0") == 0 and "●" or
                        function(diagnostic)
                            local icons =
                                require("config.defaults").icons.diagnostics
                            for d, icon in pairs(icons) do
                                if diagnostic.severity ==
                                    vim.diagnostic.severity[d:upper()] then
                                    return icon
                                end
                            end
                        end
            end

            vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

            local servers = opts.servers
            local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
            local capabilities = vim.tbl_deep_extend("force", {}, vim.lsp
                                                         .protocol
                                                         .make_client_capabilities(),
                                                     has_cmp and
                                                         cmp_nvim_lsp.default_capabilities() or
                                                         {},
                                                     opts.capabilities or {})

            local function setup(server)
                local server_opts = vim.tbl_deep_extend("force", {
                    capabilities = vim.deepcopy(capabilities)
                }, servers[server] or {})

                if opts.setup[server] then
                    if opts.setup[server](server, server_opts) then
                        return
                    end
                elseif opts.setup["*"] then
                    if opts.setup["*"](server, server_opts) then
                        return
                    end
                end
                require("lspconfig")[server].setup(server_opts)
            end

            -- get all the servers that are available through mason-lspconfig
            local have_mason, mlsp = pcall(require, "mason-lspconfig")
            local all_mslp_servers = {}
            if have_mason then
                all_mslp_servers = vim.tbl_keys(require(
                                                    "mason-lspconfig.mappings.server").lspconfig_to_package)
            end

            local ensure_installed = {} ---@type string[]
            for server, server_opts in pairs(servers) do
                if server_opts then
                    server_opts = server_opts == true and {} or server_opts
                    -- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
                    if server_opts.mason == false or
                        not vim.tbl_contains(all_mslp_servers, server) then
                        setup(server)
                    else
                        ensure_installed[#ensure_installed + 1] = server
                    end
                end
            end

            if have_mason then
                mlsp.setup({
                    ensure_installed = ensure_installed,
                    handlers = {setup}
                })
            end

            if Utils.lsp.get_config("denols") and
                Utils.lsp.get_config("tsserver") then
                local is_deno = require("lspconfig.util").root_pattern(
                                    "deno.json", "deno.jsonc")
                Utils.lsp.disable("tsserver", is_deno)
                Utils.lsp.disable("denols", function(root_dir)
                    return not is_deno(root_dir)
                end)
            end
        end
    }, {

        "williamboman/mason.nvim",
        cmd = {"Mason", "MasonInstall", "MasonUpdate"},
        keys = {{"<leader>cm", "<cmd>Mason<cr>", desc = "Mason"}},
        build = ":MasonUpdate",
        opts = {
            ensure_installed = {
                "stylua", "shfmt"
                -- "flake8",
            }
        },
        ---@param opts MasonSettings | {ensure_installed: string[]}
        config = function(_, opts)
            require("mason").setup(opts)

            local mr = require("mason-registry")
            mr:on("package:install:success", function()
                vim.defer_fn(function()
                    -- trigger FileType event to possibly load this newly installed LSP server
                    require("lazy.core.handler.event").trigger({
                        event = "FileType",
                        buf = vim.api.nvim_get_current_buf()
                    })
                end, 100)
            end)
            local function ensure_installed()
                for _, tool in ipairs(opts.ensure_installed) do
                    local p = mr.get_package(tool)
                    if not p:is_installed() then p:install() end
                end
            end
            if mr.refresh then
                mr.refresh(ensure_installed)
            else
                ensure_installed()
            end
        end
    }
}
