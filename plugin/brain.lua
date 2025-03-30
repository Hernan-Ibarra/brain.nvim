vim.api.nvim_create_user_command("BrainDump", function()
  -- package.loaded["brain"] = nil
  require("brain").dump()
end, {})

vim.api.nvim_create_user_command("BrainOrganize", function()
  require("brain").organize()
end, {})
