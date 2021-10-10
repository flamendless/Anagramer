custom = require("modules.custom")
material = require("modules.material-love")
roboto = require("modules.roboto")
material.roboto = roboto
flux = require("modules.flux.flux")
lume = require("modules.lume.lume")
timer = require("modules.hump.timer")
state = require("modules.hump.gamestate")
ser = require("modules.ser")
inspect = require("modules.inspect.inspect")
config = require("config")
if love.system.getOS() == "Android" and not _isPro and _isAPK then
	ads = require("admob")
end

print("START")
love.handlers.print = print
math.randomseed(os.time())

local utf8 = require("utf8")
--local word_algo = require("algo")
local word_algo = require("algo_new")

config.init()

game.title = "Anagramer - Anagram Solver"
local platform = love.system.getOS()
if platform == "Android" then
	game.rate_link = "http://play.google.com/store/apps/details?id=brbl.wg.flam"
elseif platform == "Windows" or platform == "OS X" or platform == "Linux" then
	game.rate_link = "http://flamendless.itch.io/anagramer-anagram-solver"
end
game.ps = love.window.getDPIScale()
game.appbar = nil
game.drawer = nil
game.menu = nil
game.clock = 0

if love.system.getOS() == "Android" then
	game.width = love.graphics.getWidth() * game.ps
	game.height = love.graphics.getHeight() * game.ps
	game.ratio = math.min((love.graphics.getHeight()/game.height),
		(love.graphics.getWidth()/game.width))
else
	game.width = 480 * game.ps
	game.height = 640 * game.ps
	love.window.setMode(game.width,game.height)
	love.window.setTitle(game.title)
	local ww,wh = love.graphics.getDimensions()
	game.ratio = math.min((wh/game.height),(ww/game.width))
end

require("screens")
require("transitions")

local startScreen = screens.loading()
local menuScreen = screens.menu()
--startScreen = screens.menu

app = {}
app.typed = ""
app.min, app.max = 3, 7
app.done = false

function isEmpty(t)
	return t[1] == nil
end

local font
adm = require("modules.adm")

FC = require("modules.firstcrush.gui")

function show_ads()
	if FC:validate() == "accept" then
		if love.system.getOS() == "Android" and not _isPro and _isAPK then
			adm.init(ads.id.banner, "bottom", ads.id.inter, false)
			adm.showBanner()
		end
	end
end

function love.load()
	font = material.roboto("title")
	print("LOAD")
	algo = word_algo()
	state.registerEvents({
		"quit","focus","init","enter",
		"leave","resume",
		}
	)

	state.switch(startScreen)
	FC:init({0, 0.4, 0, 1})
	FC:GDPR_init(function()
		show_ads()
	end)

	if FC:getState() then
		FC:show()
	else
		state.switch(menuScreen)
	end
end

function love.update(dt)
	local c = state.current().id
	timer.update(dt)
	flux.update(dt)
	if FC:getState() then
		FC:update(dt)
	else
		if state.current().update then
			if state.current().isReady then
				state.current():update(dt)
			end
		end
		if game.appbar then
			game.appbar:update(dt)
		end
		if game.drawer then
			game.drawer:update(dt)
		end
	end
end

function love.draw()
	love.graphics.push()
	love.graphics.scale(game.ratio,game.ratio)
	local c = state.current().id
	if state.current().draw then
		state.current():draw()
	end
	--if screens_tbl[c] then
		--for k,v in pairs(screens_tbl[c]) do
			--if v.draw then v:draw() end
		--end
	--end
	if game.appbar then
		game.appbar:draw()
	end
	if game.drawer then
		game.drawer:draw()
	end
	transitions.draw()
	if _debug then
		love.graphics.setColor(1,0,0,1)
		love.graphics.setFont(font)
		love.graphics.print("DEBUG MODE", game.width - font:getWidth("DEBUG MODE") - 4, game.height - font:getHeight("DEBUG MODE"))
		love.graphics.setLineWidth(1)
		--love.graphics.line(game.width/2,0,game.width/2,game.height)
		love.graphics.setLineWidth(2)
		love.graphics.rectangle("line",0,0,game.width,game.height)
	end
	love.graphics.pop()
	if FC:getState() then
		FC:draw()
	end
end

function love.quit()
	algo:stop()
	print("QUIT")
	config.save(config.getLog(),"",true)
	return true
end

function love.textinput(t)
	if state.current().id == "menu" then
		if state.current():getStatus() then
			if #app.typed < app.max then
				if not state.current().isGenerating and state.current().canType then
					app.typed = string.lower(app.typed .. t)
				end
			end
		end
	end
end

function love.keyreleased(key)
	if state.current().keyreleased then
		state.current():keyreleased(key)
	end
	--if key == "escape" then
		--local esc = love.window.showMessageBox("Confirm Exit",
			--"Are you sure you want to quit?",
			--{
				--"Yes","No",escapebutton = 0
			--}
		--)
		--if esc == 1 then
			--love.event.quit()
		--end
	--end
end

function love.keypressed(key)
	if game.drawer then
		if game.drawer.keypressed then
			game.drawer:keypressed(key)
		end
	end
	if state.current().keypressed then
		state.current():keypressed(key)
	end
	if state.current().id == "menu" then
		if state.current():getStatus() and not state.current().isGenerating and state.current().canType then
  		if key == "backspace" then
    		local byteoffset = utf8.offset(app.typed, -1)
    		if byteoffset then
      		app.typed = string.sub(app.typed, 1, byteoffset - 1)
    		end
    	end
  	end
  end
end

function love.mousepressed(x,y,b,istouch)
	local c = state.current().id
	--if screens_tbl[c] then
		--for k,v in pairs(screens_tbl[c]) do
			--if v.mousepressed then v:mousepressed(x,y,b) end
		--end
	--end
	if game.appbar then
		game.appbar:mousepressed(x,y,b,istouch)
	end
	if game.drawer then
		game.drawer:mousepressed(x,y,b,istouch)
		if not game.drawer:getStatus() then
			if state.current().mousepressed then
				state.current():mousepressed(x,y,b,istouch)
			end
		end
	end
	if FC:getState() then
		FC:mousepressed(x,y,b,istouch)
	end
end

function love.mousereleased(x,y,b,istouch)
	local c = state.current().id
	--if screens_tbl[c] then
		--for k,v in pairs(screens_tbl[c]) do
			--if v.mousereleased then v:mousereleased(x,y,b) end
		--end
	--end
	if game.appbar then
		game.appbar:mousereleased(x,y,b,istouch)
	end
	if game.drawer then
		game.drawer:mousereleased(x,y,b,istouch)
		if not game.drawer:getStatus() then
			if state.current().mousereleased then
				state.current():mousereleased(x,y,b,istouch)
			end
		end
	end
end

function love.touchpressed(id,x,y,dx,dy,t)
	local c = state.current().id
	--if screens_tbl[c] then
		--for k,v in pairs(screens_tbl[c]) do
			--if v.touchpressed then v:touchpressed(id,x,y,dx,dy,t) end
		--end
	--end
	if game.appbar then
		game.appbar:touchpressed(id,x,y,dx,dy,t)
	end
	if game.drawer then
		game.drawer:touchpressed(id,x,y,dx,dy,t)
		if not game.drawer:getStatus() then
			if state.current().touchpressed then
				state.current():touchpressed(id,x,y,dx,dy,p)
			end
		end
	end
	if FC:getState() then
		FC:touchpressed(id,x,y)
	end
end

function love.touchreleased(id,x,y,dx,dy,t)
	local c = state.current().id
	--if screens_tbl[c] then
		--for k,v in pairs(screens_tbl[c]) do
			--if v.touchreleased then v:touchreleased(id,x,y,dx,dy,t) end
		--end
	--end
	if game.appbar then
		game.appbar:touchreleased(id,x,y,dx,dy,t)
	end
	if game.drawer then
		game.drawer:touchreleased(id,x,y,dx,dy,t)
		if not game.drawer:getStatus() then
			if state.current().touchreleased then
				state.current():touchreleased(id,x,y,dx,dy,p)
			end
		end
	end
end

function love.touchmoved(id,x,y,dx,dy,p)
	local c = state.current().id
	if game.drawer then
		if not game.drawer:getStatus() then
			if state.current().touchmoved then
				state.current():touchmoved(id,x,y,dx,dy,p)
			end
		end
	end
end

function love.threaderror(thread, errmsg)
	config.save(config.getLog(),"THREAD ERROR:")
	config.save(config.getLog(),tostring(os.date()))
	config.save(config.getLog(),tostring(thread) .. "\r\n" .. tostring(errmsg))
end


--CREDITS to:
--Tae Hanazono
--Bartbes
--Positive07
--and others i forgot
