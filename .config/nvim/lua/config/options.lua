-- Leader Key
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Editor Behavior
local opt = vim.opt
opt.autowrite = true -- Auto-save before commands like :next and :make
opt.clipboard = "unnamedplus" -- Sync with system clipboard
opt.mouse = "a" -- Enable mouse mode
opt.wrap = false -- Disable line wrap
opt.splitbelow = true -- Horizontal splits below current window
opt.splitright = true -- Vertical splits to the right of current window
opt.updatetime = 200 -- Faster completion (4000ms default)
opt.timeoutlen = 300 -- Time in ms to wait for a mapped sequence to complete
opt.termguicolors = true -- Enable 24-bit RGB colors

-- UI
opt.number = true -- Print line number
opt.relativenumber = true -- Relative line numbers
opt.cursorline = true -- Highlight the current line
opt.signcolumn = "yes" -- Always show the signcolumn, avoids text shifting
opt.colorcolumn = "120" -- Marker for max line length
opt.foldmethod = "expr" -- Set fold method
opt.foldexpr = "nvim_treesitter#foldexpr()" -- Use treesitter for fold expressions
opt.foldlevelstart = 99 -- Start editing with all folds open
opt.scrolloff = 8 -- Minimum lines above/below cursor
opt.sidescrolloff = 8 -- Minimum columns left/right of cursor

-- Searching
opt.ignorecase = true -- Ignore case
opt.smartcase = true -- Override ignorecase if search contains uppercase
opt.incsearch = true -- Incremental search
opt.hlsearch = true -- Highlight search results

-- Indentation
opt.tabstop = 2 -- Number of spaces a <Tab> counts for
opt.shiftwidth = 2 -- Size of an indent
opt.softtabstop = 2 -- Number of spaces a tab counts for in insert mode
opt.expandtab = true -- Use spaces instead of tabs
opt.smartindent = true -- Insert indents automatically

-- Folding
vim.opt.foldlevel = 99
vim.opt.foldtext = "v:lua.require'util'.ui.foldtext()"

-- Backup and Undo
opt.undofile = true -- Persistent undo

opt.guicursor = {
    "n-v-c:block", "i-ci-ve:ver25", "r-cr:hor20", "o:hor50",
    "a:blinkwait700-blinkoff400-blinkon250",
    "sm:block-blinkwait175-blinkoff150-blinkon175"
}
