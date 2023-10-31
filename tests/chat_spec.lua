local chat = require('flyboy.chat')
local openai = require('flyboy.openai')
local config = require('flyboy.config')
local mock = require('luassert.mock')

describe('open_chat', function()
    it('opens a new buffer with chat in it', function()
        -- Call the function with a range of lines and a new string
        chat.open_chat()

        -- Assert that the selected lines were replaced with the expected string
        local expected_lines = { "# User", "" }
        local actual_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        assert.are.same(expected_lines, actual_lines)
    end)
end)

describe('open_chat visual', function()
    it('opens a new buffer with selected text as a chat', function()
        -- Set up a fake selection, starting on line 3, column 3, and ending on line 5, column 4
        local selected_lines = { "hello world", "example", "some text", "more text here", "and here" }
        vim.api.nvim_command('enew')
        vim.api.nvim_buf_set_lines(0, 0, -1, false, selected_lines)
        -- luacheck: ignore
        vim.fn.getpos = function(mark)
            if (mark == "'<") then
                return { 0, 2, 2 }
            else
                return { 0, 3, 7 }
            end
        end

        -- Call the function to create a chat from the selection
        local buffer = chat.open_chat("visual")
        -- Assert that the new buffer was created and contains the expected chat text
        local expected_text = "# User\nxample\nsome t\n"
        local actual_text = table.concat(vim.api.nvim_buf_get_lines(buffer, 0, -1, false), "\n")
        assert.are.same(expected_text, actual_text)
    end)
end)

describe('open_chat with custom config', function()
    it('uses the config template to open a chat', function()
        config.setup({
            templates = {
                sample = {
                    template_fn = function(_)
                        return "# User\nTest"
                    end
                }
            }
        })

        -- Call the function to create a chat from the selection
        local buffer = chat.open_chat("sample")
        -- Assert that the new buffer was created and contains the expected chat text
        local expected_text = "# User\nTest\n"
        local actual_text = table.concat(vim.api.nvim_buf_get_lines(buffer, 0, -1, false), "\n")
        assert.are.same(expected_text, actual_text)
    end)
    it('uses the config source and template to open a chat', function()
        config.setup({
            sources = {
                a = function()
                    return "Test"
                end
            },
            templates = {
                sample = {
                    template_fn = function(sources)
                        return "# User\n" .. sources.a()
                    end
                }
            }
        })

        -- Call the function to create a chat from the selection
        local buffer = chat.open_chat("sample")
        -- Assert that the new buffer was created and contains the expected chat text
        local expected_text = "# User\nTest\n"
        local actual_text = table.concat(vim.api.nvim_buf_get_lines(buffer, 0, -1, false), "\n")
        assert.are.same(expected_text, actual_text)
    end)
end)

local function completion_delta(delta)
    return {
        id = "chatcmpl-123",
        object = "edit",
        created = 1677652288,
        choices = { {
            delta = {
                content = delta
            },
            index = 0
        } },
        usage = {
            prompt_tokens = 9,
            completion_tokens = 12,
            total_tokens = 21
        }
    }
end

local function test_completion(start_content, chat_gpt_output, expected_loading, expected_after)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, start_content)
    mock.new(openai, true)

    openai.get_chatgpt_completion = function(_, _, on_delta, on_complete)
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        assert.are.same(expected_loading, lines)

        for _, delta in ipairs(chat_gpt_output) do
            on_delta(completion_delta(delta))
        end
        on_complete()
    end

    chat.send_message()

    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    assert.are.same(expected_after, lines)
end

describe('send_message', function()
    it('sends the correct user message to the openai endpoint', function()
        test_completion(
            { "# User", "Some content", "Second line" },
            { "Output" },
            {
                "# User", "Some content", "Second line", "",
                "# Assistant", "..."
            },
            {
                "# User", "Some content", "Second line", "",
                "# Assistant", "Output", "",
                "# User", ""
            })
    end)
    it('multi-turn chats are sent as expected', function()
        test_completion(
            {
                "# User", "Some content", "Second line", "",
                "# Assistant", "test", "",
                "# User", "Second user message"
            },
            { "Output" },
            {
                "# User", "Some content", "Second line", "",
                "# Assistant", "test", "",
                "# User", "Second user message", "",
                "# Assistant", "..."
            },
            {
                "# User", "Some content", "Second line", "",
                "# Assistant", "test", "",
                "# User", "Second user message", "",
                "# Assistant", "Output", "",
                "# User", ""
            })
    end)
    it('multiline assistant messages get handled correctly', function()
        test_completion(
            { "# User", "Some content", "Second line" },
            { "Hello ", "World", "\n", "Foo", " Bar" },
            {
                "# User", "Some content", "Second line", "",
                "# Assistant", "..."
            },
            {
                "# User", "Some content", "Second line", "",
                "# Assistant", "Hello World", "Foo Bar", "",
                "# User", ""
            })
    end)
    it('calling a configured on_complete function works', function ()
        local called = false

        config.setup({ on_complete = function () called = true end })

        vim.api.nvim_buf_set_lines(0, 0, -1, false, { "# User", "Foo" })
        mock.new(openai, true)

        openai.get_chatgpt_completion = function(_, _, on_delta, on_complete)
            for _, delta in ipairs({ "# Assistant", "Hello world"}) do
                on_delta(completion_delta(delta))
            end
            on_complete()
        end

        chat.send_message()

        assert.are.same(true, called)
    end)
end)
