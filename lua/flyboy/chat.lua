local openai = require('flyboy.openai')
local config = require('flyboy.config')

local function open_chat_with_text(text)
	-- create a new empty buffer
	local buffer = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_buf_set_option(buffer, "filetype", "markdown")
	local lines = vim.split(text, "\n")

	table.insert(lines, "")
	vim.api.nvim_buf_set_lines(buffer, 0, -1, true, lines)
	return buffer
end

local function open_chat_template(template)
	if not (template) then
		template = "blank"
	end
	local final_text = config.options.templates[template]
	    .template_fn(config.options.sources)

	return open_chat_with_text(final_text)
end

local function open_chat(template)
	local chat_buffer = open_chat_template(template)

	vim.api.nvim_set_current_buf(chat_buffer)
	return chat_buffer
end

local function open_chat_split(template)
	local chat_buffer = open_chat_template(template)
	vim.cmd("sp | b" .. chat_buffer)

	vim.api.nvim_set_current_buf(chat_buffer)
	return chat_buffer
end

local function open_chat_vsplit(template)
	local chat_buffer = open_chat_template(template)
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

local function start_chat(template)
	open_chat(template)
	send_message()
end

local function start_chat_split(template)
	open_chat_split(template)
	send_message()
end

local function start_chat_vsplit(template)
	open_chat_vsplit(template)
	send_message()
end

return {
	send_message = send_message,
	open_chat = open_chat,
	open_chat_split = open_chat_split,
	open_chat_vsplit = open_chat_vsplit,
	start_chat = start_chat,
	start_chat_split = start_chat_split,
	start_chat_vsplit = start_chat_vsplit,
}
