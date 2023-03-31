local chat = require('flyboy.chat')
local openai = require('flyboy.openai')
local mock = require('luassert.mock')
local match = require('luassert.match')
local stub = require('luassert.stub')


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

describe('create_chat', function()
	it('opens a new buffer with chat in it', function()
		-- Call the function with a range of lines and a new string
		chat.create_chat()

		-- Assert that the selected lines were replaced with the expected string
		local expected_lines = { "# User", "" }
		local actual_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		assert.are.same(expected_lines, actual_lines)
	end)
end)

describe('send_message', function()
	it('sends the correct user message to the openai endpoint', function()
		-- Call the function with a range of lines and a new string
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { "# User", "Some content", "Second line" })
		mock.new(openai, true)
		chat.send_message()

		assert
		    .stub(openai.get_chatgpt_completion)
		    .was_called_with(match.table({ { role = "user", content = "Some content\nSecond line" } }), match.is_function())
	end)
	it('shows a loading state while we wait for output', function()
		-- Call the function with a range of lines and a new string
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { "# User", "Some content", "Second line" })
		mock.new(openai, true)
		openai.get_chatgpt_completion.returns(nil)
		mock(vim.api)
		chat.send_message()

		assert.stub(vim.api.nvim_buf_set_lines).was_called_with(match.number(), match.number(), match.number(), false,
			match.table({ "# Assistant", "..." }))
	end)
	it('multi-turn chats are sent as expected', function()
		-- Call the function with a range of lines and a new string
		vim.api.nvim_buf_set_lines(0, 0, -1, false,
			{
				"# User", "Some content", "Second line", "",
				"# Assistant", "test", "",
				"# User", "Second user message"
			})
		mock.new(openai, true)
		chat.send_message()

		assert
		    .stub(openai.get_chatgpt_completion)
		    .was_called_with(match.table({
		            { role = "user", content = "Some content\nSecond line" },
		            { role = "assistant", content = "test" },
		            { role = "user", content = "Second user message" },
		    }), match.is_function())
	end)
end)
