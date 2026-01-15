-- Usage: nvim --headless -u <your_init.lua> -l run_copilotchat_commit.lua "<output_file>"

-- Get staged diff
local handle = io.popen("git diff --no-color --no-ext-diff --staged")
local staged_diff = handle:read("*a")
handle:close()

if staged_diff == "" then
  print("No staged changes found.")
  os.exit(1)
end

local chat = require("CopilotChat")

local prompt = ([[
You are an assistant that outputs ONLY a single conventional commit subject line.
Rules:
- Conventional commit format: <type>(optional scope): <subject>
- Allowed types: feat, fix, docs, style, refactor, perf, test, chore, build, ci
- Subject <= 72 chars, imperative mood, no trailing period.
- NO body, NO extra explanations, NO code fences.

Generate the commit subject for the following staged changes:

%s
]]):format(staged_diff)

chat.ask(prompt, {
  headless = true,
  callback = function(response)
    print(response.content)
    vim.cmd("qa!")
  end,
})
vim.cmd("sleep 20")
