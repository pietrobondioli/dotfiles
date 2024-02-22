local Utils = require("utils")

return {
    "neovim/nvim-lspconfig",
    event = {"BufReadPost"},
    cmd = {"LspInfo", "LspInstall", "LspUninstall", "Mason"},
    dependencies = { -- Plugin and UI to automatically install LSPs to stdpath
        "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        -- Install none-ls for diagnostics, code actions, and formatting
        "nvimtools/none-ls.nvim"

        -- Install neodev for better nvim configuration and plugin authoring via lsp configurations
        -- "folke/neodev.nvim", -- Progress/Status update for LSP
        -- {"j-hui/fidget.nvim", tag = "legacy"}, -- Extended LSP handlers
        -- "Hoffs/omnisharp-extended-lsp.nvim", --  teste abaixo
        -- {
        --     "folke/neoconf.nvim",
        --     cmd = "Neoconf",
        --     config = false,
        --     dependencies = {"nvim-lspconfig"}
        -- }, {"folke/neodev.nvim", opts = {}}, "mason.nvim",
        -- "williamboman/mason-lspconfig.nvim"
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
                    [vim.diagnostic.severity.ERROR] = require("config").icons
                        .diagnostics.Error,
                    [vim.diagnostic.severity.WARN] = require("config").icons
                        .diagnostics.Warn,
                    [vim.diagnostic.severity.HINT] = require("config").icons
                        .diagnostics.Hint,
                    [vim.diagnostic.severity.INFO] = require("config").icons
                        .diagnostics.Info
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
        }
    },
    config = function()
        local null_ls = require("null-ls")

        -- setup keymaps
        Utils.lsp.on_attach(function(client, buffer)
            require("plugins.lsp.keymaps").on_attach(client, buffer)
        end)

        local register_capability =
            vim.lsp.handlers["client/registerCapability"]

        vim.lsp.handlers["client/registerCapability"] =
            function(err, res, ctx)
                local ret = register_capability(err, res, ctx)
                local client_id = ctx.client_id
                ---@type lsp.Client
                local client = vim.lsp.get_client_by_id(client_id)
                local buffer = vim.api.nvim_get_current_buf()
                require("lazyvim.plugins.lsp.keymaps").on_attach(client, buffer)
                return ret
            end

        -- Use neodev to configure lua_ls in nvim directories - must load before lspconfig
        require("neodev").setup()

        -- Setup mason so it can manage 3rd party LSP servers
        require("mason").setup({ui = {border = "rounded"}})

        -- Configure mason to auto install servers
        require("mason-lspconfig").setup({
            ensure_installed = {
                "bashls", "cssls", "graphql", "html", "jsonls", "lua_ls",
                "marksman", "prismals", "pyright", "sqlls", "tailwindcss",
                "tsserver", "yamlls", "omnisharp", "angularls", "ansiblels",
                "dockerls", "docker_compose_language_service", "eslint",
                "gopls", "golangci_lint_ls", "rust_analyzer", "grammarly",
                "lemminx", "tflint", "ltex", "java_language_server", "htmx",
                "azure_pipelines_ls", "arduino_language_server", "ast_grep"
            },
            automatic_installation = true
        })

        -- Override tsserver diagnostics to filter out specific messages
        local messages_to_filter = {
            "This may be converted to an async function.",
            "'_Assertion' is declared but never used.",
            "'__Assertion' is declared but never used.",
            "The signature '(data: string): string' of 'atob' is deprecated.",
            "The signature '(data: string): string' of 'btoa' is deprecated."
        }

        local function tsserver_on_publish_diagnostics_override(_, result, ctx,
                                                                config)
            local filtered_diagnostics = {}

            for _, diagnostic in ipairs(result.diagnostics) do
                local found = false
                for _, message in ipairs(messages_to_filter) do
                    if diagnostic.message == message then
                        found = true
                        break
                    end
                end
                if not found then
                    table.insert(filtered_diagnostics, diagnostic)
                end
            end

            result.diagnostics = filtered_diagnostics

            vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
        end

        local pid = vim.fn.getpid()
        -- On linux/darwin if using a release build, otherwise under scripts/OmniSharp(.Core)(.cmd)
        local omnisharp_bin = "/usr/bin/omnisharp"

        -- LSP servers to install (see list here: https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers )
        local servers = {
            bashls = {}, -- Bash Language Server
            cssls = {}, -- CSS Language Server
            graphql = {}, -- GraphQL Language Server
            html = {}, -- HTML Language Server
            jsonls = {}, -- JSON Language Server
            lua_ls = {
                settings = {
                    Lua = {
                        workspace = {checkThirdParty = false},
                        telemetry = {enabled = false}
                    }
                }
            }, -- Lua Language Server
            marksman = {}, -- Markdown Language Server
            prismals = {}, -- Prisma Language Server
            pyright = {}, -- Python Language Server
            sqlls = {}, -- SQL Language Server
            tailwindcss = {
                -- filetypes = { "reason" },
            }, -- Tailwind CSS Language Server
            tsserver = {
                settings = {experimental = {enableProjectDiagnostics = true}},
                handlers = {
                    ["textDocument/publishDiagnostics"] = vim.lsp.with(
                        tsserver_on_publish_diagnostics_override, {})
                }
            }, -- TypeScript Language Server
            yamlls = {
                schemas = {
                    ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*"
                }
            }, -- YAML Language Server
            omnisharp = {
                cmd = {
                    omnisharp_bin, "--languageserver", "--hostPID",
                    tostring(pid)
                },
                handlers = {
                    ["textDocument/definition"] = require('omnisharp_extended').handler
                }
            }, -- C# Language Server
            angularls = {}, -- Angular Language Server
            ansiblels = {}, -- Ansible Language Server
            dockerls = {}, -- Docker Language Server
            docker_compose_language_service = {}, -- Docker Compose Language Server
            eslint = {
                on_attach = function(client, bufnr)
                    vim.api.nvim_create_autocmd("BufWritePre", {
                        buffer = bufnr,
                        command = "EslintFixAll"
                    })
                end
            }, -- ESLint language server
            gopls = {}, -- Go Language Server
            golangci_lint_ls = {}, -- GolangCI Lint Language Server
            rust_analyzer = {}, -- Rust Analyzer
            grammarly = {}, -- Grammarly Language Server
            lemminx = {}, -- Lemminx Language Server (XML, XSD, XSL, DTD)
            tflint = {}, -- TFLint Language Server (Terraform)
            ltex = {}, -- LaTeX Language Server
            java_language_server = {}, -- Java Language Server
            htmx = {}, -- HTMX Language Server,
            azure_pipelines_ls = {
                settings = {
                    yaml = {
                        schemas = {
                            ["https://raw.githubusercontent.com/microsoft/azure-pipelines-vscode/master/service-schema.json"] = {
                                "/azure-pipeline*.y*l", "/*.azure*",
                                "Azure-Pipelines/**/*.y*l", "Pipelines/*.y*l"
                            }
                        }
                    }
                }
            }, -- Azure Pipelines Language Server
            arduino_language_server = {}, -- Arduino Language Server
            ast_grep = {} -- AST Grep Language Server
        }

        -- Default handlers for LSP
        local default_handlers = {
            ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover,
                                                  {border = "rounded"}),
            ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers
                                                              .signature_help,
                                                          {border = "rounded"})
        }

        -- nvim-cmp supports additional completion capabilities
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        local default_capabilities =
            require("cmp_nvim_lsp").default_capabilities(capabilities)

        ---@diagnostic disable-next-line: unused-local
        local on_attach = function(_client, buffer_number)
            -- Pass the current buffer to map lsp keybinds
            map_lsp_keybinds(buffer_number)

            -- Create a command `:Format` local to the LSP buffer
            vim.api.nvim_buf_create_user_command(buffer_number, "Format",
                                                 function(_)
                vim.lsp.buf.format({
                    filter = function(format_client)
                        -- Use Prettier to format TS/JS if it's available
                        return format_client.name ~= "tsserver" or
                                   not null_ls.is_registered("prettier")
                    end
                })
            end, {desc = "LSP: Format current buffer with LSP"})

            -- if client.server_capabilities.codeLensProvider then
            -- 	vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave", "CursorHold" }, {
            -- 		buffer = buffer_number,
            -- 		callback = vim.lsp.codelens.refresh,
            -- 		desc = "LSP: Refresh code lens",
            -- 		group = vim.api.nvim_create_augroup("codelens", { clear = true }),
            -- 	})
            -- end
        end

        -- Iterate over our servers and set them up
        for name, config in pairs(servers) do
            require("lspconfig")[name].setup({
                capabilities = default_capabilities,
                filetypes = config.filetypes,
                handlers = vim.tbl_deep_extend("force", {}, default_handlers,
                                               config.handlers or {}),
                on_attach = on_attach,
                settings = config.settings
            })
        end

        -- Configure LSP linting, formatting, diagnostics, and code actions
        local formatting = null_ls.builtins.formatting
        local diagnostics = null_ls.builtins.diagnostics
        local code_actions = null_ls.builtins.code_actions

        null_ls.setup({
            border = "rounded",
            sources = { -- Formatting
                formatting.prettierd, -- JavaScript, TypeScript, CSS, etc.
                formatting.stylua, -- Lua
                formatting.black.with({extra_args = {"--fast"}}), -- Python
                -- Add more formatting tools as needed
                -- Diagnostics
                diagnostics.eslint_d.with({
                    condition = function(utils)
                        return utils.root_has_file({
                            ".eslintrc.js", ".eslintrc.cjs", ".eslintrc.json",
                            ".eslintrc"
                        })
                    end
                }), -- JavaScript, TypeScript
                diagnostics.flake8, -- Python
                diagnostics.hadolint, -- Dockerfiles
                diagnostics.ansiblelint, -- Ansible
                -- diagnostics
                -- code actions
                code_actions.eslint_d.with({
                    condition = function(utils)
                        return utils.root_has_file({
                            ".eslintrc.js", ".eslintrc.cjs", ".eslintrc.json",
                            ".eslintrc"
                        })
                    end
                })
            }
        })

        -- Configure borderd for LspInfo ui
        require("lspconfig.ui.windows").default_options.border = "rounded"

        -- Configure diagostics border
        vim.diagnostic.config({float = {border = "rounded"}})
    end
}
