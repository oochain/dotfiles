return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        hidden = true, -- for dotfiles
        ignored = true, -- for gitignored files
        exclude = {
          ".git",
          ".ruff_cache",
          ".venv",
          ".pytest_cache",
          "__pycache__",
          "*.egg-info",
          "node_modules",
        },
      },
    },
  },
}
