--
-- WARN: Breaking change from Mason v1 to v2.
--
-- Today is 9mai25 and two days ago there was a breaking change in Mason. After
-- having many problems trying to fix the issue by myself, I found an issue[1]
-- in which the creator suggests the workaround below.
--
-- Links:
--  [1]: https://github.com/mason-org/mason-lspconfig.nvim/issues/545

return {
  { "mason-org/mason.nvim", version = "^1.0.0" },
  { "mason-org/mason-lspconfig.nvim", version = "^1.0.0" },
}
