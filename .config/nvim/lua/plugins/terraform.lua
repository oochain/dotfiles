-- Terraform LSP tweaks for Neovim 0.11+
--
-- The upstream nvim-lspconfig terraformls config ships an on_attach that calls
-- vim.lsp.codelens.enable(), an API that was removed in Neovim 0.11. This
-- causes an ON_ATTACH_ERROR every time a terraform file is opened.
--
-- We override the LSP config here to replicate the same behaviour (auto-refresh
-- codelenses) using the current Neovim 0.11 API: an autocmd that calls
-- vim.lsp.codelens.refresh() on the buffer events recommended by the docs.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        terraformls = {
          -- Replace the broken on_attach from upstream with a working one.
          on_attach = function(client, bufnr)
            -- Refresh codelenses when entering the buffer, holding the cursor,
            -- or leaving insert mode — the pattern shown in :h lsp-codelens.
            vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
              buffer = bufnr,
              callback = function()
                vim.lsp.codelens.refresh({ bufnr = bufnr })
              end,
            })
          end,
        },
      },
    },
  },
}
