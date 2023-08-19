local mock = require('luassert.mock')
local match = require('luassert.match')

local openai = require('flyboy.openai')
local config = require('flyboy.config')

local completion_response = {
    id = "chatcmpl-123",
    object = "edit",
    created = 1677652288,
    choices = { {
        message = {
            role = "assistant",
            content = "Output"
        },
        index = 0
    } },
    usage = {
        prompt_tokens = 9,
        completion_tokens = 12,
        total_tokens = 21
    }
}

describe('ChatGPT call', function()
    local testCurl = require('plenary.curl')
    it('uses the correct API key and body', function()
        local curl = mock(testCurl, true)
        local env = mock(vim.env, true)
        local on_delta = function(_)
        end

        env.OPENAI_API_KEY = "test"

        curl.post.returns({ body = vim.fn.json_encode(completion_response) })

        openai.get_chatgpt_completion(
            config.options,
            { { role = "system", content = "Say hello!" } },
            on_delta)

        assert.stub(curl.post).was_called_with("https://api.openai.com/v1/chat/completions", match.table({
            headers = {
                ['Content-Type'] = 'application/json',
                ['Authorization'] = 'Bearer test'
            },
            body = vim.fn.json_encode({
                messages = { { role = "system", content = "Say hello!" } },
                model = "gpt-3.5-turbo"
            }),
            stream = on_delta
        })
        )
    end)
end)

describe('Test configuring azure openai', function()
    local testCurl = require('plenary.curl')
    it('uses the correct API key and body', function()
        local curl = mock(testCurl, true)
        local env = mock(vim.env, true)
        local on_delta = function(_)
        end

        env.AZURE_OPENAI_API_KEY = "test"

        config.setup({
            endpoint = "https://custom.com/chat",
            headers = {
                api_key = 'foo',
                content_type = 'application/json'
            }
        })

        curl.post.returns({ body = vim.fn.json_encode(completion_response) })

        openai.get_chatgpt_completion(
            config.options,
            { { role = "system", content = "Say hello!" } },
            on_delta)

        assert.stub(curl.post).was_called_with("https://custom.com/chat", match.table({
            headers = {
                ['Content-Type'] = 'application/json',
                ['Api-Key'] = 'foo'
            },
            body = vim.fn.json_encode({
                messages = { { role = "system", content = "Say hello!" } },
                model = "gpt-3.5-turbo"
            }),
            stream = on_delta
        })
        )
    end)
end)
