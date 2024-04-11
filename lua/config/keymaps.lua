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

vim.keymap.set("n", "<leader>cp", ":Copilot panel<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>al", ":AerialToggle<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>t", "<CMD>lua require('FTerm').toggle()<CR>", { noremap = true, silent = true })
vim.keymap.set("t", "<leader>t", "<C-\\><C-n><CMD>lua require('FTerm').toggle()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>rr", "<Plug>RestNvim", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>rp", "<Plug>RestNvimPreview", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>rl", "<Plug>RestNvimLast", { noremap = true, silent = true })
