local curl = require('plenary.curl')

local function get_chatgpt_completion(messages)
	local completions = curl.post("https://api.openai.com/v1/chat/completions",
		{
			headers = {
				Authorization = "Bearer " .. vim.env.OPENAI_API_KEY,
				content_type = "application/json"
			},
			body = vim.fn.json_encode(
				{
					model = "gpt-3.5-turbo",
					messages = messages
				})
		})
	if (completions) then
		return vim.fn.json_decode(completions.body)
	end
	return nil
end

local function get_code_edit(input, instruction)
	local edits = curl.post("https://api.openai.com/v1/edits",
		{
			headers = {
				Authorization = "Bearer " .. vim.env.OPENAI_API_KEY,
				content_type = "application/json"
			},
			body = vim.fn.json_encode(
				{
					model = "code-davinci-edit-001",
					input = input,
					instruction = instruction
				})
		})
	if (edits) then
		return vim.fn.json_decode(edits.body)
	end
	return nil
end

return {
	get_chatgpt_completion = get_chatgpt_completion,
	get_code_edit = get_code_edit

}