command! FlyboyOpen lua require('flyboy.chat').open_chat()
command! FlyboyOpenSplit lua require('flyboy.chat').open_chat_split()
command! FlyboyOpenVSplit lua require('flyboy.chat').open_chat_vsplit()
command! -range=% -nargs=1 FlyboyOpenTemplate lua require('flyboy.chat').open_chat_template_buf(<f-args>)
command! -range=% -nargs=1 FlyboyOpenTemplateSplit lua require('flyboy.chat').open_chat_template_split(<f-args>)
command! -range=% -nargs=1 FlyboyOpenTemplateVSplit lua require('flyboy.chat').open_chat_template_vsplit(<f-args>)

command! FlyboySendMessage lua require('flyboy.chat').send_message()

command! -range=% -nargs=1 FlyboyEditLines lua require('flyboy.edit').edit_lines(<line1>, <line2>, <f-args>)
