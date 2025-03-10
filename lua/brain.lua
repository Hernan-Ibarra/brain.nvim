local M = {}

---@class brain.Options
---@field brain_directory string

local data_dir = vim.fn.stdpath("data")

---@type brain.Options
local defaults = {
  ---@cast data_dir string
  brain_directory = data_dir .. "/brain",
}

---@type brain.Options
local options = defaults

---@param opts? brain.Options
M.setup = function(opts)
  options = vim.tbl_deep_extend("force", defaults, opts or {})
end

--- Adapted from oil.nvim source code
---@param dir string
local mkdirp = function(dir)
  local mode = 484
  local modifier = ""
  local path = dir

  while vim.fn.isdirectory(path) == 0 do
    modifier = modifier .. ":h"
    path = vim.fn.fnamemodify(dir, modifier)
  end

  while modifier ~= "" do
    modifier = modifier:sub(3)
    path = vim.fn.fnamemodify(dir, modifier)
    vim.uv.fs_mkdir(path, mode)
  end
end

---@return { pretty: string, fname: string } date
local get_date = function()
  local now = os.date("*t")

  local fname = ("%s-%.2d-%.2d_%.2d-%.2d-%.2d"):format(now.year, now.month, now.day, now.hour, now.min, now.sec)

  local weekdays = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" }
  local months = {
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  }

  local pretty = ("%s %.2d %s %.2d:%.2d:%.2d %s"):format(
    weekdays[now.wday],
    now.day,
    months[now.month],
    now.hour,
    now.min,
    now.sec,
    now.year
  )
  return { pretty = pretty, fname = fname }
end

M.log = function()
  vim.cmd("$tabnew")

  local success, _ = pcall(function(brain_dir)
    if vim.fn.isdirectory(brain_dir) == 0 then
      mkdirp(brain_dir)
    end
    vim.cmd.tcd(brain_dir)
  end, options.brain_directory)

  if not success then
    vim.notify("Could not find or could not create brain directory.", vim.log.levels.WARN)
  end

  local date = get_date()
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_name(buf, date.fname)

  vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = buf,
    callback = function()
      vim.api.nvim_buf_set_lines(buf, 0, 0, true, { date.pretty, "" })
    end,
    once = true,
  })
  vim.cmd.startinsert()
end

M.organize = function()
  local previous_wd = vim.fn.getcwd(0)
  vim.cmd.lcd(options.brain_directory)

  local brain_logs = vim.fn.globpath(options.brain_directory, "*")

  if not (brain_logs and #brain_logs > 0) then
    vim.notify("Nothing in brain directory", vim.log.levels.INFO)
    return
  end

  local success, error = pcall(vim.cmd.arglocal, "*")
  if not success then
    vim.cmd.lcd(previous_wd)
    vim.notify("Could not open files in brain directory: " .. error, vim.log.levels.ERROR)
  end
end

M.add = function(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local date = get_date()
  local new_buf = vim.api.nvim_create_buf(false, false)

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  vim.api.nvim_buf_set_lines(new_buf, 0, -1, false, { date.pretty, "", unpack(lines) })

  local path = vim.api.nvim_buf_get_name(buf)
  local filename = vim.fn.fnamemodify(path, ":t")

  vim.api.nvim_buf_call(new_buf, function()
    vim.cmd.cd(options.brain_directory)
    vim.cmd.write(filename)
  end)

  vim.api.nvim_buf_delete(new_buf, {})
end

return M
