vim.api.nvim_create_user_command("BrainLog", function()
  -- package.loaded["brain"] = nil
  require("brain").log()
end, {})
