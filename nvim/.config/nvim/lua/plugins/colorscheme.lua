return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    config = function()
      require("catppuccin").setup({
        integrations = {
          cmp = true,
          gitsigns = true,
          harpoon = true,
          illuminate = true,
          indent_blankline = {
            enabled = false,
            scope_color = "sapphire",
            colored_indent_levels = false,
          },
          mason = true,
          native_lsp = { enabled = true },
          notify = true,
          nvimtree = true,
          neotree = true,
          symbols_outline = true,
          telescope = true,
          treesitter = true,
          treesitter_context = true,
        },
      })

      -- Hide all semantic highlights until upstream issues are resolved (https://github.com/catppuccin/nvim/issues/480)
      for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
        vim.api.nvim_set_hl(0, group, {})
      end
    end,
  },

  {
    "folke/tokyonight.nvim",
    name = "tokyonight",
    lazy = true,
    opts = { style = "storm" },
  },

  { "sainnhe/everforest", name = "everforest", lazy = true },

  { "NLKNguyen/papercolor-theme", name = "papercolor", lazy = true },

  { "morhetz/gruvbox", name = "gruvbox", lazy = true },

  { "rose-pine/neovim", name = "rose-pine", lazy = true },

  { "rebelot/kanagawa.nvim", name = "kanagawa", lazy = true },

  { "navarasu/onedark.nvim", name = "onedark", lazy = true },
}
