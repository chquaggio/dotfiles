-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
require("neo-tree").setup({
  window = {
    mappings = {
      ["<left>"] = "navigate_up",
      ["<right>"] = "open",
    },
  },
  filesystem = {
    window = {
      mappings = {
        ["<left>"] = "navigate_up",
        ["<right>"] = "open",
      },
    },
  },
  buffers = {
    window = {
      mappings = {
        ["<left>"] = "navigate_up",
        ["<right>"] = "open",
      },
    },
  },
})

vim.keymap.set("n", "<leader>cp", "<cmd>Copilot panel<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>al", "<cmd>AerialToggle<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "ù", "<CMD>lua require('FTerm').toggle()<CR>", { noremap = true, silent = true })
vim.keymap.set("t", "ù", "<C-\\><C-n><CMD>lua require('FTerm').toggle()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>rr", "<cmd>Rest run<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>rl", "<cmd>Rest run last<CR>", { noremap = true, silent = true })
