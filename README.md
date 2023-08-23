# flyboy

Flyboy is a plugin for lightweight interaction with ChatGPT.

<!-- markdownlint-disable-next-line no-bare-urls -->
https://github.com/CamdenClark/flyboy/assets/11891578/3e3fdf5d-25cc-4691-bf25-0abd0a228424

It works by using a simple Markdown format, as follows:

```markdown
# User

Who was the 1st president of the United States?

# Assistant

George Washington

# User
```

This makes it easy to:

1. Start chats
1. Save/share chats
1. Edit conversations in line
1. Have multi-turn conversations

No popups that take over your screen, flyboy operates on any buffer.

Flyboy also supports configuring custom templates, so you can go straight from
your buffer to ChatGPT with context:

```markdown
# User

Write a unit test in Lua for the following code
<Your code from visual selection here>
```


## Installation

1. Put your `OPENAI_API_KEY` as an environment variable

```bash
export OPENAI_API_KEY=""
```

2. Have curl installed on your machine

3. Install `plenary.nvim` and `flyboy` using your package manager:

For example, using plug

```vim
Plug 'nvim-lua/plenary.nvim'
Plug 'CamdenClark/flyboy'
```

## Usage

`:FlyboyOpen` functions open a new chat window. Split opens in a horizontal split,
while VSplit opens in a vertical split. They optionally take a template.

```vim
:FlyboyOpen
:FlyboyOpenSplit
:FlyboyOpenVSplit

" open a chat buffer with the current text selected in visual mode
:FlyboyOpen visual
```

`:FlyboyStart` functions open a new chat window and automatically send the message to the
assistant. You need to provide a template or the first message sent will be blank.

```vim
" starts a chat session with the current text selected in visual mode
:FlyboyStart visual
:FlyboyStartSplit visual
:FlyboyStartVSplit visual
```

To send a message:

```vim
:FlyboySendMessage
```

The response from the Assistant will be streamed back to the same buffer.

## Configuration

### Templates

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

#### Visual selection

Flyboy supports adding something you've selected in visual mode to the contents
of a prompt:

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

#### Buffer selection

Flyboy supports adding the contents of your current buffer to a prompt:

```lua
require('flyboy.config').setup({
  templates = {
    unit_test_buffer = {
      template_fn = function(sources)
          return "# User\n"
            .. "Write unit tests for the code in the following file:\n"
            .. sources.buffer()
      end
      -- :FlyboyStart unit_test_buffer
      -- Output:
      -- # User
      -- Write a unit test for the following
      -- <Your previous buffer's contents>
    }
  }
})
```

### Alternative models: gpt-3.5-turbo-16k / gpt-4 / gpt-4-32k

If you want to use Flyboy with a different model in OpenAI, call setup with the model:

```lua
require('flyboy.config').setup({
  -- ...
  model = "gpt-4"
})
```

To change on the fly, call `:FlyboySwitchModel gpt-4`

### Alternative endpoints (Azure OpenAI)

Flyboy supports configuring the URL and headers with a different endpoint that shares API compatibility (IE: Azure OpenAI)
with OpenAI, here's a reference implementation:

```lua
require('flyboy.config').setup({
  -- should be like "$AZURE_OPENAI_ENDPOINT/openai/deployments/gpt-35-turbo/chat/completions?api-version=2023-07-01-preview"
  url = vim.env.AZURE_OPENAI_GPT4_URL,
  headers = { 
    Api_Key = vim.env.AZURE_OPENAI_GPT4_KEY,
    Content_Type = "application/json"
  }
})
```

where you put the values for `AZURE_OPENAI_GPT4_URL` and `AZURE_OPENAI_GPT4_KEY` in the environment.

If you want to be able to switch URLs based on model, you should make some lua functions in your
init.lua that are bound to re-call setup with the updated URL and API key.


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
