-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Shell script formatting autocmds
vim.api.nvim_create_autocmd("FileType", {
  pattern = "sh",
  callback = function()
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
    vim.bo.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.sh",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- Python with ruff formatting
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.py",
  callback = function()
    local file = vim.fn.expand("%")
    local cmd = string.format('pre-commit run --files "%s"', file)
    vim.fn.system(cmd)
    -- Reload the buffer to see changes
    vim.cmd("e!")
  end,
})