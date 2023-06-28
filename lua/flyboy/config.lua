local M = {}

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
        end,
        filetype = function()
                return vim.bo.filetype
        end,
        path = function()
                return vim.api.nvim_buf_get_name(0)
        end,
}

local templates = {
        blank = {
                template_fn = function(_)
                        return "# User"
                end
        },
        visual = {
                template_fn = function(sources_table)
                        return "# User\n" .. sources_table.visual()
                end
        },
        visual_with_prompt = {
                template_fn = function(sources_table)
                        return "# User\n"
                            .. sources_table.prompt("Prompt to add before selection context: ") .. "\n"
                            .. sources_table.visual()
                end
        },
}

local defaults = {
        templates = templates,
        sources = sources,
        model = "gpt-3.5-turbo",
        temperature = 1
}

M.options = {}

function M.setup(options)
        M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
end

function M.switch_model(model)
        M.options.model = model
end

function M.set_temperature(temperature)
        local temp = tonumber(temperature)
        if temp == nil then
                error("Temperature setting must be a number between 0 and 2: can't interpret " ..
                        temperature .. " as a number")
                return
        end
        if (temp < 0 or temp > 2) then
                error("Temperature setting must be a number between 0 and 2")
                return
        end
        M.options.temperature = temp
end

M.setup()

return M
