local M = {}

---@class brain.Options
---@field brain_directory string

local data_dir = vim.fn.stdpath("data")

---@type brain.Options
local options = {
  ---@cast data_dir string
  brain_directory = data_dir .. "/brain",
}

---@param opts brain.Options
M.setup = function(opts)
  options = vim.tbl_deep_extend("force", options, opts or {})
end

return M
