function love.conf(t)
	game = {}
	user = {}
	_test = false

	if love._os == "Android" then
		t.modules.admob = true
	end

	t.modules.audio = true
	t.modules.data = true
	t.modules.event = true
	t.modules.font = true
	t.modules.graphics = true
	t.modules.image = true
	t.modules.joystick = false
	t.modules.keyboard = true
	t.modules.math = true
	t.modules.mouse = true
	t.modules.physics = false
	t.modules.sound = true
	t.modules.system = true
	t.modules.thread = true
	t.modules.timer = true
	t.modules.touch = true
	t.modules.video = false
	t.modules.window = true

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

