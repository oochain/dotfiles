return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        prettier_2_spaces = {
          command = "prettier",
          args = { "--tab-width", "2", "--stdin-filepath", "$FILENAME" },
          stdin = true,
        },
      },
      formatters_by_ft = {
        python = { "ruff" },
        terraform = { "terraform_fmt" },
        tf = { "terraform_fmt" },
        ["terraform-vars"] = { "terraform_fmt" },
        json = { "prettier_2_spaces" },
        javascript = { "prettier_2_spaces" },
        typescript = { "prettier_2_spaces" },
        html = { "prettier_2_spaces" },
        css = { "prettier_2_spaces" },
        scss = { "prettier_2_spaces" },
      },
    },
  },
}
