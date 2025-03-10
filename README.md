# 🧠 brain.nvim

Write down ideas before they vanish, without disrupting your workflow.

## Use

The 'brain directory' (configurable) is the place where all your fleeting thoughts will live until you have time for them.

The `:BrainLog` command is basically `:$tabnew` but it

- sets the tab-local working directory to be the brain directory (see [:h 22.2](https://neovim.io/doc/user/usr_22.html#_tab-local-directory))
- adds a timestamp to the file on write.

Running `:BrainOrganize` will set the local argument list to be everything in the brain directory (see [:h 07.2](https://neovim.io/doc/user/usr_07.html#_a-list-of-files), [:h argument-list](https://neovim.io/doc/user/editing.html#_3.-the-argument-list), and [:h :arglocal](https://neovim.io/doc/user/editing.html#_local-argument-list)). Move through your notes with `:next` and `:prev`.

You can add a current buffer to your brain directory with `:BrainAdd`.

## Configuration

Everything should work out of the box. If you want to change the brain directory, here is how to do it with [lazy](https://github.com/folke/lazy.nvim)

```lua
{
  "Hernan-Ibarra/brain.nvim",
  -- This is the default; no need to call opts.
  opts = {
    -- Use absolute, fully expanded paths
    brain_directory = vim.fn.stdpath("data") .. "/brain"
  }
}
```

## Tips

Here are some tips for using this plugin. I didn't include these commands as part of the plugin because they are helpful in Neovim more generally. The Lua snippets are part of my own configuration.

### Overwrite default filename

After `:BrainLog`, the new buffer will use the current date as a filename. You can use `:wq` when you are done writing to go back to your previous buffer.

If you want to change the name of the buffer and write it at the same time, use `:saveas`. Here is a typical workflow.

```vim
:BrainLog
" Write my brilliant idea about dogs
:sav dogs.txt | q
```

Note that `:w dogs.txt | q` would not have worked. To save on keystrokes you could define a user command that does this.

<details>
<summary>Click for command (Lua)</summary><!-- --+ -->

```lua
local save_and_quit = function(opts)
  vim.cmd.saveas {
    args = { opts.fargs[1] },
    bang = opts.bang,
  }
  vim.cmd.quit { bang = opts.bang }
end

vim.api.nvim_create_user_command('Squit', save_and_quit, {
  nargs = 1,
  desc = 'Save and quit the current buffer under a different filename',
  complete = 'file',
})
```

<!-- --_ -->
</details>

### Delete and move on

When moving through your notes with `:BrainOrganize` you may think a note is no longer relevant. In that case you want to delete the file and the buffer. You can do this in one Ex command (four, really).

```vim
:call delete(expand('%')) | argdelete % | silent! prev | bdelete! #
```

If you find yourself using this frequently, you can again define a user command. To delete all of your notes you can either delete everything in the brain directory or do something like the following.

```vim
:BrainOrganize
:argdo call delete(expand('%'))
:qa
```

<details>
<summary>Click for command (Lua)</summary><!-- --+ -->

```lua
local delete_current_file_and_buffer = function(opts)
  local buf = vim.api.nvim_get_current_buf()
  local buf_name = vim.api.nvim_buf_get_name(buf)

  if (not buf_name) or buf_name == '' then
    vim.notify('Buffer not associated to a file', vim.log.levels.ERROR)
    return
  end

  if (not opts.bang) and vim.api.nvim_get_option_value('confirm', {}) then
    local message = 'Delete file ' .. vim.fn.fnamemodify(buf_name, ':t') .. '?\nBuffer will be deleted too!'
    local choice = vim.fn.confirm(message, '&Yes\n&No', 0, 'Question')
    if choice ~= 1 then
      return
    end
  end

  local delete_success = (vim.fn.delete(buf_name) == 0)

  if not delete_success then
    vim.notify('Deletion of file' .. buf_name .. ' was unsuccessful.\nAborting...', vim.log.levels.ERROR)
    return
  end

  local arglist_length = vim.fn.argc()
  local arglist_index = vim.fn.argidx()

  local argdelete_success, _ = pcall(function()
    vim.cmd.argdelete '%'
  end)

  vim.api.nvim_buf_delete(buf, { force = true })

  if (not argdelete_success) or arglist_length <= 1 then
    return
  end

  if arglist_index >= arglist_length - 1 then
    vim.cmd.first()
    return
  end

  vim.cmd.argument(arglist_index + 1)
end

vim.api.nvim_create_user_command('DelThis', delete_current_file_and_buffer, {
  desc = 'Delete the current file and buffer',
})
```

<!-- --_ -->
</details>
