local mock = require('luassert.mock')

local eq = assert.are.same

local completion_response = {
	id = "chatcmpl-123",
	object = "chat.completion",
	created = 1677652288,
	choices = { {
		index = 0,
		message = {
			role = "assistant",
			content = "\n\nHello there, how may I assist you today?",
		},
		finish_reason = "stop"
	} },
	usage = {
		prompt_tokens = 9,
		completion_tokens = 12,
		total_tokens = 21
	}
}

describe('ChatGPT call', function()
	local testCurl = require('plenary.curl')
	it('Test can access vim namespace', function()
		local curl = mock(testCurl, true)
		local env = mock(vim.env, true)

		env.OPENAI_API_KEY = "test"

		curl.post.returns({ body = vim.fn.json_encode(completion_response) } )

		local flyboy = require('flyboy.init')
		local completion = flyboy.get_chatgpt_completion({ { role = "system", content = "Say hello!" } })

		eq(completion, completion_response)
	end)
end)
