local chat = require('flyboy.chat')
local openai = require('flyboy.openai')
local mock = require('luassert.mock')


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

local function test_completion(start_content, chat_gpt_output, expected_loading, expected_after)
	vim.api.nvim_buf_set_lines(0, 0, -1, false, start_content)
	mock.new(openai, true)

	openai.get_chatgpt_completion = function(_, callback)
		local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		assert.are.same(expected_loading, lines)

		callback(chat_gpt_output)
	end

	chat.send_message()

	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

	assert.are.same(expected_after, lines)
end

describe('send_message', function()
	it('sends the correct user message to the openai endpoint', function()
		test_completion(
			{ "# User", "Some content", "Second line" },
			completion_response,
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
			completion_response,
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
end)
