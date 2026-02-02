return {
  -- First, disable the pyright LSP server from being configured
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = false,
        pyrefl = {},
      },
    },
  },
  -- Second, remove pyright from the list of packages mason should install, and add pyrefly
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      -- `opts.ensure_installed` is the list of packages to be installed
      opts.ensure_installed = opts.ensure_installed or {}

      -- Add "pyrefly" to the list
      table.insert(opts.ensure_installed, "pyrefly")

      -- Filter out "pyright" from the list
      opts.ensure_installed = vim.tbl_filter(function(server)
        return server ~= "pyright"
      end, opts.ensure_installed)
    end,
  },
}
