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

-- Navigate between buffers using <TAB> and <S-TAB>
map("n", "<TAB>", "<cmd>bn!<cr>", { desc = "Next buffer" })
map("n", "<S-TAB>", "<cmd>bp!<cr>", { desc = "Previous buffer" })

-- debug using functions keys, using same layout as vscode or goland
map("n", "<F1>", "<cmd>lua require'dapui'.toggle()<cr>", { desc = "DAP: Toggle UI" })
map("n", "<F2>", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", { desc = "DAP: Toggle Breakpoint" })
map("n", "<F4>", "<cmd>lua require'dap'.close()<cr>", { desc = "DAP: Stop" })
map("n", "<F5>", "<cmd>lua require'dap'.continue()<cr>", { desc = "DAP: Continue" })
map("n", "<F9>", "<cmd>lua require'dap'.run_to_cursor()<cr>", { desc = "DAP: Run to cursor" })
map("n", "<F10>", "<cmd>lua require'dap'.step_over()<cr>", { desc = "DAP: Step Over" })
map("n", "<F11>", "<cmd>lua require'dap'.step_into()<cr>", { desc = "DAP: Step Into" })
map("n", "<F12>", "<cmd>lua require'dap'.step_out()<cr>", { desc = "DAP: Step Out" })
