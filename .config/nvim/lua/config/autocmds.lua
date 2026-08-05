-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- Shell script formatting autocmds
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

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

-- Python: run pre-commit after save so the pinned ruff version (from
-- .pre-commit-config.yaml) formats the file, then reload the buffer.
-- The `_pre_commit_running` flag stops the reload from re-triggering this autocmd.
local _pre_commit_running = false

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.py",
  callback = function()
    -- Skip if we are already inside a pre-commit run to avoid a reload loop.
    if _pre_commit_running then
      return
    end

    -- Only run when the repo has a pre-commit config file.
    local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
    if not git_root or vim.v.shell_error ~= 0 then
      return
    end
    local config_path = git_root .. "/.pre-commit-config.yaml"
    if vim.fn.filereadable(config_path) == 0 then
      return
    end

    -- Use the absolute path so pre-commit always finds the file.
    local file = vim.fn.expand("%:p")
    local cmd = string.format("pre-commit run --files %s", vim.fn.shellescape(file))

    _pre_commit_running = true
    vim.fn.system(cmd)
    -- Reload only when pre-commit actually changed the file (exit code 1 = fixed).
    if vim.v.shell_error == 1 then
      vim.cmd("e!")
    end
    _pre_commit_running = false
  end,
})

-- Dockerfile indentation settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "dockerfile",
  callback = function()
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
    vim.bo.softtabstop = 4
    vim.bo.expandtab = true
  end,
})
