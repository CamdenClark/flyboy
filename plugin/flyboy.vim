command! -range=% -nargs=1 FlyboyEditLines lua require('flyboy.edit').edit_lines(<line1>, <line2>, <f-args>)
command! FlyboyStartChat lua require('flyboy.chat').create_chat()
command! FlyboySendChatMessage lua require('flyboy.chat').send_message()
