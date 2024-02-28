local Utils = require("utils")

local M = {}

M.setup = function()
    require("config.options")
    require("config.lazy")
    vim.cmd.colorscheme("catppuccin-macchiato")
    require("config.usercmds")
    require("config.keymaps")
    M.init()
end

M.init = function()
    Utils.format.setup()
    Utils.root.setup()
end

return M
