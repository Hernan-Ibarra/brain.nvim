# brain.nvim

Write down ideas before they vanish, without disrupting your workflow.

## Use

The `:Brain Log` command is basically `:tabnew` but writing the buffer will

- add a timestamp to the file;
- prompt you to choose a filename or go with a default one; and
- save the file to the 'brain directory'.

Running `:Brain Organize` will append everything in the 'brain directory' to the local argument list (see [:h argument-list](https://neovim.io/doc/user/editing.html#_3.-the-argument-list) and [:h :arglocal](https://neovim.io/doc/user/editing.html#_local-argument-list)). Move through your notes with `:next` and `:prev`.

When you are done with a file run `:Brain Delete` to delete the file and close the buffer.

You can add a file to your brain directory with `:Brain Add`.

## Configuration
