local Utils = require("utils")

---@class utils.toggle
local M = {}

-- This function toggles a local option in Vim.
-- If 'values' is provided, it will toggle between those two values.
-- Otherwise, it will toggle between true and false.
-- If 'silent' is not true, it will display a message about the new state of the option.
---@param silent boolean?
---@param values? {[1]:any, [2]:any}
function M.option(option, silent, values)
    if values then
        if vim.opt_local[option]:get() == values[1] then
            ---@diagnostic disable-next-line: no-unknown
            vim.opt_local[option] = values[2]
        else
            ---@diagnostic disable-next-line: no-unknown
            vim.opt_local[option] = values[1]
        end
        return Utils.info("Set " .. option .. " to " ..
                              vim.opt_local[option]:get(), {title = "Option"})
    end
    ---@diagnostic disable-next-line: no-unknown
    vim.opt_local[option] = not vim.opt_local[option]:get()
    if not silent then
        if vim.opt_local[option]:get() then
            Utils.info("Enabled " .. option, {title = "Option"})
        else
            Utils.warn("Disabled " .. option, {title = "Option"})
        end
    end
end

-- This function toggles the 'number' and 'relativenumber' options in Vim.
-- It keeps track of the previous state of these options so it can restore them when toggling off.
local nu = {number = true, relativenumber = true}
function M.number()
    if vim.opt_local.number:get() or vim.opt_local.relativenumber:get() then
        nu = {
            number = vim.opt_local.number:get(),
            relativenumber = vim.opt_local.relativenumber:get()
        }
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        Utils.warn("Disabled line numbers", {title = "Option"})
    else
        vim.opt_local.number = nu.number
        vim.opt_local.relativenumber = nu.relativenumber
        Utils.info("Enabled line numbers", {title = "Option"})
    end
end

-- This function toggles the diagnostics in Vim.
-- It checks if the current version of Neovim supports checking if diagnostics are enabled.
-- If it does, it uses that to determine the current state of diagnostics.
-- Otherwise, it keeps track of the state itself.
local enabled = true
function M.diagnostics()
    -- if this Neovim version supports checking if diagnostics are enabled
    -- then use that for the current state
    if vim.diagnostic.is_disabled then
        enabled = not vim.diagnostic.is_disabled()
    end
    enabled = not enabled

    if enabled then
        vim.diagnostic.enable()
        Utils.info("Enabled diagnostics", {title = "Diagnostics"})
    else
        vim.diagnostic.disable()
        Utils.warn("Disabled diagnostics", {title = "Diagnostics"})
    end
end

-- This function toggles inlay hints in Vim.
-- It checks if the current version of Neovim supports inlay hints.
-- If it does, it uses that to toggle the inlay hints.
-- Otherwise, it does nothing.
---@param buf? number
---@param value? boolean
function M.inlay_hints(buf, value)
    local ih = vim.lsp.buf.inlay_hint or vim.lsp.inlay_hint
    if type(ih) == "function" then
        ih(buf, value)
    elseif type(ih) == "table" and ih.enable then
        if value == nil then value = not ih.is_enabled(buf) end
        ih.enable(buf, value)
    end
end

setmetatable(M, {__call = function(m, ...) return m.option(...) end})

return M
