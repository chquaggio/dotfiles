local prompts = {
  -- Code related prompts
  Explain = "Please explain how the following code works.",
  Review = "Please review the following code and provide suggestions for improvement.",
  Tests = "Please generate unit tests for the following code.",
  Docstrings = "Please generate detailed docstrings for the following code.",
  Refactor = "Please refactor the following code to improve its clarity and readability.",
  FixCode = "Please fix the following code to make it work as intended.",
  FixError = "Please explain the error in the following text and provide a solution.",
  BetterNamings = "Please provide better names for the following variables and functions.",
  Documentation = "Please provide documentation for the following code.",
  SwaggerApiDocs = "Please provide documentation for the following API using Swagger.",
  -- Text related prompts
  Summarize = "Please summarize the following text.",
  Spelling = "Please correct any grammar and spelling errors in the following text.",
  Wording = "Please improve the grammar and wording of the following text.",
  Concise = "Please rewrite the following text to make it more concise.",
}

return {
  "CopilotC-Nvim/CopilotChat.nvim",
  dependencies = {
    {
      "zbirenbaum/copilot.lua",
      optional = true,
      opts = function()
        require("copilot.api").status = require("copilot.status")
      end,
    },
    { "nvim-lua/plenary.nvim" },
  },
  build = "make tiktoken", -- Only on MacOS or Linux
  opts = {
    prompts = prompts,
    model = "gpt-5.2",
    temperature = 0.1,
    auto_follow_cursor = false, -- Don't follow the cursor after getting response
    show_help = false, -- Show help in virtual text, set to true if that's 1st time using Copilot Chat
    headers = {
      user = "👤 You",
      assistant = "🤖 Copilot",
      tool = "🔧 Tool",
    },
    contexts = {
      git = {
        diff = true,
        commit = true,
      },
    },
    mappings = {
      -- Use tab for completion
      complete = {
        detail = "Use @<Tab> or /<Tab> for options.",
        insert = "<Tab>",
      },
      -- Close the chat
      close = {
        normal = "q",
        insert = "<C-c>",
      },
      -- Reset the chat buffer
      reset = {
        normal = "<C-x>",
        insert = "<C-x>",
      },
      -- Submit the prompt to Copilot
      submit_prompt = {
        normal = "<CR>",
        insert = "<C-CR>",
      },
      -- Accept the diff
      accept_diff = {
        normal = "<C-y>",
        insert = "<C-y>",
      },
      -- Yank the diff in the response to register
      yank_diff = {
        normal = "gmy",
      },
      -- Show the diff
      show_diff = {
        normal = "gmd",
      },
      -- Show the prompt
      show_system_prompt = {
        normal = "gmp",
      },
      -- Show the user selection
      show_user_selection = {
        normal = "gms",
      },
    },
  },
  -- config = function(_, opts)
  --   local chat = require("CopilotChat")
  --   local select = require("CopilotChat.select")
  --   -- -- Use unnamed register for the selection
  --   -- opts.selection = select.unnamed
  --   require("fzf-lua").register_ui_select()
  --
  --   chat.setup(opts)
  --
  --   -- Restore CopilotChatBuffer
  --   vim.api.nvim_create_user_command("CopilotChatBuffer", function(args)
  --     chat.ask(args.args, { selection = select.buffer })
  --   end, { nargs = "*", range = true })
  --
  --   -- Custom buffer for CopilotChat
  --   vim.api.nvim_create_autocmd("BufEnter", {
  --     pattern = "copilot-*",
  --     callback = function()
  --       vim.opt_local.relativenumber = true
  --       vim.opt_local.number = true
  --
  --       -- Get current filetype and set it to markdown if the current filetype is copilot-chat
  --       local ft = vim.bo.filetype
  --       if ft == "copilot-chat" then
  --         vim.bo.filetype = "markdown"
  --       end
  --     end,
  --   })
  --
  --   -- Add which-key mappings
  --   local wk = require("which-key")
  --   wk.add({
  --     { "<leader>gm", group = "+Copilot Chat" }, -- group
  --     { "<leader>gmd", desc = "Show diff" },
  --     { "<leader>gmp", desc = "System prompt" },
  --     { "<leader>gms", desc = "Show selection" },
  --     { "<leader>gmy", desc = "Yank diff" },
  --   })
  -- end,
  event = "VeryLazy",
  keys = {
    -- Code related commands
    { "<leader>ae", "<cmd>CopilotChatExplain<cr>", desc = "CopilotChat - Explain code" },
    { "<leader>ac", "<cmd>CopilotChatCommit<cr>", desc = "CopilotChat - Generate commit" },
    { "<leader>at", "<cmd>CopilotChatTests<cr>", desc = "CopilotChat - Generate tests" },
    { "<leader>ar", "<cmd>CopilotChatReview<cr>", desc = "CopilotChat - Review code" },
    { "<leader>aR", "<cmd>CopilotChatRefactor<cr>", desc = "CopilotChat - Refactor code" },
    { "<leader>an", "<cmd>CopilotChatBetterNamings<cr>", desc = "CopilotChat - Better Naming" },
    -- Chat with Copilot in visual mode
    {
      "<leader>av",
      ":CopilotChatVisual",
      mode = "x",
      desc = "CopilotChat - Open in vertical split",
    },
    -- Custom input for CopilotChat
    {
      "<leader>ai",
      function()
        local input = vim.fn.input("Ask Copilot: ")
        if input ~= "" then
          vim.cmd("CopilotChat " .. input)
        end
      end,
      desc = "CopilotChat - Ask input",
    },
    -- Quick chat with Copilot
    {
      "<leader>aq",
      function()
        local input = vim.fn.input("Quick Chat: ")
        if input ~= "" then
          vim.cmd("CopilotChatBuffer " .. input)
        end
      end,
      desc = "CopilotChat - Quick chat",
    },
    -- Debug
    { "<leader>ad", "<cmd>CopilotChatDebugInfo<cr>", desc = "CopilotChat - Debug Info" },
    -- Fix the issue with diagnostic
    { "<leader>af", "<cmd>CopilotChatFixDiagnostic<cr>", desc = "CopilotChat - Fix Diagnostic" },
    -- Clear buffer and chat history
    { "<leader>al", "<cmd>CopilotChatReset<cr>", desc = "CopilotChat - Clear buffer and chat history" },
    -- Toggle Copilot Chat Vsplit
    { "<leader>av", "<cmd>CopilotChatToggle<cr>", desc = "CopilotChat - Toggle" },
    -- Copilot Chat Models
    { "<leader>a?", "<cmd>CopilotChatModels<cr>", desc = "CopilotChat - Select Models" },
  },
}
