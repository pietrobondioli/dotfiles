local Utils = require("utils")

---@class utils.lualine
local M = {}

-- Function to create a source for the cmp completion plugin
-- The source is represented by a table with three functions:
-- - The first function returns the icon for the source
-- - The second function (cond) checks if the source is available
-- - The third function (color) returns the color for the source based on its status
function M.cmp_source(name, icon)
    local started = false
    local function status()
        if not package.loaded["cmp"] then return end
        for _, s in ipairs(require("cmp").core.sources) do
            if s.name == name then
                if s.source:is_available() then
                    started = true
                else
                    return started and "error" or nil
                end
                if s.status == s.SourceStatus.FETCHING then
                    return "pending"
                end
                return "ok"
            end
        end
    end

    local colors = {
        ok = Utils.ui.fg("Special"),
        error = Utils.ui.fg("DiagnosticError"),
        pending = Utils.ui.fg("DiagnosticWarn")
    }

    return {
        function()
            return icon or
                       require("config.defaults").icons.kinds[name:sub(1, 1)
                           :upper() .. name:sub(2)]
        end,
        cond = function() return status() ~= nil end,
        color = function() return colors[status()] or colors.ok end
    }
end

-- Function to format a component of the lualine status line
-- It applies a highlight group to the text of the component
-- The highlight group is created if it doesn't exist yet
---@param component any
---@param text string
---@param hl_group? string
---@return string
function M.format(component, text, hl_group)
    if not hl_group then return text end
    ---@type table<string, string>
    component.hl_cache = component.hl_cache or {}
    local lualine_hl_group = component.hl_cache[hl_group]
    if not lualine_hl_group then
        local utils = require("lualine.utils.utils")
        lualine_hl_group = component:create_hl({
            fg = utils.extract_highlight_colors(hl_group, "fg")
        }, "LV_" .. hl_group)
        component.hl_cache[hl_group] = lualine_hl_group
    end
    return component:format_hl(lualine_hl_group) .. text ..
               component:get_default_hl()
end

-- Function to create a pretty path for the lualine status line
-- The path is relative to the current working directory or the root directory
-- The path is shortened if it has more than three parts
-- The last part of the path is highlighted if the buffer is modified
---@param opts? {relative: "cwd"|"root", modified_hl: string?}
function M.pretty_path(opts)
    opts = vim.tbl_extend("force", {relative = "cwd", modified_hl = "Constant"},
                          opts or {})

    return function(self)
        local path = vim.fn.expand("%:p") --[[@as string]]

        if path == "" then return "" end
        local root = Utils.root.get({normalize = true})
        local cwd = Utils.root.cwd()

        if opts.relative == "cwd" and path:find(cwd, 1, true) == 1 then
            path = path:sub(#cwd + 2)
        else
            path = path:sub(#root + 2)
        end

        local sep = package.config:sub(1, 1)
        local parts = vim.split(path, "[\\/]")
        if #parts > 3 then
            parts = {parts[1], "…", parts[#parts - 1], parts[#parts]}
        end

        if opts.modified_hl and vim.bo.modified then
            parts[#parts] = M.format(self, parts[#parts], opts.modified_hl)
        end

        return table.concat(parts, sep)
    end
end

-- Function to create a root directory component for the lualine status line
-- The component shows the name of the root directory
-- The root directory is the current working directory, a subdirectory of the current working directory, a parent directory of the current working directory, or another directory
-- The component is represented by a table with three functions:
-- - The first function returns the text for the component
-- - The second function (cond) checks if the root directory exists
-- - The third function (color) returns the color for the component
---@param opts? {cwd:false, subdirectory: true, parent: true, other: true, icon?:string}
function M.root_dir(opts)
    opts = vim.tbl_extend("force", {
        cwd = false,
        subdirectory = true,
        parent = true,
        other = true,
        icon = "󱉭 ",
        color = Utils.ui.fg("Special")
    }, opts or {})

    local function get()
        local cwd = Utils.root.cwd()
        local root = Utils.root.get({normalize = true})
        local name = vim.fs.basename(root)

        if root == cwd then
            -- root is cwd
            return opts.cwd and name
        elseif root:find(cwd, 1, true) == 1 then
            -- root is subdirectory of cwd
            return opts.subdirectory and name
        elseif cwd:find(root, 1, true) == 1 then
            -- root is parent directory of cwd
            return opts.parent and name
        else
            -- root and cwd are not related
            return opts.other and name
        end
    end

    return {
        function() return (opts.icon and opts.icon .. " ") .. get() end,
        cond = function() return type(get()) == "string" end,
        color = opts.color
    }
end

return M
