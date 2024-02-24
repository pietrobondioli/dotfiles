return {
    {
        "alexghergh/nvim-tmux-navigation",
        config = function()
            require("nvim-tmux-navigation").setup({disable_when_zoomed = true})
        end
    }, {"szw/vim-maximizer"}, -- library used by other plugins
    {"nvim-lua/plenary.nvim", lazy = true}
}
