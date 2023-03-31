
local openai = require('flyboy.openai')

local function edit_lines(start_line, end_line, instruction)
  -- Get the selected lines as a table
  local text_to_edit = ''
  for line_num=start_line, end_line do
    text_to_edit = text_to_edit .. vim.api.nvim_buf_get_lines(0, line_num-1, line_num, false)[1] .. '\n'
  end

  local text_after_edit = openai.get_code_edit(text_to_edit, instruction).choices[1].text

  local new_lines = vim.split(text_after_edit, "\n")
  vim.api.nvim_buf_set_lines(0, start_line-1, end_line, false, new_lines)
end


return {
	edit_lines = edit_lines
}
