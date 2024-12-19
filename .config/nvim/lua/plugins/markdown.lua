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
}
