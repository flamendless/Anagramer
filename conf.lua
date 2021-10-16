function love.conf(t)
	game = {}
	user = {}
	_test = true

	t.external = true
	t.externalstorage = true
	t.identity = "Anagramer"
	t.resizable = false
	t.console = true
	io.stdout:setvbuf("no")
end

