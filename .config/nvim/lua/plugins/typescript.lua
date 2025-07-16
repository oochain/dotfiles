return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ts_ls = {
          filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
          settings = {
            typescript = {
              preferences = {
                includePackageJsonAutoImports = "auto",
              },
            },
            javascript = {
              preferences = {
                includePackageJsonAutoImports = "auto",
              },
            },
          },
        },
      },
    },
  },
}
