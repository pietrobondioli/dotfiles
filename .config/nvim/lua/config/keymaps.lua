local Util = require("lazyvim.util")
local map = Util.safe_keymap_set

-- Shortcuts

-- Press 'Ctrl + a + a' to select all
map("n", "<C-a>", "ggVG", { desc = "Select all" })

-- Press 'leader + .' toggle harpoon menu
map("n", "<leader>.", function()
  local harpoon = require("harpoon")
  harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Toggle harpoon menu" })
