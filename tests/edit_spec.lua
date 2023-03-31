local edit = require('flyboy.edit')
local openai = require('flyboy.openai')
local mock = require('luassert.mock')

local edit_response = {
  object = "edit",
  created = 1589478378,
  choices = {
    {
      text = "output",
      index = 0,
    }
  },
  usage = {
    prompt_tokens = 25,
    completion_tokens = 32,
    total_tokens = 57
  }
}

describe('replace_lines', function()
	it('correctly replaces the lines in a buffer', function()
		-- Set up the test environment
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { "Line 1", "Line 2", "Line 3", "Line 4" })
		mock.new(openai, true)
		openai.get_code_edit.returns(edit_response)

		-- Call the function with a range of lines and a new string
		edit.edit_lines(2, 3, "instruction")

		-- Assert that the selected lines were replaced with the expected string
		local expected_lines = { "Line 1", "output", "Line 4" }
		local actual_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		assert.are.same(expected_lines, actual_lines)
	end)
end)
