test TEST='':
	nvim --headless --noplugin -u tests/minimal.vim -c "PlenaryBustedDirectory tests/{{TEST}} {minimal_init = 'tests/minimal.vim'}"


