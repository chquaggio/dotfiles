-- Usage: nvim --headless -u <your_init.lua> -l run_copilotchat_commit.lua "<output_file>"
local outfile = arg[1] or "/tmp/copilotchat_commit.txt"

-- Get staged diff
local handle = io.popen("git -C . diff --no-color --no-ext-diff --staged")
local staged_diff = handle:read("*a")
handle:close()

if staged_diff == "" then
  print("No staged changes found.")
  os.exit(1)
end

local chat = require("CopilotChat")

local prompt = "Generate a commit message with commitzen convention, but without commit description, for the following staged changes:\n"
  .. staged_diff

chat.ask(prompt, {
  callback = function(response)
    print(response)
    vim.cmd("qa!")
  end,
})
vim.cmd("sleep 20")
