function love.conf(t)
	game = {}
	user = {}
	--necessary for different builds
	--ANDROID
	_isAPK = true
	--_debug = false

	--IOS

	_isIOS = true
	--WINDOWS
	--_isAPK = false
	--_debug = false

	_test = false
	_isPro = false
	t.external = true
	t.externalstorage = true
	t.identity = "DATA"
	t.version = "0.10.2"
	if _debug or _test then
		t.console = true
		io.stdout:setvbuf("no")
	end
end

