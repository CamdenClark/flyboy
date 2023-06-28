command! -range=% -nargs=* FlyboyOpen lua require('flyboy.chat').open_chat(<f-args>)
command! -range=% -nargs=* FlyboyOpenSplit lua require('flyboy.chat').open_chat_split(<f-args>)
command! -range=% -nargs=* FlyboyOpenVSplit lua require('flyboy.chat').open_chat_vsplit(<f-args>)

command! -range=% -nargs=* FlyboyStart lua require('flyboy.chat').start_chat(<f-args>)
command! -range=% -nargs=* FlyboyStartSplit lua require('flyboy.chat').start_chat_split(<f-args>)
command! -range=% -nargs=* FlyboyStartVSplit lua require('flyboy.chat').start_chat_vsplit(<f-args>)

command! FlyboySendMessage lua require('flyboy.chat').send_message()

command! -nargs=1 FlyboySwitchModel lua require('flyboy.config').switch_model(<f-args>)
command! -nargs=1 FlyboySetTemperature lua require('flyboy.config').set_temperature(<f-args>)
