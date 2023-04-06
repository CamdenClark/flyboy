# flyboy.nvim

Flyboy is a plugin for lightweight interaction with ChatGPT.

It works by using a simple markdown format, as follows:

```markdown
# User

Who was the 1st president of the United States?

# Assistant

George Washington

# User

...
```

This makes it really easy to:

1. Start chats
1. Save chats
1. Edit conversations in line
1. Have multi-turn conversations

Flyboy also supports configuring custom templates and data sources, so you can support prompts like the following:

```markdown
# User

Write a unit test in Lua for the following code
<Your code here>
```

## Requirements

1. Put your `OPENAI_API_KEY` as an environment variable

```
export OPENAI_API_KEY=""
```

2. Have curl installed on your machine

3. Install `plenary.nvim` and `flyboy.nvim` using your package manager:

For example, using plug

```
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

// open a chat buffer with the current text selected in visual mode
:FlyboyOpen visual
```

These functions open a new chat window and automatically send the message to the
assistant. Best used with a template.

```vim
// starts a chat session with the current text selected in visual mode
:FlyboyStart visual
:FlyboyStartSplit visual
:FlyboyStartVSplit visual
```

Finally, at any time, you can send a message:

```vim
:FlyboySendMessage
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

[nvim-lua-guide]: https://github.com/nanotee/nvim-lua-guide
[plenary]: https://github.com/nvim-lua/plenary.nvim
