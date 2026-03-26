-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

vim.keymap.set("n", "ù", "<CMD>lua require('FTerm').toggle()<CR>", { noremap = true, silent = true })
vim.keymap.set("t", "ù", "<C-\\><C-n><CMD>lua require('FTerm').toggle()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>rr", "<cmd>lua require('kulala').run()<CR>", { noremap = true, silent = true })
