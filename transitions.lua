overlay = {
	x = -game.width, y = -game.height * 2,
	w = game.width, h = game.height * 2,
}

transitions = {}
transitions.list = {}
local transition_done = true

transitions.random = function(next_screen,arg)
	local ns = next_screen
	if transition_done then
		local r = math.floor(math.random(1))
		transitions.list[r](ns,arg)
		transition_done = false
	end
end

transitions.swipe = function(nextScreen,arg)
	local time = 0.25
	local dir = -1
	overlay.x = -game.width
	overlay.y = 0
	state.current().isReady = false
	flux.to(overlay,time,{
			x = 0
		}
	):oncomplete(function()
		if arg ~= "once" then
			state.switch(nextScreen(arg))
		else
			state.switch(nextScreen)
		end
		nextScreen.isReady = false
	end):after(overlay,time,{
			x = game.width * dir
		}
	):oncomplete(function()
		state.current().isReady = true
		transition_done = true
	end)
end

for k,v in pairs(transitions) do
	if type(v) == "function" and tostring(k) ~= "random" then
		table.insert(transitions.list,v)
	end
end


transitions.draw = function()
	love.graphics.setColor(0,0,0,255)
	love.graphics.rectangle("fill",
		overlay.x,overlay.y,overlay.w,overlay.h)
end

