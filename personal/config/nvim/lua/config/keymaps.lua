-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Terminal toggle keymap (using French keyboard character ù)
vim.keymap.set("n", "ù", "<CMD>lua require('FTerm').toggle()<CR>", { noremap = true, silent = true, desc = "Toggle FTerm" })
vim.keymap.set("t", "ù", "<C-\\><C-n><CMD>lua require('FTerm').toggle()<CR>", { noremap = true, silent = true, desc = "Toggle FTerm" })

-- REST client keymap
vim.keymap.set("n", "<leader>rr", "<cmd>Rest run<CR>", { noremap = true, silent = true, desc = "Run REST request" })
