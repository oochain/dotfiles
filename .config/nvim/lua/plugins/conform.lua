return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        prettier = {
          prepend_args = { "--tab-width", "4" },
        },
      },
      formatters_by_ft = {
        python = { "ruff" },
        terraform = { "terraform_fmt" },
        tf = { "terraform_fmt" },
        ["terraform-vars"] = { "terraform_fmt" },
        json = { "prettier" },
        javascript = { "prettier" },
        typescript = { "prettier" },
      },
    },
  },
}
