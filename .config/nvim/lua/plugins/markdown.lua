local HOME = os.getenv("HOME")
return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        markdown = { "markdownlint" },
      },
      formatters = {
        markdownlint = {
          prepend_args = { "--indent", "4" },
        },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters = {
        ["markdownlint-cli2"] = {
          args = { "--config", HOME .. "/.markdownlint-cli2.yaml", "--" },
          -- to disable lingth check, add the following in ~/prod-main-dashboard.json
          -- config:
          --  MD013: false
        },
      },
    },
  },
}
