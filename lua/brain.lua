local M = {}

---@class brain.Options
---@field brain_directory string

local data_dir = vim.fn.stdpath("data")

---@type brain.Options
local options = {
  ---@cast data_dir string
  brain_directory = data_dir .. "/brain",
}

---@param opts? brain.Options
M.setup = function(opts)
  options = vim.tbl_deep_extend("force", options, opts or {})
end

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

local prompt_for_filename = function()
  local prompt_buf = vim.api.nvim_create_buf(false, true)
  assert(prompt_buf ~= 0, "Failed to prompt for filename")

  vim.api.nvim_set_option_value("buftype", "prompt", { buf = prompt_buf })
  vim.api.nvim_set_option_value("filetype", "text", { buf = prompt_buf })

  vim.fn.prompt_setprompt(prompt_buf, "Enter filename: ")

  local width = math.floor(vim.o.columns * 0.8)
  local height = 2
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = "Brain Log",
  }

  local prompt_win = vim.api.nvim_open_win(prompt_buf, true, win_opts)
  vim.cmd.startinsert()

  vim.fn.prompt_setcallback(prompt_buf, function(input)
    vim.api.nvim_win_close(prompt_win, true)
    vim.api.nvim_buf_delete(prompt_buf, { force = true })

    if not (input and input ~= "") then
      return
    end

    assert(input:sub(1, 1) ~= "/", "Error: filename cannot begin with root '/'")

    return input
  end)
end

M.log = function()
  local success, err = pcall(function()
    vim.cmd("$tabnew")
  end)

  if not success then
    print("Error opening new tab: " .. err)
    return
  end

  success, err = pcall(function()
    vim.cmd.tcd(options.brain_directory)
  end)

  if not success then
    print("Could not find brain directory: " .. err)
  end

  local date = os.date()
  local buf = vim.api.nvim_get_current_buf()
  ---@cast date string
  vim.api.nvim_buf_set_name(buf, date)

  vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = buf,
    callback = function()
      ---@cast date string
      vim.api.nvim_buf_set_lines(buf, 0, 0, true, { date })

      local filename = prompt_for_filename()
      filename = filename or vim.api.nvim_buf_get_name(buf)

      local brain_dir = options.brain_directory
      local brain_dir_last_char = brain_dir:sub(#brain_dir, #brain_dir)
      if brain_dir_last_char ~= "/" then
        brain_dir = brain_dir .. "/"
      end

      vim.api.nvim_buf_set_name(buf, brain_dir .. filename)
    end,
    once = true,
  })
end

return M
