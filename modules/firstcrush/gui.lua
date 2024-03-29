local fc = {
	_AUTHOR = "Brandon Blanker Lim-it @flamendless",
	_DESCRIPTION = "A simple gui window with two options, perfect for yes or no dialogue box",
	_VERSION = "0.1",
}

local thread = [[
	local isRunning = true
	while (isRunning) do
		if love.thread.getChannel("state"):pop() == false then
			print("stopped")
			isRunning = false
			break
		end
	end
]]

local version = 255
local dpi = love.window.getDPIScale()
if love.system.getOS() == "Android" then
	dpi = dpi * 0.5
end

local count = 1
local button_count = 1
local cursor = 0
local getColor = function()
	local c = {}
	for i = 1, 3 do
		local max = 255/version
		c[i] = math.random(0,max)
	end
	return c
end

local point_to_rect = function(mx,my, x,y,w,h)
	return mx > x and mx <= x + w and my > y and my <= y + h
end

function fc:show()
	self.state = true
end

function fc:hide()
	self.state = false
	if self.onFinished then self.onFinished() end
end

local SHOW_GDPR = true

function fc:GDPR_check()
	if love.filesystem.getInfo("gdrp") then
		local _gdrp = love.filesystem.read("gdrp")
		if _gdrp == "accept" then
			SHOW_GDPR = false
		end
	end
end

function fc:validate()
	if love.filesystem.getInfo("gdrp") then
		local _g = love.filesystem.read("gdrp")
		return _g
	end
end

function fc:GDPR_init(fn)
	if SHOW_GDPR == false then return end
	self.onFinished = fn or function() end
	self:addWindow()
	self:addButton("I Agree", function()
			love.filesystem.write("gdrp", "accept")
			self:hide()
		end)
	self:addButton("I Refuse", function()
			love.filesystem.write("gdrp", "refuse")
			self:hide()
		end)
	self:show()
	self:start()
end

function fc:init(color)
	math.randomseed(os.time())
	self.text = "\tThe game wishes to display ads. Allowing ads will help the developer earn income. If you want to support the game, please accept.\n\n\t The ads to be displayed will not use any of your personal data. This is a consensus in compliance with the GDPR.\n\n\tYou can revoke the consent anytime by going to game settings"
	self.font = love.graphics.newFont(16 * dpi)
	self.padding = 16
	self.isShow = false

	self.buttons = {}

	self.windows = {}
	local base = {}
	base.count = count
	base.x = 32
	base.y = 32
	base.w = love.graphics.getWidth() - (base.x * 2)
	base.h = love.graphics.getHeight() - (base.y * 2)
	base.color = color or {77/version, 77/version, 77/version, 155/version}

	self:registerWindow(base)
	self:GDPR_check()
end

function fc:registerWindow(w)
	self.windows[count] = w
	count = count + 1
end

function fc:registerButton(b, current)
	self.buttons[button_count] = b

	if button_count == 1 then
		local b = self.buttons[1]
		b.x = current.x + current.w/2 - b.w/2
	else
		local b_left = self.buttons[1]
		local b_right = self.buttons[2]
		if b_left then
			b_left.x = current.x + current.w/4 - b_left.w/2
		end
		if b_right then
			b_right.x = current.x + current.w/2 + current.w/4 - b_right.w/2
		end
	end

	button_count = button_count + 1
end

function fc:addWindow()
	local w = {}
	w.count = count
	w.x = 32 + (self.padding * count)
	w.y = 32 + (self.padding * count)
	w.w = love.graphics.getWidth() - (w.x * 2)
	w.h = love.graphics.getHeight() - (w.y * 2)
	w.color = {255/version, 255/version, 255/version, 255/version}

	self:registerWindow(w)
end

function fc:addButton(text, fn)
	local current = self.windows[count - 1]
	local b = {}
	b.text = text
	b.callback = fn or function() end
	b.index = button_count
	b.isHover = false
	b.w = current.w/4
	b.h = current.h/8
	b.x = 0
	b.y = current.y + current.h - b.h - self.padding * 2
	b.hoverColor = {255/version,0,0,125/version}
	b.color = {77/version,77/version,77/version,255/version}

	self:registerButton(b, current)
end

function fc:update(dt)
	if #self.buttons > 0 then
		local mx, my = love.mouse.getPosition()
		for k,btn in pairs(self.buttons) do
			btn.isHover = false
			if point_to_rect(mx,my, btn.x,btn.y,btn.w,btn.h) then
				cursor = btn.index
				btn.isHover = true
			end
			if btn.isHover and cursor == btn.index then
				btn.isHover = true
			end
		end
	end
	if self.thread then
		if self.thread:isRunning() then
			self.channel:push(self.state)
		end
	end
end

function fc:start()
	local t = love.thread.newThread(thread)
	local c = love.thread.getChannel("state")
	t:start()
	self.thread = t
	self.channel = c
end

function fc:draw()
	if not self.state then return end
	love.graphics.push()
	love.graphics.origin()
	love.graphics.setColor(255/version,255/version,255/version,255/version)
	for k,v in pairs(self.windows) do
		love.graphics.setColor(v.color)
		love.graphics.rectangle("fill", v.x, v.y, v.w, v.h)
		--print text
		if v.count == count - 1 then
			love.graphics.setColor(0,0,0,255/version)
			love.graphics.setFont(self.font)
			love.graphics.printf(self.text, v.x + self.padding, v.y + self.padding * 2, v.w - self.padding * 2)
		end
	end
	for k,v in pairs(self.buttons) do
		if v.isHover then love.graphics.setColor(v.hoverColor)
		else love.graphics.setColor(v.color)
		end
		love.graphics.rectangle("fill", v.x, v.y, v.w, v.h)
		if v.text then
			love.graphics.setColor(255/version,255/version,255/version,255/version)
			love.graphics.setFont(self.font)
			love.graphics.print(v.text,
				v.x + v.w/2 - self.font:getWidth(v.text)/2,
				v.y + v.h/2 - self.font:getHeight(v.text)/2)
		end
	end

	love.graphics.setColor(255/version,255/version,255/version,255/version)
	love.graphics.pop()
end

function fc:mousepressed(mx,my,mb,istouch)
	if not self.state then return end
	if #self.buttons > 0 then
		for k,v in pairs(self.buttons) do
			if mb == 1 or istouch then
				if v.isHover then v.callback() end
			end
		end
	end
end

function fc:touchpressed(id,tx,ty)
	if not self.state then return end
	if #self.buttons > 0 then
		for k,v in pairs(self.buttons) do
			if point_to_rect(tx,ty, v.x,v.y,v.w,v.h) then
				cursor = v.index
				v.callback()
			end
		end
	end
end

function fc:getState()
	return self.state
end

return fc
