return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      strategies = {
        chat = { adapter = "openrouter" },
        inline = { adapter = "openrouter" },
        agent = { adapter = "openrouter" },
      },
      adapters = {
        openrouter = function()
          return require("codecompanion.adapters").extend("openai_compatible", {
            env = {
              url = "https://openrouter.ai/api",
              api_key = "OPENROUTER_API_KEY", -- Reads from environment variable
              chat_url = "/v1/chat/completions",
            },
            schema = {
              model = {
                default = "google/gemini-3-flash-preview",
              },
            },
          })
        end,
      },
    },
    keys = {
      { "<C-a>", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "AI Actions (CodeCompanion)" },
      { "<LocalLeader>a", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "AI Chat (CodeCompanion)" },
      { "ga", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "Add to AI Chat" },
    },
  },
}
