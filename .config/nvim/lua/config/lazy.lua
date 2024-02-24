-- Lazy install bootstrap snippet
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", "--branch=stable", -- latest stable release
        lazypath
    })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require("lazy").setup({
    {import = "plugins"}, {import = "plugins.extras.lang"},
    {import = "plugins.extras.coding"}, {import = "plugins.extras.formatting"},
    {import = "plugins.extras.linting"}
}, {change_detection = {enabled = true, notify = true}})
