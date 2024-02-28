local Utils = require("utils")

-- Define a new class `utils.format` with a metatable that allows it to be called like a function
---@class utils.format
---@overload fun(opts?: {force?:boolean})
local M = setmetatable({}, {__call = function(m, ...) return m.format(...) end})

---@class LazyFormatter
---@field name string
---@field primary? boolean
---@field format fun(bufnr:number)
---@field sources fun(bufnr:number):string[]
---@field priority number

M.formatters = {} ---@type LazyFormatter[]

-- Function to register a new formatter
-- Adds the formatter to the list and sorts the list by priority
---@param formatter LazyFormatter
function M.register(formatter)
    M.formatters[#M.formatters + 1] = formatter
    table.sort(M.formatters, function(a, b) return a.priority > b.priority end)
end

-- Function to format an expression
-- If the `conform.nvim` plugin is installed, use its formatexpr function
-- Otherwise, use the built-in LSP formatexpr function with a timeout of 3000ms
function M.formatexpr()
    if Utils.has("conform.nvim") then return require("conform").formatexpr() end
    return vim.lsp.formatexpr({timeout_ms = 3000})
end

-- Function to resolve a buffer to a list of formatters
-- If no buffer is provided, use the current buffer
-- For each formatter, determine whether it is active and what sources it has
-- A formatter is active if it has sources and either it is not the primary formatter or there is no primary formatter yet
---@param buf? number
---@return (LazyFormatter|{active:boolean,resolved:string[]})[]
function M.resolve(buf)
    buf = buf or vim.api.nvim_get_current_buf()
    local have_primary = false
    ---@param formatter LazyFormatter
    return vim.tbl_map(function(formatter)
        local sources = formatter.sources(buf)
        local active = #sources > 0 and
                           (not formatter.primary or not have_primary)
        have_primary = have_primary or (active and formatter.primary) or false
        return setmetatable({active = active, resolved = sources},
                            {__index = formatter})
    end, M.formatters)
end

-- Function to display information about the formatters for a buffer
-- If no buffer is provided, use the current buffer
-- Displays whether autoformatting is enabled globally and for the buffer, and which formatters are active and what sources they have
---@param buf? number
function M.info(buf)
    buf = buf or vim.api.nvim_get_current_buf()
    local gaf = vim.g.autoformat == nil or vim.g.autoformat
    local baf = vim.b[buf].autoformat
    local enabled = M.enabled(buf)
    local lines = {
        "# Status", ("- [%s] global **%s**"):format(gaf and "x" or " ", gaf and
                                                        "enabled" or "disabled"),
        ("- [%s] buffer **%s**"):format(enabled and "x" or " ", baf == nil and
                                            "inherit" or baf and "enabled" or
                                            "disabled")
    }
    local have = false
    for _, formatter in ipairs(M.resolve(buf)) do
        if #formatter.resolved > 0 then
            have = true
            lines[#lines + 1] = "\n# " .. formatter.name ..
                                    (formatter.active and " ***(active)***" or
                                        "")
            for _, line in ipairs(formatter.resolved) do
                lines[#lines + 1] = ("- [%s] **%s**"):format(
                                        formatter.active and "x" or " ", line)
            end
        end
    end
    if not have then
        lines[#lines + 1] = "\n***No formatters available for this buffer.***"
    end
    Util[enabled and "info" or "warn"](table.concat(lines, "\n"), {
        title = "LazyFormat (" .. (enabled and "enabled" or "disabled") .. ")"
    })
end

-- Function to check whether autoformatting is enabled for a buffer
-- If no buffer is provided, use the current buffer
-- If the buffer has a local value for autoformatting, use that
-- Otherwise, use the global value if set, or true by default
---@param buf? number
function M.enabled(buf)
    buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
    local gaf = vim.g.autoformat
    local baf = vim.b[buf].autoformat

    -- If the buffer has a local value, use that
    if baf ~= nil then return baf end

    -- Otherwise use the global value if set, or true by default
    return gaf == nil or gaf
end

-- Function to toggle autoformatting for a buffer or globally
-- If a buffer is provided, toggle autoformatting for that buffer
-- Otherwise, toggle global autoformatting and unset the buffer value
---@param buf? boolean
function M.toggle(buf)
    if buf then
        vim.b.autoformat = not M.enabled()
    else
        vim.g.autoformat = not M.enabled()
        vim.b.autoformat = nil
    end
    M.info()
end

-- Function to format a buffer
-- If no options are provided, use the current buffer and only format if autoformatting is enabled
-- If `force` is true, format regardless of whether autoformatting is enabled
-- If no formatters are active and `force` is true, display a warning
---@param opts? {force?:boolean, buf?:number}
function M.format(opts)
    opts = opts or {}
    local buf = opts.buf or vim.api.nvim_get_current_buf()
    if not ((opts and opts.force) or M.enabled(buf)) then return end

    local done = false
    for _, formatter in ipairs(M.resolve(buf)) do
        if formatter.active then
            done = true
            Utils.try(function() return formatter.format(buf) end,
                      {msg = "Formatter `" .. formatter.name .. "` failed"})
        end
    end

    if not done and opts and opts.force then
        Utils.warn("No formatter available", {title = "LazyVim"})
    end
end

function M.setup()
    -- Autoformat autocmd
    vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("LazyFormat", {}),
        callback = function(event) M.format({buf = event.buf}) end
    })

    -- Manual format
    vim.api.nvim_create_user_command("LazyFormat",
                                     function() M.format({force = true}) end,
                                     {desc = "Format selection or buffer"})

    -- Format info
    vim.api.nvim_create_user_command("LazyFormatInfo", function() M.info() end,
                                     {
        desc = "Show info about the formatters for the current buffer"
    })
end

return M
