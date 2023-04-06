# flyboy.nvim

Flyboy is a plugin for lightweight interaction with ChatGPT.

It works by using a simple Markdown format, as follows:

```markdown
# User

Who was the 1st president of the United States?

# Assistant

George Washington

# User
```

This makes it really easy to:

1. Start chats
1. Save/share chats
1. Edit conversations in line
1. Have multi-turn conversations

Flyboy also supports configuring custom templates and data sources, so you can support prompts like the following:

```markdown
# User

Write a unit test in Lua for the following code
<Your code from visual selection here>
```

and automatically send them to ChatGPT for a response.

## Installation

1. Put your `OPENAI_API_KEY` as an environment variable

```bash
export OPENAI_API_KEY=""
```

2. Have curl installed on your machine

3. Install `plenary.nvim` and `flyboy.nvim` using your package manager:

For example, using plug

```vim
Plug 'nvim-lua/plenary.nvim'
Plug 'CamdenClark/flyboy'
```

## Functions

These functions open a new chat window. Split opens in a horizontal split,
while VSplit opens in a vertical split. They optionally take a

```vim
:FlyboyOpen
:FlyboyOpenSplit
:FlyboyOpenVSplit

" open a chat buffer with the current text selected in visual mode
:FlyboyOpen visual
```

These functions open a new chat window and automatically send the message to the
assistant. Best used with a template.

```vim
" starts a chat session with the current text selected in visual mode
:FlyboyStart visual
:FlyboyStartSplit visual
:FlyboyStartVSplit visual
```

Finally, at any time, you can send a message:

```vim
:FlyboySendMessage
```

## Configuration

You can configure custom sources and templates for your ChatGPT prompts.

```lua
require('flyboy.config').setup({
  sources = {
    my_source = function () return "world" end
  },
  templates = {
    my_template = {
      template_fn = function(sources) return "# User\nHello, " .. sources.my_source() end
      -- :FlyboyOpen my_template
      -- Output:
      -- # User
      -- Hello, world
    }
  }
})
```

Sources are intended to be helpers to get common pieces of data that you'd be
interested in to build your prompts to ChatGPT. Some sources are pre-created,
including `visual`, which provides the text that's visually selected.

Templates are how you construct prompts that will be sent to ChatGPT.

### Visual selection

A common thing you'd want to do is support adding something you've selected
in visual mode to the contents of a prompt. Here's how you do that.

```lua
require('flyboy.config').setup({
  templates = {
    unit_test = {
      template_fn = function(sources)
          return "# User\n"
            .. "Write a unit test for the following code:\n"
            .. sources.visual()
      end
      -- :FlyboyStart unit_test
      -- Output:
      -- # User
      -- Write a unit test for the following
      -- <Your visual selection>
    }
  }
})
```

## Development

### Run tests

Running tests requires [plenary.nvim][plenary] to be checked out in the parent directory of _this_ repository.
You can then run:

```bash
just test
```

or, more verbose:

```bash
nvim --headless --noplugin -u tests/minimal.vim -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal.vim'}"
```

Or if you want to run a single test file:

```bash
just test chat_spec.lua
```

```bash
nvim --headless --noplugin -u tests/minimal.vim -c "PlenaryBustedDirectory tests/path_to_file.lua {minimal_init = 'tests/minimal.vim'}"
```

Read the [nvim-lua-guide][nvim-lua-guide] for more information on developing neovim plugins.

[nvim-lua-guide]: https://github.com/nanotee/nvim-lua-guide
[plenary]: https://github.com/nvim-lua/plenary.nvim
