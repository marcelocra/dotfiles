return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,

    ---@type snacks.Config
    opts = {
      profiler = { enabled = false },
      notifier = {
        style = "fancy",

        width = { min = 40, max = 0.8 },
        height = { min = 1, max = 0.6 },
      },
    },
  },
}
