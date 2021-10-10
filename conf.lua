function love.conf(t)
	game = {}
	user = {}
	--necessary for different builds
	--ANDROID
	-- _isAPK = true
	-- _debug = false

	--IOS

	-- _isIOS = true

	--DESKTOP
	_isAPK = false
	-- _debug = false

	-- _test = true
	-- _isPro = false

	t.external = true
	t.externalstorage = true
	t.identity = "Anagramer"
	t.resizable = false

	if _debug or _test then
		t.console = true
		io.stdout:setvbuf("no")
	end
end

