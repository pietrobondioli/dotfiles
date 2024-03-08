return {
  "ThePrimeagen/harpoon",
  keys = {
    { "<leader>h", false },
    { "<leader>H", false },
    {
      "<leader>.",
      function()
        local harpoon = require("harpoon")
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end,
      desc = "Harpoon quick menu",
    },
    {
      "<leader>h",
      function()
        require("harpoon"):list():append()
      end,
      desc = "Harpoon file",
    },
  },
}
