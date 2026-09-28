-- Taplo LSP is kept for TOML schema validation and autocomplete only.
-- Formatting is disabled in conform.lua (toml = {}) because Taplo always
-- expands every array element onto its own line — there is no setting to
-- preserve manually grouped arrays (e.g. ruff lint select with comments).
return {}
