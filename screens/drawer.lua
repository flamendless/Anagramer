local class = require("modules.classic.classic")
local drawer = class:extend()
local box = require("screens.box")

local speed = 50
local time = 0.5
local _rad
local lines
local items = {
	"Home",
	"Help",
	"About",
	"Follow",
	"Rate",
  "Support",
	"Exit"
}
local boxes = {}

function drawer:new(appbar)
	self.isShowing = false
	self.isHiding = false
	self.isShown = false
	self.isHidden = true

	self.color = {material.colors.background("light")}
	self.width = game.width/1.5
	self.height = game.height
	self.x = -self.width
	self.y = 0

	--drawer rect
	self:rectUpdate()
	--button
	self.icon = "close"
	_rad = appbar.barHeader.h/3
	self.fab = material.ripple.circle(
		_rad + 16 * game.ps,
		appbar.barHeader.y + appbar.barHeader.h/2,
		_rad
	)
	self.fab.circle.ty = appbar.fabMenu.circle.y

	--others
	if love.system.getOS() == "Android" then
		--self.font = material.roboto("display3")
		self.font = material.roboto("display1")
	else
		self.font = material.roboto("display1")
	end

	--grids
	lines = self.height/#items
	for i = 1, lines do
		local x = 0
		local y = i * self.font:getHeight(items[0])*2
		if i > 0 and i <= #items then
			local b = box(i,string.upper(items[i]),
				x,y,
				self.width,
				self.font:getHeight(items[i]) * 2,
				appbar
			)
			table.insert(boxes,b)
		end
	end
end

function drawer:rectUpdate()
	self.rect = {
		x = self.x, y = self.y,
		w = self.width, h = self.height
	}
	self.rect.p = material.roundrect(
		self.rect.x,self.rect.y,
		self.rect.w,self.rect.h
	)
	self.rectOutline = {
		x = self.rect.x-1,
		y = self.rect.y-1,
		w = self.rect.w-1,
		h = self.rect.h-1,
	}
	self.rectOutline.p = material.roundrect(
		self.rectOutline.x,
		self.rectOutline.y,
		self.rectOutline.w,
		self.rectOutline.h,
		2*game.ps,2*game.ps
	)
end

function drawer:update(dt)
	if self.isShown then
		if boxes then
			for k,v in pairs(boxes) do
				v:update(dt)
			end
		end
		self.fab:update(dt)
		local x,y
		if love.system.getOS() == "Android" then
			local touches = love.touch.getTouches()
			for i,id in ipairs(touches) do
				local tx,ty = love.touch.getPosition(id)
				x = tx/game.ratio
				y = ty/game.ratio
			end
		else
			local mx,my = love.mouse.getPosition()
			if love.mouse.isDown(1) then
				x = mx/game.ratio
				y = my/game.ratio
			end
		end
		if x and y then
			if x > self.x + self.width then
				self:hide()
			end
		end
	end
end

function drawer:draw()
	love.graphics.setColor(material.colors.background("dark"))
	custom.rectangle.card(self.rectOutline,self.rectOutline.p)
	love.graphics.setColor(self.color)
	custom.rectangle.card(self.rect, self.rect.p)
	if self.isShown and not self.isHiding then
		love.graphics.setColor(material.colors("teal","A700"))
		material.fab(
			self.fab.circle.x, self.fab.circle.y,
			_rad, 3
		)
		self.fab:draw()
		love.graphics.push()
		love.graphics.scale((game.ps/1.5),(game.ps/1.5))
		material.icons.draw(self.icon,
			self.fab.circle.x/(game.ps/1.5),
			self.fab.circle.y/(game.ps/1.5))
		love.graphics.pop()

		--grids
		love.graphics.setColor(material.colors.mono("black","divider"))
		local y = self.fab.circle.y + _rad + 8 * game.ps
		love.graphics.line(
			0,y,
			self.width,y)
		if boxes then
			for k,v in pairs(boxes) do
				v:draw()
			end
		end
	end
end

function drawer:pressed(mx,my)
	self.fab:start(mx,my,material.colors("red","A200"))
	self:hide()
end

function drawer:keypressed(key)
	if key == "escape" then
		self:hide()
	end
end

function drawer:mousepressed(x,y,b)
	if b and self.isShown then
		local mx,my = x/game.ratio,y/game.ratio
		custom.collisions.circle(mx,my,self.fab.circle,function()
			self:pressed(mx,my)
		end)
		if boxes then
			for k,v in pairs(boxes) do
				v:mousepressed(mx,my,b)
			end
		end
	end
end

function drawer:mousereleased(x,y,b)
	local mx,my = x/game.ratio,y/game.ratio
	if self.isShown then
		self.fab:fade()
		if boxes then
			for k,v in pairs(boxes) do
				v:mousereleased(mx,my,b)
			end
		end
	end
end

function drawer:touchreleased(id,x,y)
	local mx,my = x/game.ratio,y/game.ratio
	if self.isShown then
		self.fab:fade()
		if boxes then
			for k,v in pairs(boxes) do
				v:touchreleased(id,mx,my)
			end
		end
	end
end

function drawer:touchpressed(id,x,y)
	local mx,my = x/game.ratio,y/game.ratio
	if self.isShown then
		custom.collisions.circle(mx,my,self.fab.circle,function()
			self:pressed(mx,my)
		end)
		if boxes then
			for k,v in pairs(boxes) do
				v:touchpressed(id,mx,my)
			end
		end
	end
end

function drawer:show()
	if self.isHidden and not self.isShowing then
		self.isShowing = true
		flux.to(self, time, {
				x = 0,
			}
		):onupdate(function()
				self:rectUpdate()
			end
		):oncomplete(function()
			self.isShowing = false
			self.isShown = true
			self.isHidden = false
		end)
	end
end

function drawer:hide()
	if self.isShown and not self.isHiding then
		self.isHiding = true
		flux.to(self, time, {
				x = -self.width
			}
		):onupdate(function()
				self:rectUpdate()
			end
		):oncomplete(function()
			self.isHiding = false
			self.isShown = false
			self.isHidden = true
		end)
	end
end

function drawer:getStatus()
	return self.isShowing or self.isShown
end

return drawer
