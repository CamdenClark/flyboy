local openai = require('flyboy.openai')

local function create_chat()
	-- create a new empty buffer
	local buffer = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(buffer, "filetype", "markdown")

	-- switch to the new buffer
	vim.api.nvim_set_current_buf(buffer)

	-- insert some text into the buffer
	local lines = { "# User", "" }
	vim.api.nvim_buf_set_lines(buffer, 0, -1, true, lines)
end

local function parseMarkdown()
	local messages = {}
	local currentEntry = nil
	local buffer = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
	for _, line in ipairs(lines) do
		if line:match("^#%s+(.*)$") then
			local role = line:match("^#%s+(.*)$")
			if (currentEntry) then
				table.insert(messages, currentEntry)
			end
			currentEntry = {
				role = string.lower(role),
				content = ""
			}
		elseif currentEntry then
			if not (line == "") then
				if currentEntry.content == "" then
					currentEntry.content = line
				else
					currentEntry.content = currentEntry.content .. "\n" .. line
				end
			end
		end
	end
	if currentEntry then
		table.insert(messages, currentEntry)
	end

	return messages
end

local function send_message()
	local messages = parseMarkdown()

	local buffer = vim.api.nvim_get_current_buf()
	local currentLine = vim.api.nvim_buf_line_count(buffer)

	vim.api.nvim_buf_set_lines(buffer, currentLine, currentLine, false, { "# Assistant", "..." })

	local callback = function(response)
		local lines_to_add = vim.split(response.choices[1].message.content, "\n")
		table.insert(lines_to_add, 1, "# Assistant")
		table.insert(lines_to_add, 1, "")

		table.insert(lines_to_add, "")
		table.insert(lines_to_add, "# User")
		table.insert(lines_to_add, "")

		vim.api.nvim_buf_set_lines(buffer, currentLine, currentLine + 2, false, lines_to_add)
	end

	openai.get_chatgpt_completion(messages, callback)
end

return {
	create_chat = create_chat,
	send_message = send_message
}
