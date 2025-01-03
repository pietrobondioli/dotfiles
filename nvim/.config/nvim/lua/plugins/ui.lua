return {
  {
    "petertriho/nvim-scrollbar",
    config = function()
      require("scrollbar").setup({
        handle = {
          blend = 0,
        },
      })
      vim.keymap.set("n", "<leader>u|", "<cmd>ScrollbarToggle<cr>", { desc = "Toggle scrollbar" })
    end,
  },

  -- {
  --   "folke/snacks.nvim",
  --   opts = {
  --     terminal = {
  --       win = {
  --         position = "float",
  --       },
  --     },
  --   },
  -- },
}
