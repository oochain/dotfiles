local function get_ruff_version()
  local precommit = vim.fn.getcwd() .. "/.pre-commit-config.yaml"

  if vim.fn.filereadable(precommit) == 0 then
    return "0.15.4" -- fallback
  end

  local in_ruff_repo = false

  for line in io.lines(precommit) do
    if line:match("astral%-sh/ruff%-pre%-commit") then
      in_ruff_repo = true
    elseif in_ruff_repo then
      -- Matches:
      -- rev: a27a2e47c7751b639d2b5badf0ef6ff11fee893f # v0.15.4
      local version = line:match("rev:.-#%s*v([%d%.]+)")
      if version then
        return version
      end

      -- Stop searching once we hit the next repo
      if line:match("^%s*%- repo:") then
        break
      end
    end
  end
end

return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "ruff" },
        terraform = { "terraform_fmt" },
        tf = { "terraform_fmt" },
        ["terraform-vars"] = { "terraform_fmt" },
        json = { "prettier" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
      },
    },
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}

      -- Remove unpinned ruff entries
      opts.ensure_installed = vim.tbl_filter(function(pkg)
        if type(pkg) == "string" then
          return pkg ~= "ruff"
        end
        if type(pkg) == "table" then
          return pkg[1] ~= "ruff"
        end
        return true
      end, opts.ensure_installed)

      table.insert(opts.ensure_installed, {
        "ruff",
        version = get_ruff_version(),
      })
    end,
  },
}

-- return {
--   {
--     "stevearc/conform.nvim",
--     opts = {
--       formatters_by_ft = {
--         python = { "ruff" },
--         terraform = { "terraform_fmt" },
--         tf = { "terraform_fmt" },
--         ["terraform-vars"] = { "terraform_fmt" },
--         json = { "prettier" },
--         javascript = { "prettier" },
--         typescript = { "prettier" },
--         html = { "prettier" },
--         css = { "prettier" },
--         scss = { "prettier" },
--       },
--     },
--   },
--   -- Pin ruff to the same version used in .pre-commit-config.yaml so formatting
--   -- behaviour is identical between the editor and the git hooks on every machine.
--   {
--     "WhoIsSethDaniel/mason-tool-installer.nvim",
--     opts = function(_, opts)
--       opts.ensure_installed = opts.ensure_installed or {}
--
--       -- Remove any un-versioned "ruff" entry added by other plugins (e.g. LazyVim extras)
--       opts.ensure_installed = vim.tbl_filter(function(pkg)
--         if type(pkg) == "string" then
--           return pkg ~= "ruff"
--         end
--         if type(pkg) == "table" then
--           return pkg[1] ~= "ruff"
--         end
--         return true
--       end, opts.ensure_installed)
--
--       -- mason-tool-installer supports { "pkg", version = "x.y.z" } for pinning.
--       table.insert(opts.ensure_installed, { "ruff", version = "0.15.4" })
--     end,
--   },
-- }
