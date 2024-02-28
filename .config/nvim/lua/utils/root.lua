local Utils = require("utils")

---@class utils.root
---@overload fun(): string
local M = setmetatable({}, {__call = function(m) return m.get() end})

---@class LazyRoot
---@field paths string[]
---@field spec LazyRootSpec

---@alias LazyRootFn fun(buf: number): (string|string[])

---@alias LazyRootSpec string|string[]|LazyRootFn

-- The spec field is a list of detectors that are used to find the root directory.
-- The detectors are used in the order they are listed in the spec field.
-- The default spec includes the "lsp" detector, a detector that looks for a ".git" directory or a "lua" directory, and the "cwd" detector.
---@type LazyRootSpec[]
M.spec = {"lsp", {".git", "lua"}, "cwd"}

-- The detectors field is a table that maps detector names to detector functions.
-- Each detector function takes a buffer number as an argument and returns a list of root directories.
M.detectors = {}

-- The "cwd" detector returns the current working directory as the root directory.
function M.detectors.cwd() return {vim.loop.cwd()} end

-- The "lsp" detector returns the workspace folders of the LSP clients as the root directories.
-- It only considers LSP clients that are attached to the given buffer and that are running in workspace mode (not in single file mode).
function M.detectors.lsp(buf)
    local bufpath = M.bufpath(buf)
    if not bufpath then return {} end
    local roots = {} ---@type string[]
    for _, client in pairs(Utils.lsp.get_clients({bufnr = buf})) do
        -- only check workspace folders, since we're not interested in clients
        -- running in single file mode
        local workspace = client.config.workspace_folders
        for _, ws in pairs(workspace or {}) do
            roots[#roots + 1] = vim.uri_to_fname(ws.uri)
        end
    end
    return vim.tbl_filter(function(path)
        path = Utils.norm(path)
        return path and bufpath:find(path, 1, true) == 1
    end, roots)
end

-- The "pattern" detector returns the directory that contains a file that matches one of the given patterns as the root directory.
-- It searches for the patterns in the directory of the given buffer and in its parent directories.
---@param patterns string[]|string
function M.detectors.pattern(buf, patterns)
    patterns = type(patterns) == "string" and {patterns} or patterns
    local path = M.bufpath(buf) or vim.loop.cwd()
    local pattern = vim.fs.find(patterns, {path = path, upward = true})[1]
    return pattern and {vim.fs.dirname(pattern)} or {}
end

-- The bufpath function returns the real path of the file of the given buffer.
function M.bufpath(buf) return
    M.realpath(vim.api.nvim_buf_get_name(assert(buf))) end

-- The cwd function returns the real path of the current working directory.
function M.cwd() return M.realpath(vim.loop.cwd()) or "" end

-- The realpath function returns the real path of the given path.
-- It resolves symbolic links and normalizes the path.
function M.realpath(path)
    if path == "" or path == nil then return nil end
    path = vim.loop.fs_realpath(path) or path
    return Utils.norm(path)
end

-- The resolve function returns a detector function for the given spec.
-- If the spec is a string, it returns the detector function with that name.
-- If the spec is a function, it returns the spec itself.
-- Otherwise, it returns a function that uses the "pattern" detector with the spec as the patterns.
---@param spec LazyRootSpec
---@return LazyRootFn
function M.resolve(spec)
    if M.detectors[spec] then
        return M.detectors[spec]
    elseif type(spec) == "function" then
        return spec
    end
    return function(buf) return M.detectors.pattern(buf, spec) end
end

-- The detect function returns a list of root directories based on the given options.
-- It uses the detectors listed in the spec option to find the root directories.
-- If the all option is false, it stops after finding the first root directory.
---@param opts? { buf?: number, spec?: LazyRootSpec[], all?: boolean }
function M.detect(opts)
    opts = opts or {}
    opts.spec = opts.spec or type(vim.g.root_spec) == "table" and
                    vim.g.root_spec or M.spec
    opts.buf = (opts.buf == nil or opts.buf == 0) and
                   vim.api.nvim_get_current_buf() or opts.buf

    local ret = {} ---@type LazyRoot[]
    for _, spec in ipairs(opts.spec) do
        local paths = M.resolve(spec)(opts.buf)
        paths = paths or {}
        paths = type(paths) == "table" and paths or {paths}
        local roots = {} ---@type string[]
        for _, p in ipairs(paths) do
            local pp = M.realpath(p)
            if pp and not vim.tbl_contains(roots, pp) then
                roots[#roots + 1] = pp
            end
        end
        table.sort(roots, function(a, b) return #a > #b end)
        if #roots > 0 then
            ret[#ret + 1] = {spec = spec, paths = roots}
            if opts.all == false then break end
        end
    end
    return ret
end

-- The info function displays information about the root directories in a floating window.
-- It shows the root directories for the current buffer and the spec used to find them.
function M.info()
    local spec = type(vim.g.root_spec) == "table" and vim.g.root_spec or M.spec

    local roots = M.detect({all = true})
    local lines = {} ---@type string[]
    local first = true
    for _, root in ipairs(roots) do
        for _, path in ipairs(root.paths) do
            lines[#lines + 1] = ("- [%s] `%s` **(%s)**"):format(
                                    first and "x" or " ", path,
                                    type(root.spec) == "table" and
                                        table.concat(root.spec, ", ") or
                                        root.spec)
            first = false
        end
    end
    lines[#lines + 1] = "```lua"
    lines[#lines + 1] = "vim.g.root_spec = " .. vim.inspect(spec)
    lines[#lines + 1] = "```"
    require("utils").info(lines, {title = "LazyVim Roots"})
    return roots[1] and roots[1].paths[1] or vim.loop.cwd()
end

---@type table<number, string>
M.cache = {}

-- The setup function creates a user command and an autocommand for the root module.
-- The user command shows information about the root directories.
-- The autocommand clears the cache of root directories when an LSP client is attached or a buffer is written.
function M.setup()
    vim.api.nvim_create_user_command("LazyRoot",
                                     function() Utils.root.info() end, {
        desc = "LazyVim roots for the current buffer"
    })

    vim.api.nvim_create_autocmd({"LspAttach", "BufWritePost"}, {
        group = vim.api
            .nvim_create_augroup("lazyvim_root_cache", {clear = true}),
        callback = function(event) M.cache[event.buf] = nil end
    })
end

-- The get function returns the root directory for the current buffer.
-- It uses the detectors listed in the spec field to find the root directory.
-- It caches the root directory for each buffer to improve performance.
---@param opts? {normalize?:boolean}
---@return string
function M.get(opts)
    local buf = vim.api.nvim_get_current_buf()
    local ret = M.cache[buf]
    if not ret then
        local roots = M.detect({all = false})
        ret = roots[1] and roots[1].paths[1] or vim.loop.cwd()
        M.cache[buf] = ret
    end
    if opts and opts.normalize then return ret end
    return Utils.is_win() and ret:gsub("/", "\\") or ret
end

return M
