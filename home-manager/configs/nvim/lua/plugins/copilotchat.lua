return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- Ta base actuelle
      { "nvim-lua/plenary.nvim" }, -- Pour les requêtes async
    },
    opts = {
      debug = false,
      -- Tu peux personnaliser d'autres options ici
    },
    config = function(_, opts)
      local chat = require("CopilotChat")
      chat.setup(opts)

      -- --- LE SCRIPT DU SELECTEUR ---
      local function ai_commit_picker()
        -- On récupère le diff de ce qui est 'staged' (git add)
        local diff = vim.fn.system("git diff --cached")
        if diff == "" then
          vim.notify("Rien n'est stagé (fais un git add d'abord)", vim.log.levels.WARN)
          return
        end

        local prompt =
          "Generate 3 different concise commit messages (one line each) based on this diff, following Conventional Commits. Use English. Give me only the messages, one per line, no numbering or bullets."

        vim.notify("L'IA réfléchit...", vim.log.levels.INFO)

        chat.ask(prompt, {
          selection = function()
            return { lines = vim.split(diff, "\n"), filetype = "diff" }
          end,
          callback = function(response)
            -- On nettoie la réponse pour en faire une liste propre
            local lines = {}
            for line in response:gmatch("[^\r\n]+") do
              local clean = line:gsub("^[%s%-*]+", ""):gsub("^%d+%.%s+", "")
              if clean ~= "" then
                table.insert(lines, clean)
              end
            end

            -- Utilisation de Snacks.picker (ou fallback sur vim.ui.select)
            if _G.Snacks then
              Snacks.picker.select(lines, { prompt = "AI Commit Options" }, function(choice)
                if choice then
                  vim.fn.system({ "git", "commit", "-m", choice })
                  vim.notify("Commit effectué : " .. choice)
                end
              end)
            else
              vim.ui.select(lines, { prompt = "Choisir le message de commit :" }, function(choice)
                if choice then
                  vim.fn.system({ "git", "commit", "-m", choice })
                  vim.notify("Commit effectué : " .. choice)
                end
              end)
            end
          end,
        })
      end

      -- Raccourci clavier : <leader>gC
      vim.keymap.set("n", "<leader>gC", ai_commit_picker, { desc = "Git AI Commit Picker" })
    end,
  },
}
