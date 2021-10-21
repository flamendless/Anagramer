function love.conf(t)
	game = {}
	user = {}
	_test = false

	t.modules = {
		ads = true,
		data = true,
		event = true,
		keyboard = true,
		mouse = true,
		timer = true,
		joystick = true,
		touch = true,
		image = true,
		graphics = true,
		audio = true,
		math = true,
		physics = true,
		sound = true,
		system = true,
		font = true,
		thread = true,
		window = true,
		video = true,
	}

	t.window.width = 480
	t.window.height = 640
	t.window.icon = "assets/logo_128.png"

	t.external = true
	t.externalstorage = true
	t.identity = "Anagramer"
	t.resizable = false
	t.console = true
	io.stdout:setvbuf("no")
end

