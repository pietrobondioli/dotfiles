local Utils = require("utils")

---@class utils.lsp
local M = {}

---@alias lsp.Client.filter {id?: number, bufnr?: number, name?: string, method?: string, filter?:fun(client: lsp.Client):boolean}

-- Function to get LSP clients based on provided options
-- If no options are provided, it returns all active LSP clients
-- If options are provided, it filters the clients based on the options
---@param opts? lsp.Client.filter
function M.get_clients(opts)
    local ret = {} ---@type lsp.Client[]
    if vim.lsp.get_clients then
        ret = vim.lsp.get_clients(opts)
    else
        ---@diagnostic disable-next-line: deprecated
        ret = vim.lsp.get_active_clients(opts)
        if opts and opts.method then
            ---@param client lsp.Client
            ret = vim.tbl_filter(function(client)
                return client.supports_method(opts.method, {bufnr = opts.bufnr})
            end, ret)
        end
    end
    return opts and opts.filter and vim.tbl_filter(opts.filter, ret) or ret
end

-- Function to create an autocommand that triggers on the LspAttach event
-- The callback function is called with the client and buffer as arguments
---@param on_attach fun(client, buffer)
function M.on_attach(on_attach)
    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
            local buffer = args.buf ---@type number
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            on_attach(client, buffer)
        end
    })
end

-- Function to handle the rename event in LSP
-- It sends a request to all LSP clients that support the "workspace/willRenameFiles" method
-- The request contains the old and new file names
-- If a client responds with a workspace edit, it applies the edit
---@param from string
---@param to string
function M.on_rename(from, to)
    local clients = M.get_clients()
    for _, client in ipairs(clients) do
        if client.supports_method("workspace/willRenameFiles") then
            ---@diagnostic disable-next-line: invisible
            local resp = client.request_sync("workspace/willRenameFiles", {
                files = {
                    {
                        oldUri = vim.uri_from_fname(from),
                        newUri = vim.uri_from_fname(to)
                    }
                }
            }, 1000, 0)
            if resp and resp.result ~= nil then
                vim.lsp.util.apply_workspace_edit(resp.result,
                                                  client.offset_encoding)
            end
        end
    end
end

-- Function to get the configuration options for a specific LSP server
-- It returns the options from the lspconfig module
---@return _.lspconfig.options
function M.get_config(server)
    local configs = require("lspconfig.configs")
    return rawget(configs, server)
end

-- Function to disable a specific LSP server based on a condition
-- The condition is a function that takes the root directory and configuration as arguments
-- If the condition returns true, the server is disabled
---@param server string
---@param cond fun( root_dir, config): boolean
function M.disable(server, cond)
    local util = require("lspconfig.util")
    local def = M.get_config(server)
    ---@diagnostic disable-next-line: undefined-field
    def.document_config.on_new_config = util.add_hook_before(
                                            def.document_config.on_new_config,
                                            function(config, root_dir)
            if cond(root_dir, config) then config.enabled = false end
        end)
end

-- Function to create a formatter for LSP
-- The formatter can be filtered by client name or other client properties
-- The format function sends a format request to all LSP clients that match the filter
-- The sources function returns the names of all LSP clients that match the filter and support formatting
---@param opts? LazyFormatter| {filter?: (string|lsp.Client.filter)}
function M.formatter(opts)
    opts = opts or {}
    local filter = opts.filter or {}
    filter = type(filter) == "string" and {name = filter} or filter
    ---@cast filter lsp.Client.filter
    ---@type LazyFormatter
    local ret = {
        name = "LSP",
        primary = true,
        priority = 1,
        format = function(buf)
            M.format(Utils.merge(filter, {bufnr = buf}))
        end,
        sources = function(buf)
            local clients = M.get_clients(Utils.merge(filter, {bufnr = buf}))
            ---@param client lsp.Client
            local ret = vim.tbl_filter(function(client)
                return client.supports_method("textDocument/formatting") or
                           client.supports_method("textDocument/rangeFormatting")
            end, clients)
            ---@param client lsp.Client
            return vim.tbl_map(function(client) return client.name end, ret)
        end
    }
    return Utils.merge(ret, opts) --[[@as LazyFormatter]]
end

---@alias lsp.Client.format {timeout_ms?: number, format_options?: table} | lsp.Client.filter

-- Function to format a document using LSP
-- It sends a format request to the LSP server
-- If the conform module is available, it uses it for formatting because it has better format diffing
-- Otherwise, it uses the built-in LSP formatting
---@param opts? lsp.Client.format
function M.format(opts)
    opts = vim.tbl_deep_extend("force", {}, opts or {}, require("utils").opts(
                                   "nvim-lspconfig").format or {})
    local ok, conform = pcall(require, "conform")
    -- use conform for formatting with LSP when available,
    -- since it has better format diffing
    if ok then
        opts.formatters = {}
        opts.lsp_fallback = true
        conform.format(opts)
    else
        vim.lsp.buf.format(opts)
    end
end

return M
