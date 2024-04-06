local map = vim.keymap.set

-- Press 'H', 'L' to jump to start/end of a line (first/last char)
map("n", "H", "^", { desc = "Go to start of line" })
map("n", "L", "$", { desc = "Go to end of line" })

-- -----------------
-- Resize window using <ctrl> arrow keys --
-- -----------------

map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Press 'U' for redo
map("n", "U", "<C-r>", { desc = "Redo" })

-- Select all
map("n", "<C-a>", "ggVG", { desc = "Select all" })
