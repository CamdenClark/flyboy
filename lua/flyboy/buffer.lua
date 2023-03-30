local function replace_lines(start_line, end_line, new_string)
  -- Get the selected lines as a table
  local selected_lines = {}
  for line_num=start_line, end_line do
    table.insert(selected_lines, vim.api.nvim_buf_get_lines(0, line_num-1, line_num, false)[1])
  end

  local new_lines = vim.split(new_string, "\n")
  vim.api.nvim_buf_set_lines(0, start_line-1, end_line, false, new_lines)
end


return {
	replace_lines = replace_lines
}
