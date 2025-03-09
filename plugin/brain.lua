vim.api.nvim_create_user_command("BrainLog", function()
  -- package.loaded["brain"] = nil
  require("brain").log()
end, {})

vim.api.nvim_create_user_command("BrainOrganize", function()
  require("brain").organize()
end, {})

vim.api.nvim_create_user_command("BrainAdd", function()
  require("brain").add()
end, {})
