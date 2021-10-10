local class= require("modules.classic.classic")
local appbar = class:extend()
local drawer = require("screens.drawer")

local _h, _rad

function appbar:change(t)
	self.strTitle = string.upper(t)
end

function appbar:changeIcon(str)
	self.icon = str
end

function appbar:reset()
	self.strTitle = string.upper("anagramer")
	self.icon = "menu"
end

function appbar:sortChange()
	if self.canSort then
		if self.sortIconCurrent == self.sortIconZA then
			self.sortIconCurrent = self.sortIconAZ
			state.current():sort_(state.current().pool, "a-z")
		elseif self.sortIconCurrent == self.sortIconAZ then
			self.sortIconCurrent = self.sortIconZA
			state.current():sort_(state.current().pool, "z-a")
		end
		self.canSort = false
		timer.after(1, function()
			self.canSort = true
		end)
	end
end

function appbar:activateSortButton()
	self.isSortButton = true
end

function appbar:deactivateSortButton()
	self.isSortButton = false
end

function appbar:new(current)
	self.icon = "menu"
	self.strTitle = string.upper("anagramer")
	if love.system.getOS() == "Android" then
		self.fontTitle = material.roboto("display1")
	else
		self.fontTitle = material.roboto("title")
	end
	_h = self.fontTitle:getHeight(self.strTitle) * 2

	self.barHeader = {
		x = 0,
		y = 0,
		w = game.width,
		h = _h
	}
	_rad = self.barHeader.h/3

	self.fabMenu = material.ripple.circle(
		_rad + 16 * game.ps,
		self.barHeader.y + self.barHeader.h/2,
		_rad
	)
	self.fabMenu.circle.ty = self.fabMenu.circle.y

	--sort button
	self.isSortButton = false
	self.canSort = true
	self.sortIconAZ = "sort-ascending"
	self.sortIconZA = "sort-descending"
	self.sortIconCurrent = self.sortIconAZ
	self.sortButton = material.ripple.circle(
		game.width - (_rad + 16 * game.ps),
		self.barHeader.y + self.barHeader.h/2,
		_rad
	)
	self.sortButton.circle.ty = self.sortButton.circle.y

	--screens.hook(self, current)
	game.appbar = self
	game.drawer = drawer(self)
end

function appbar:update(dt)
	self.fabMenu:update(dt)
	if self.isSortButton then
		self.sortButton:update(dt)
	end
end

function appbar:draw()
	--bar header
	love.graphics.setColor(material.colors("teal","800"))
	custom.rectangle.bar(self.barHeader)
	love.graphics.setColor(material.colors("teal", "A700"))
	material.fab(
		self.fabMenu.circle.x,
		self.fabMenu.circle.y,
		_rad,
		3
	)
	if self.isSortButton then
		material.fab(
			self.sortButton.circle.x,
			self.sortButton.circle.y,
			_rad,
			3
		)
	end
	self.fabMenu:draw()
	if self.isSortButton then
		self.sortButton:draw()
	end
	love.graphics.push()
	love.graphics.scale(game.ps/1.5,game.ps/1.5)
	material.icons.draw(self.icon,
		self.fabMenu.circle.x/(game.ps/1.5),
		self.fabMenu.circle.y/(game.ps/1.5)
	)
	if self.isSortButton then
		material.icons.draw(self.sortIconCurrent,
			self.sortButton.circle.x/(game.ps/1.5),
			self.sortButton.circle.y/(game.ps/1.5)
		)
	end
	love.graphics.pop()
	--title
	love.graphics.setColor(material.colors.mono("white","headline"))
	love.graphics.setFont(self.fontTitle)
	custom.print.header(self.strTitle,self.fontTitle,0,self.barHeader.h)
	if game.drawer then
		if game.drawer:getStatus() then
			--blur
			love.graphics.setColor(0,0,0,150/255)
			love.graphics.rectangle("fill",0,0,game.width,game.height)
		end
	end
end

function appbar:pressed(mx,my)
	local current = state.current().id
	self.fabMenu:start(mx,my,material.colors("red","A200"))
	if state.current().id == "menu" or
		state.current().id == "help" or
		state.current().id == "about" then
		if game.drawer then
			game.drawer:show()
		end
	end
	if current == "result" then
		state.current():keypressed("escape")
	end
end
function appbar:released()
	self.fabMenu:fade()
	if self.isSortButton then
		self.sortButton:fade()
	end
end

function appbar:mousepressed(x,y,button)
	local mx,my = x/game.ratio, y/game.ratio
	custom.collisions.circle(mx,my,self.fabMenu.circle,function()
		self:pressed(mx,my)
	end)
	if self.isSortButton then
		custom.collisions.circle(mx,my,self.sortButton.circle,function()
			self:sortChange()
		end)
	end
end

function appbar:mousereleased(x,y,button)
	local mx,my = x/game.ratio, y/game.ratio
	self:released()
end

function appbar:touchpressed(id,x,y,dx,dy,p)
	local mx,my = x/game.ratio, y/game.ratio
	custom.collisions.circle(mx,my,self.fabMenu.circle,function()
		self:pressed(mx,my)
	end)
end

function appbar:touchreleased(id,x,y,dx,dy,p)
	local mx,my = x/game.ratio, y/game.ratio
	if self.isSortButton then
		custom.collisions.circle(mx,my,self.sortButton.circle, function()
			self:sortChange()
		end)
	end
	self:released()
end

return appbar
