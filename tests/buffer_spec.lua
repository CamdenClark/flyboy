local buffer = require('flyboy.buffer')

describe('replace_lines', function()
	it('correctly replaces the lines in a buffer', function()
		-- Set up the test environment
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { "Line 1", "Line 2", "Line 3", "Line 4" })
		-- Call the function with a range of lines and a new string
		buffer.replace_lines(2, 3,
			"This is an arbitrary string\nthat might have\na different number of lines\nthan the original selection.")

		-- Assert that the selected lines were replaced with the expected string
		local expected_lines = { "Line 1", "This is an arbitrary string", "that might have", "a different number of lines",
			"than the original selection.", "Line 4" }
		local actual_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		assert.are.same(expected_lines, actual_lines)
	end)
end)
