local curl = require('plenary.curl')

local function get_chatgpt_completion(options, messages, on_delta, on_done)
        curl.post("https://api.openai.com/v1/chat/completions",
                {
                        headers = {
                                Authorization = "Bearer " .. vim.env.OPENAI_API_KEY,
                                content_type = "application/json"
                        },
                        body = vim.fn.json_encode(
                                {
                                        model = options.model,
                                        temperature = options.temperature,
                                        messages = messages,
                                        stream = true
                                }),
                        stream = vim.schedule_wrap(
                                function(_, data, _)
                                        local raw_message = string.gsub(data, "^data: ", "")
                                        if raw_message == "[DONE]" then
                                                on_done()
                                        elseif (string.len(data) > 6) then
                                                on_delta(vim.fn.json_decode(string.sub(data, 6)))
                                        end
                                end)
                })
end


local function get_code_edit(input, instruction, callback)
        curl.post("https://api.openai.com/v1/edits",
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
                                }),
                        callback = vim.schedule_wrap(function(response) callback(vim.fn.json_decode(response.body)) end)
                })
end

return {
        get_chatgpt_completion = get_chatgpt_completion,
        get_code_edit = get_code_edit
}
