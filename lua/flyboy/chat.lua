local openai = require('flyboy.openai')

local function create_chat_buf_with_text(text)

	-- create a new empty buffer
	local buffer = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_buf_set_option(buffer, "filetype", "markdown")

	local lines = vim.split(text, "\n")
	table.insert(lines, "")
	vim.api.nvim_buf_set_lines(buffer, 0, -1, true, lines)
	return buffer
end

local function create_chat()
	-- insert some text into the buffer
	local buffer = create_chat_buf_with_text("# User")
	vim.api.nvim_set_current_buf(buffer)
end

local function create_chat_vsplit()
	local buffer = create_chat_buf_with_text("# User")
	-- switch to the new buffer
	vim.cmd("vsp | b" .. buffer)
	vim.api.nvim_set_current_buf(buffer)
end

local function create_chat_split()
	local buffer = create_chat_buf_with_text("# User")
	-- switch to the new buffer
	vim.cmd("sp | b" .. buffer)
	vim.api.nvim_set_current_buf(buffer)
end

local sources = {
	visual = function()
		local start_pos = vim.fn.getpos("'<")
		local end_pos = vim.fn.getpos("'>")

		local start_line, start_col = start_pos[2], start_pos[3]
		local end_line, end_col = end_pos[2], end_pos[3]

		local buffer = vim.api.nvim_get_current_buf()
		local lines = vim.api.nvim_buf_get_lines(buffer, start_line - 1, end_line, false)

		-- Modify the first line to start at the correct column
		lines[1] = lines[1]:sub(start_col)

		-- Modify the last line to end at the correct column
		lines[#lines] = lines[#lines]:sub(1, end_col - 1)


		-- Join the lines into a single string
		return table.concat(lines, "\n")
	end,
	prompt = function(message)
		return vim.fn.input(message)
	end
}

local templates = {
	visual = {
		sources = { "visual" },
		template_fn = function(sources)
			return "# User\n" .. sources.visual()
		end
	},
	do_something = {
		sources = { "visual" },
		template_fn = function(sources)
			return "# User\n"
			    .. sources.prompt("Enter a thing we should do") .. "\n"
			    .. sources.visual()
		end
	},
}

local function create_chat_template(template)
	local final_text = templates[template].template_fn(sources)

	return create_chat_buf_with_text(final_text)
end

local function create_chat_template_buf(template)
	local chat_buffer = create_chat_template(template)

	vim.api.nvim_set_current_buf(chat_buffer)
	return chat_buffer
end

local function create_chat_template_split(template)
	local chat_buffer = create_chat_template(template)
	vim.cmd("sp | b" .. chat_buffer)

	vim.api.nvim_set_current_buf(chat_buffer)
	return chat_buffer
end

local function create_chat_template_vsplit(template)
	local chat_buffer = create_chat_template(template)
	vim.cmd("vsp | b" .. chat_buffer)

	vim.api.nvim_set_current_buf(chat_buffer)
	return chat_buffer
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

	vim.api.nvim_buf_set_lines(buffer, currentLine, currentLine, false, { "", "# Assistant", "..." })

	local callback = function(response)
		local lines_to_add = vim.split(response.choices[1].message.content, "\n")
		table.insert(lines_to_add, 1, "# Assistant")
		table.insert(lines_to_add, 1, "")

		table.insert(lines_to_add, "")
		table.insert(lines_to_add, "# User")
		table.insert(lines_to_add, "")

		vim.api.nvim_buf_set_lines(buffer, currentLine, currentLine + 3, false, lines_to_add)
	end

	openai.get_chatgpt_completion(messages, callback)
end

return {
	create_chat = create_chat,
	send_message = send_message,
	create_chat_split = create_chat_split,
	create_chat_vsplit = create_chat_vsplit,
	create_chat_template_buf = create_chat_template_buf,
	create_chat_template_split = create_chat_template_split,
	create_chat_template_vsplit = create_chat_template_vsplit,

}
