local Utils = require("utils")

---@class utils.telescope.opts
---@field cwd? string|boolean
---@field show_untracked? boolean

---@class utils.telescope
---@overload fun(builtin:string, opts?:utils.telescope.opts)
local M = setmetatable({},
                       {__call = function(m, ...) return m.telescope(...) end})

-- This function returns a function that calls telescope.
-- The 'cwd' option will default to the root directory found by the 'Utils.root()' function.
-- For the 'files' builtin, it will choose between 'git_files' or 'find_files' depending on the presence of a '.git' directory.
---@param builtin string
---@param opts? utils.telescope.opts
function M.telescope(builtin, opts)
    local params = {builtin = builtin, opts = opts}
    return function()
        builtin = params.builtin
        opts = params.opts
        opts = vim.tbl_deep_extend("force", {cwd = Utils.root()}, opts or {}) --[[@as utils.telescope.opts]]
        if builtin == "files" then
            if vim.loop.fs_stat((opts.cwd or vim.loop.cwd()) .. "/.git") then
                opts.show_untracked = true
                builtin = "git_files"
            else
                builtin = "find_files"
            end
        end
        if opts.cwd and opts.cwd ~= vim.loop.cwd() then
            ---@diagnostic disable-next-line: inject-field
            opts.attach_mappings = function(_, map)
                map("i", "<a-c>", function()
                    local action_state = require("telescope.actions.state")
                    local line = action_state.get_current_line()
                    M.telescope(params.builtin,
                                vim.tbl_deep_extend("force", {},
                                                    params.opts or {}, {
                        cwd = false,
                        default_text = line
                    }))()
                end)
                return true
            end
        end

        require("telescope.builtin")[builtin](opts)
    end
end

-- This function returns a function that calls telescope with the 'find_files' builtin and the 'cwd' option set to the user's config directory.
function M.config_files()
    return Utils.telescope("find_files", {cwd = vim.fn.stdpath("config")})
end

return M
