function love.conf(t)
	game = {}
	user = {}
	_test = false

	t.window.width = 480
	t.window.height = 640
	t.external = true
	t.externalstorage = true
	t.identity = "Anagramer"
	t.resizable = false
	t.console = true
	io.stdout:setvbuf("no")
end

