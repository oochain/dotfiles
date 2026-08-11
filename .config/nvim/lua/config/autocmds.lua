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

-- Python: run pre-commit after save, mirroring what the git pre-commit hook
-- does, so the file is formatted before you commit. The `_pre_commit_running`
-- flag prevents the buffer reload from re-triggering this autocmd.
local _pre_commit_running = false

-- Read the INSTALL_PYTHON path that `pre-commit install` embedded in the git
-- hook. That is the same Python binary the hook uses, so we stay consistent.
local function get_hook_python(git_root)
  local hook = git_root .. "/.git/hooks/pre-commit"
  if vim.fn.filereadable(hook) == 0 then
    return nil
  end
  for line in io.lines(hook) do
    local python = line:match("^INSTALL_PYTHON=(.+)$")
    if python then
      return python
    end
  end
  return nil
end

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.py",
  callback = function()
    if _pre_commit_running then
      return
    end

    local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
    if not git_root or vim.v.shell_error ~= 0 then
      return
    end
    if vim.fn.filereadable(git_root .. "/.pre-commit-config.yaml") == 0 then
      return
    end

    local python = get_hook_python(git_root)
    if not python or vim.fn.executable(python) == 0 then
      return
    end

    local file = vim.fn.expand("%:p")
    -- Run from git_root so pre-commit finds .pre-commit-config.yaml.
    local cmd = string.format(
      "cd %s && %s -mpre_commit run --files %s",
      vim.fn.shellescape(git_root),
      vim.fn.shellescape(python),
      vim.fn.shellescape(file)
    )

    _pre_commit_running = true
    vim.fn.system(cmd)
    -- pre-commit exits 1 when a hook fixed something, reload to see changes.
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
