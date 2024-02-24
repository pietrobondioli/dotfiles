-- Normal Mode Mappings
local Utils = require("utils")

local map = Utils.safe_keymap_set

-- better up/down
map({"n", "x"}, "j", "v:count == 0 ? 'gj' : 'j'", {expr = true, silent = true})
map({"n", "x"}, "<Down>", "v:count == 0 ? 'gj' : 'j'",
    {expr = true, silent = true})
map({"n", "x"}, "k", "v:count == 0 ? 'gk' : 'k'", {expr = true, silent = true})
map({"n", "x"}, "<Up>", "v:count == 0 ? 'gk' : 'k'",
    {expr = true, silent = true})

-- Press 'H', 'L' to jump to start/end of a line (first/last char)
map("n", "H", "^", {desc = "Go to start of line"})
map("n", "L", "$", {desc = "Go to end of line"})

-- Move to window using the <ctrl> hjkl keys

map("n", "<C-h>", "<Cmd>NvimTmuxNavigateLeft<CR>",
    {desc = "Go to left window", remap = true})
map("n", "<C-j>", "<Cmd>NvimTmuxNavigateDown<CR>",
    {desc = "Go to lower window", remap = true})
map("n", "<C-k>", "<Cmd>NvimTmuxNavigateUp<CR>",
    {desc = "Go to upper window", remap = true})
map("n", "<C-l>", "<Cmd>NvimTmuxNavigateRight<CR>",
    {desc = "Go to right window", remap = true})

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", {desc = "Increase window height"})
map("n", "<C-Down>", "<cmd>resize -2<cr>", {desc = "Decrease window height"})
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>",
    {desc = "Decrease window width"})
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>",
    {desc = "Increase window width"})

-- Move Lines
map("n", "<A-j>", "<cmd>m .+1<cr>==", {desc = "Move down"})
map("n", "<A-k>", "<cmd>m .-2<cr>==", {desc = "Move up"})
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", {desc = "Move down"})
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", {desc = "Move up"})
map("v", "<A-j>", ":m '>+1<cr>gv=gv", {desc = "Move down"})
map("v", "<A-k>", ":m '<-2<cr>gv=gv", {desc = "Move up"})

-- buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", {desc = "Prev buffer"})
map("n", "<S-l>", "<cmd>bnext<cr>", {desc = "Next buffer"})
map("n", "[b", "<cmd>bprevious<cr>", {desc = "Prev buffer"})
map("n", "]b", "<cmd>bnext<cr>", {desc = "Next buffer"})
map("n", "<leader>bb", "<cmd>e #<cr>", {desc = "Switch to Other Buffer"})
map("n", "<leader>`", "<cmd>e #<cr>", {desc = "Switch to Other Buffer"})

-- Clear search with <esc>
map({"i", "n"}, "<esc>", "<cmd>noh<cr><esc>",
    {desc = "Escape and clear hlsearch"})

-- Clear search, diff update and redraw
-- taken from runtime/lua/_editor.lua
map("n", "<leader>ur", "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
    {desc = "Redraw / clear hlsearch / diff update"})

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward].'zv'",
    {expr = true, desc = "Next search result"})
map("x", "n", "'Nn'[v:searchforward]",
    {expr = true, desc = "Next search result"})
map("o", "n", "'Nn'[v:searchforward]",
    {expr = true, desc = "Next search result"})
map("n", "N", "'nN'[v:searchforward].'zv'",
    {expr = true, desc = "Prev search result"})
map("x", "N", "'nN'[v:searchforward]",
    {expr = true, desc = "Prev search result"})
map("o", "N", "'nN'[v:searchforward]",
    {expr = true, desc = "Prev search result"})

-- Add undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- save file
map({"i", "x", "n", "s"}, "<C-s>", "<cmd>w<cr><esc>", {desc = "Save file"})
-- Save and Quit with leader key
map("n", "<leader>z", "<cmd>wq<cr>", {silent = false, desc = "Save and Quit"})

-- keywordprg
map("n", "<leader>K", "<cmd>norm! K<cr>", {desc = "Keywordprg"})

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- lazy
map("n", "<leader>l", "<cmd>Lazy<cr>", {desc = "Lazy"})

-- new file
map("n", "<leader>fn", "<cmd>enew<cr>", {desc = "New File"})

map("n", "<leader>xl", "<cmd>lopen<cr>", {desc = "Location List"})
map("n", "<leader>xq", "<cmd>copen<cr>", {desc = "Quickfix List"})

map("n", "[q", vim.cmd.cprev, {desc = "Previous quickfix"})
map("n", "]q", vim.cmd.cnext, {desc = "Next quickfix"})

-- formatting
map({"n", "v"}, "<leader>cf", function() Utils.format({force = true}) end,
    {desc = "Format"})

-- diagnostic
local diagnostic_goto = function(next, severity)
    local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
    severity = severity and vim.diagnostic.severity[severity] or nil
    return function() go({severity = severity}) end
end
map("n", "<leader>cd", vim.diagnostic.open_float, {desc = "Line Diagnostics"})
map("n", "]d", diagnostic_goto(true), {desc = "Next Diagnostic"})
map("n", "[d", diagnostic_goto(false), {desc = "Prev Diagnostic"})
map("n", "]e", diagnostic_goto(true, "ERROR"), {desc = "Next Error"})
map("n", "[e", diagnostic_goto(false, "ERROR"), {desc = "Prev Error"})
map("n", "]w", diagnostic_goto(true, "WARN"), {desc = "Next Warning"})
map("n", "[w", diagnostic_goto(false, "WARN"), {desc = "Prev Warning"})

-- stylua: ignore start

-- toggle options
map("n", "<leader>uf", function() Utils.format.toggle() end,
    {desc = "Toggle auto format (global)"})
map("n", "<leader>uF", function() Utils.format.toggle(true) end,
    {desc = "Toggle auto format (buffer)"})
map("n", "<leader>us", function() Utils.toggle("spell") end,
    {desc = "Toggle Spelling"})
map("n", "<leader>uw", function() Utils.toggle("wrap") end,
    {desc = "Toggle Word Wrap"})
map("n", "<leader>uL", function() Utils.toggle("relativenumber") end,
    {desc = "Toggle Relative Line Numbers"})
map("n", "<leader>ul", function() Utils.toggle.number() end,
    {desc = "Toggle Line Numbers"})
map("n", "<leader>ud", function() Utils.toggle.diagnostics() end,
    {desc = "Toggle Diagnostics"})
local conceallevel = vim.o.conceallevel > 0 and vim.o.conceallevel or 3
map("n", "<leader>uc",
    function() Utils.toggle("conceallevel", false, {0, conceallevel}) end,
    {desc = "Toggle Conceal"})
if vim.lsp.buf.inlay_hint or vim.lsp.inlay_hint then
    map("n", "<leader>uh", function() Utils.toggle.inlay_hints() end,
        {desc = "Toggle Inlay Hints"})
end
map("n", "<leader>uT", function()
    if vim.b.ts_highlight then
        vim.treesitter.stop()
    else
        vim.treesitter.start()
    end
end, {desc = "Toggle Treesitter Highlight"})
map("n", "<leader>ub",
    function() Utils.toggle("background", false, {"light", "dark"}) end,
    {desc = "Toggle Background"})

-- Git
map("n", "<leader>gg", function()
    Utils.terminal({"lazygit"},
                   {cwd = Utils.root(), esc_esc = false, ctrl_hjkl = false})
end, {desc = "Lazygit (root dir)"})
map("n", "<leader>gG", function()
    Utils.terminal({"lazygit"}, {esc_esc = false, ctrl_hjkl = false})
end, {desc = "Lazygit (cwd)"})

map("n", "<leader>gb", ":Gitsigns toggle_current_line_blame<cr>",
    {desc = "Toggle Blame"})
map("n", "<leader>gf", function()
    if not Utils.git.is_git_directory() then
        Utils.lazy_notify("Current project is not a git directory", "WARN",
                          {title = "Telescope Git Files"})
    else
        require("telescope.builtin").git_files()
    end
end, {desc = "Search [G]it [F]iles"})

-- quit
map("n", "<leader>qq", "<cmd>qa<cr>", {desc = "Quit all"})
map("n", "<leader>qQ", "<cmd>qa!<cr>", {desc = "Quit all (force)"})
map("n", "<leader>q", "<cmd>q<cr>", {desc = "Quit"})

-- highlights under cursor
map("n", "<leader>ui", vim.show_pos, {desc = "Inspect Pos"})

-- horizontal terminal
map("n", "<c-/>", "<Cmd>ToggleTerm", {desc = "Terminal (root dir)"})

-- Terminal Mappings
map("t", "<esc><esc>", "<c-\\><c-n>", {desc = "Enter Normal Mode"})
map("t", "<C-h>", "<cmd>wincmd h<cr>", {desc = "Go to left window"})
map("t", "<C-j>", "<cmd>wincmd j<cr>", {desc = "Go to lower window"})
map("t", "<C-k>", "<cmd>wincmd k<cr>", {desc = "Go to upper window"})
map("t", "<C-l>", "<cmd>wincmd l<cr>", {desc = "Go to right window"})
map("t", "<C-/>", "<cmd>close<cr>", {desc = "Hide Terminal"})
map("t", "<c-_>", "<cmd>close<cr>", {desc = "which_key_ignore"})

-- windows
map("n", "<leader>ww", "<C-W>p", {desc = "Other window", remap = true})
map("n", "<leader>wd", "<C-W>c", {desc = "Delete window", remap = true})
map("n", "<leader>w-", "<C-W>s", {desc = "Split window below", remap = true})
map("n", "<leader>w|", "<C-W>v", {desc = "Split window right", remap = true})
map("n", "<leader>-", "<C-W>s", {desc = "Split window below", remap = true})
map("n", "<leader>|", "<C-W>v", {desc = "Split window right", remap = true})
-- Press leader rw to rotate open windows
map("n", "<leader>wr", "<cmd>RotateWindows<cr>", {desc = "[R]otate [W]indows"})

-- tabs
map("n", "<leader><tab>l", "<cmd>tablast<cr>", {desc = "Last Tab"})
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", {desc = "First Tab"})
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", {desc = "New Tab"})
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", {desc = "Next Tab"})
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", {desc = "Close Tab"})
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", {desc = "Previous Tab"})

-- Map Oil to <leader>e
map("n", "<leader>e", function() require("oil").toggle_float() end,
    {desc = "Open Oil"})

-- Center buffer while navigating

map("n", "n", "nzzzv", {desc = "Next search result"})
map("n", "N", "Nzzzv", {desc = "Prev search result"})
map("n", "<C-u>", "<C-u>zz", {desc = "Scroll up"})
map("n", "<C-d>", "<C-d>zz", {desc = "Scroll down"})
map("n", "gg", "ggzz", {desc = "Go to top"})
map("n", "G", "Gzz", {desc = "Go to bottom"})
map("n", "{", "{zz", {desc = "Next paragraph"})
map("n", "}", "}zz", {desc = "Prev paragraph"})

-- Open Spectre for global find/replace
map("n", "<leader>sw",
    function() require("spectre").open_visual({select_word = true}) end,
    {desc = "Search current word"})

-- Open Spectre for global find/replace for the word under the cursor in normal mode
-- TODO Fix, currently being overriden by Telescope
map("n", "<leader>ss", function() require("spectre").open_file_search() end,
    {desc = "Search in file"})

-- Press 'U' for redo
map("n", "U", "<C-r>", {desc = "Redo"})

-- -----
-- Trouble --
-- -----

map("n", "<leader>xx", function() require("trouble").toggle() end,
    {desc = "Trouble Toggle"})

map("n", "<leader>xw",
    function() require("trouble").toggle({mode = "workspace"}) end,
    {desc = "Trouble Workspace"})

map("n", "<leader>xd",
    function() require("trouble").toggle({mode = "document"}) end,
    {desc = "Trouble Document"})

map("n", "<leader>xl",
    function() require("trouble").toggle({mode = "loclist"}) end,
    {desc = "Trouble Loclist"})

map("n", "<leader>xq",
    function() require("trouble").toggle({mode = "quickfix"}) end,
    {desc = "Trouble Quickfix"})

map("n", "gR",
    function() require("trouble").toggle({mode = "lsp_references"}) end,
    {desc = "Trouble LSP References"})

-- -----
-- Diagnostics --
-- -----

map("n", "]d", function()
    vim.diagnostic.goto_next({})
    vim.api.nvim_feedkeys("zz", "n", false)
end, {desc = "Next Diagnostic"})

map("n", "[d", function()
    vim.diagnostic.goto_prev({})
    vim.api.nvim_feedkeys("zz", "n", false)
end, {desc = "Prev Diagnostic"})

map("n", "]e", function()
    vim.diagnostic.goto_next({severity = vim.diagnostic.severity.ERROR})
    vim.api.nvim_feedkeys("zz", "n", false)
end, {desc = "Next Error"})

map("n", "[e", function()
    vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.ERROR})
    vim.api.nvim_feedkeys("zz", "n", false)
end, {desc = "Prev Error"})

map("n", "]w", function()
    vim.diagnostic.goto_next({severity = vim.diagnostic.severity.WARN})
    vim.api.nvim_feedkeys("zz", "n", false)
end, {desc = "Next Warning"})

map("n", "[w", function()
    vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.WARN})
    vim.api.nvim_feedkeys("zz", "n", false)
end, {desc = "Prev Warning"})

map("n", "<leader>d",
    function() vim.diagnostic.open_float({border = "rounded"}) end,
    {desc = "Open Diagnostics"})

-- -----
-- Telescope keybinds --
-- -----

map("n", "<leader>?", function() require("telescope.builtin").oldfiles() end,
    {desc = "Find recently opened files"})

map("n", "<leader>sf",
    function() require("telescope.builtin").find_files({hidden = true}) end,
    {desc = "Search Files"})

map("n", "<leader>sh", function() require("telescope.builtin").help_tags() end,
    {desc = "Search Help"})

map("n", "<leader>.", function()
    require("telescope.builtin").current_buffer_fuzzy_find(require(
                                                               "telescope.themes").get_dropdown(
                                                               {
            previewer = false
        }))
end, {desc = "Fuzzily search in current buffer"})

map("n", "<leader>ss", function()
    require("telescope.builtin").spell_suggest(
        require("telescope.themes").get_dropdown({previewer = false}))
end, {desc = "Search Spelling suggestions"})

map("n", "<leader>:", "<cmd>Telescope command_history<cr>",
    {desc = "Command History"})
map("n", "<leader><space>", Utils.telescope("files"),
    {desc = "Find Files (root dir)"})
map("n", "<leader>fb",
    "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",
    {desc = "Buffers"})
map("n", "<leader>fc", Utils.telescope.config_files(),
    {desc = "Find Config File"})
map("n", "<leader>ff", Utils.telescope("files"),
    {desc = "Find Files (root dir)"})
map("n", "<leader>fF", Utils.telescope("files", {cwd = false}),
    {desc = "Find Files (cwd)"})
map("n", "<leader>fg", "<cmd>Telescope git_files<cr>",
    {desc = "Find Files (git-files)"})
map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", {desc = "Recent"})
map("n", "<leader>fR", Utils.telescope("oldfiles", {cwd = vim.loop.cwd()}),
    {desc = "Recent (cwd)"})
map("n", "<leader>gc", "<cmd>Telescope git_commits<CR>", {desc = "commits"})
map("n", "<leader>gs", "<cmd>Telescope git_status<CR>", {desc = "status"})
map("n", '<leader>s"', "<cmd>Telescope registers<cr>", {desc = "Registers"})
map("n", "<leader>sa", "<cmd>Telescope autocommands<cr>",
    {desc = "Auto Commands"})
map("n", "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>",
    {desc = "Buffer"})
map("n", "<leader>sc", "<cmd>Telescope command_history<cr>",
    {desc = "Command History"})
map("n", "<leader>sC", "<cmd>Telescope commands<cr>", {desc = "Commands"})
map("n", "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>",
    {desc = "Document diagnostics"})
map("n", "<leader>sD", "<cmd>Telescope diagnostics<cr>",
    {desc = "Workspace diagnostics"})
map("n", "<leader>sg", Utils.telescope("live_grep"), {desc = "Grep (root dir)"})
map("n", "<leader>sG", Utils.telescope("live_grep", {cwd = false}),
    {desc = "Grep (cwd)"})
map("n", "<leader>sh", "<cmd>Telescope help_tags<cr>", {desc = "Help Pages"})
map("n", "<leader>sH", "<cmd>Telescope highlights<cr>",
    {desc = "Search Highlight Groups"})
map("n", "<leader>sk", "<cmd>Telescope keymaps<cr>", {desc = "Key Maps"})
map("n", "<leader>sM", "<cmd>Telescope man_pages<cr>", {desc = "Man Pages"})
map("n", "<leader>sm", "<cmd>Telescope marks<cr>", {desc = "Jump to Mark"})
map("n", "<leader>so", "<cmd>Telescope vim_options<cr>", {desc = "Options"})
map("n", "<leader>sR", "<cmd>Telescope resume<cr>", {desc = "Resume"})
map("n", "<leader>sw", Utils.telescope("grep_string", {word_match = "-w"}),
    {desc = "Word (root dir)"})
map("n", "<leader>sW",
    Utils.telescope("grep_string", {cwd = false, word_match = "-w"}),
    {desc = "Word (cwd)"})
map("v", "<leader>sw", Utils.telescope("grep_string"),
    {desc = "Selection (root dir)"})
map("v", "<leader>sW", Utils.telescope("grep_string", {cwd = false}),
    {desc = "Selection (cwd)"})
map("n", "<leader>uC", Utils.telescope("colorscheme", {enable_preview = true}),
    {desc = "Colorscheme with preview"})
