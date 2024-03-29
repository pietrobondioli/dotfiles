---@class utils
---@field ui utils.ui
---@field lsp utils.lsp
---@field root utils.root
---@field telescope utils.telescope
---@field toggle utils.toggle
---@field format utils.format
---@field inject utils.inject
---@field lualine utils.lualine
local M = {}

setmetatable(M, {
    __index = function(t, k)
        local LazyUtil = require("lazy.core.util")

        if LazyUtil[k] then return LazyUtil[k] end

        t[k] = require("utils." .. k)
        return t[k]
    end
})

-- Function to check if the current operating system is Windows
function M.is_win() return vim.loop.os_uname().sysname:find("Windows") ~= nil end

-- Function to check if a specific plugin is present in the configuration
---@param plugin string
function M.has(plugin)
    return require("lazy.core.config").spec.plugins[plugin] ~= nil
end

-- Function to create an autocommand that triggers on the User event with the pattern "VeryLazy"
---@param fn fun()
function M.on_very_lazy(fn)
    vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function() fn() end
    })
end

-- Function to get the options for a specific plugin
---@param name string
function M.opts(name)
    local plugin = require("lazy.core.config").plugins[name]
    if not plugin then return {} end
    local Plugin = require("lazy.core.plugin")
    return Plugin.values(plugin, "opts", false)
end

-- Function to delay notifications until vim.notify was replaced or after 500ms
function M.lazy_notify()
    local notifs = {}
    local function temp(...) table.insert(notifs, vim.F.pack_len(...)) end

    local orig = vim.notify
    vim.notify = temp

    local timer = vim.loop.new_timer()
    local check = assert(vim.loop.new_check())

    local replay = function()
        timer:stop()
        check:stop()
        if vim.notify == temp then
            vim.notify = orig -- put back the original notify if needed
        end
        vim.schedule(function()
            ---@diagnostic disable-next-line: no-unknown
            for _, notif in ipairs(notifs) do
                vim.notify(vim.F.unpack_len(notif))
            end
        end)
    end

    -- wait till vim.notify has been replaced
    check:start(function() if vim.notify ~= temp then replay() end end)
    -- or if it took more than 500ms, then something went wrong
    timer:start(500, 0, replay)
end

-- Function to create an autocommand that triggers on the User event with the pattern "LazyLoad"
-- The callback function is only called if the event data matches the provided name
---@param name string
---@param fn fun(name:string)
function M.on_load(name, fn)
    local Config = require("lazy.core.config")
    if Config.plugins[name] and Config.plugins[name]._.loaded then
        fn(name)
    else
        vim.api.nvim_create_autocmd("User", {
            pattern = "LazyLoad",
            callback = function(event)
                if event.data == name then
                    fn(name)
                    return true
                end
            end
        })
    end
end

-- Function to safely set a keymap
-- Does not create a keymap if a lazy key handler exists
-- Sets `silent` to true by default
function M.safe_keymap_set(mode, lhs, rhs, opts)
    local keys = require("lazy.core.handler").handlers.keys
    ---@cast keys LazyKeysHandler
    local modes = type(mode) == "string" and {mode} or mode

    ---@param m string
    modes = vim.tbl_filter(function(m)
        return not (keys.have and keys:have(lhs, m))
    end, modes)

    -- do not create the keymap if a lazy keys handler exists
    if #modes > 0 then
        opts = opts or {}
        opts.silent = opts.silent ~= false
        if opts.remap and not vim.g.vscode then
            ---@diagnostic disable-next-line: no-unknown
            opts.remap = nil
        end
        vim.keymap.set(modes, lhs, rhs, opts)
    end
end

return M
