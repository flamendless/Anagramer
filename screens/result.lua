local class = require("modules.classic.classic")
local result = class:extend()
local vec = require("modules.hump.vector")
local ResultCard = require("screens.result_cards")

--card properties
--card.id (int)
--card.content (table)
--card.nResult(#card.content)(int)

local padding = 32
local _rad
local list_colors = {
	"red","pink","purple","deep-purple","indigo","blue","cyan","teal","lime","yellow","amber","orange"
}
local getRandomColor = function()
	local n = math.floor(math.random(1,#list_colors))
	local random = list_colors[n]
	--table.remove(list_colors,n)
	return {material.colors(random,"400")}
end
local sqr = function(n)
	return n*n
end
local check = function(t)
	for k,v in pairs(t) do print(k,v) end
end
local count = function(t)
	local n = 0
	for k,v in pairs(t) do n = n + 1 end
	return n
end
local findWidest = function(t)
	local temp = ""
	for k,v in pairs(t) do
		if #v > #temp then temp = v end
	end
	return temp
end

function result:enter(previous)
	local str = self._id .. "-Letter Words"
	game.appbar:change(str)
	game.appbar:changeIcon("keyboard-return")
	game.appbar:activateSortButton()
	self.previous = previous
end

function result:new(card)
	self.pool = {}
	self.mx,self.my,self.tx,self.ty = 0,0,0,0
	self.translate_x, self.translate_y = 0,0
	self.isScroll = false
	appbar = game.appbar
	self.bar = appbar.barHeader
	self._card = card
	self._id = card.id
	self.contents = self._card.content
	self:sort(self.contents,"a-z")
	self.result_number = count(self.contents)
	self.color1 = getRandomColor()
	self.color2 = getRandomColor()
	local wh = game.height/game.ps
	if wh < 720 then
		self.font = material.roboto("headline")
	elseif wh < 960 then
		self.font = material.roboto("display1")
	elseif wh < 1024 then
		self.font = material.roboto("display2")
	elseif wh < 1280 then
		self.font = material.roboto("display3")
	else
		self.font = material.roboto("display4")
	end
	self.txt_widest = findWidest(self.contents)
	self.pos = vec(16 * game.ps, self.bar.h + 16 * game.ps)
	self.size = vec(
		--self.font:getWidth(self.txt_widest) + padding * game.ps,
		game.width - self.pos.x * 2,
		self.font:getHeight("") + padding * game.ps)
	self.pool = self:generate({})
	self.isScrolling = false

	_rad = game.height/20
	self.buttonDown = material.ripple.circle(
		game.width - _rad - 24 * game.ps,
		game.height/2 + _rad*4 + 32,
		_rad
	)
	self.buttonUp = material.ripple.circle(
		game.width - _rad - 24 * game.ps,
		game.height/2 + _rad*2,
		_rad
	)
	self.buttonUp.circle.ty = self.buttonUp.circle.y
	self.buttonDown.circle.ty = self.buttonDown.circle.y
end

function result:sort(t,sort)
	if sort == "a-z" then
		table.sort(t, function(a,b)
			return a < b
		end)
	elseif sort == "z-a" then
		table.sort(t, function(a,b)
			return a > b
		end)
	end
end

function result:sort_(t,sort)
	local new_pool = {}
	self:sort(self.contents, sort)
	self.pool = self:generate(new_pool)
end

function result:update(dt)
	for _,result_card in pairs(self.pool) do
		if result_card.update then result_card:update(dt) end
	end
end

function result:keypressed(key)
	local dy
	local amount = game.height/2
	local time = 0.75
	if self.isScroll then
		if key == "s" or key == "down" then
			dy = self.translate_y - amount
		elseif key == "w" or key == "up" then
			dy = self.translate_y + amount
		end
		if dy then
			if self.isScrolling then
				time = 0.25
			else
				time = 0.5
			end
			local flux_move = flux.to(self,time,{
					translate_y = dy
				}
			):ease("backinout"):onupdate(function()
				self.isScrolling = true
				if flux_move then flux_move:stop() end
				if self.translate_y < 0 then
					self.translate_y = 0
				elseif self.translate_y > self.maxTranslate - game.height/2 then
					self.translate_y = self.maxTranslate - game.height/2
				end
			end):oncomplete(function()
				self.isScrolling = false
			end)
		end
	end
	if key == "escape" then
		transitions.random(self.previous,"once")
	end
end

function result:mousepressed(x,y,b)
	local mx,my = x/game.ratio, y/game.ratio
	self.mx = mx
	self.my = my
	custom.collisions.circle(mx,my,self.buttonUp.circle,function()
		--self.buttonUp:start(mx,my,material.colors("red","A200"))
		self:keypressed("s")
	end)
	custom.collisions.circle(mx,my,self.buttonDown.circle,function()
		--self.buttonDown:start(mx,my,material.colors("red","A200"))
		self:keypressed("w")
	end)
end

function result:mousereleased(x,y,b)
	local mx,my = x/game.ratio, y/game.ratio
	custom.collisions.circle(mx,my,self.buttonUp.circle,function()
		self.buttonUp:fade()
	end)
	custom.collisions.circle(mx,my,self.buttonDown.circle,function()
		self.buttonDown:fade()
	end)
end

function result:touchpressed(id,x,y,dx,dy,p)
	local tx,ty = x/game.ratio, y/game.ratio
	self.tx = tx
	self.ty = ty
	custom.collisions.circle(tx,ty,self.buttonUp.circle,function()
		--self.buttonUp:start(tx,ty,material.colors("red","A200"))
		self:keypressed("s")
	end)
	custom.collisions.circle(tx,ty,self.buttonDown.circle,function()
		--self.buttonDown:start(tx,ty,material.colors("red","A200"))
		self:keypressed("w")
	end)
end

function result:touchreleased(id,x,y,dx,dy,p)
	local tx,ty = x/game.ratio, y/game.ratio
	custom.collisions.circle(tx,ty,self.buttonUp.circle,function()
		self.buttonUp:fade()
	end)
	custom.collisions.circle(tx,ty,self.buttonDown.circle,function()
		self.buttonDown:fade()
	end)
end

function result:touchmoved(id,x,y,dx,dy,p)
end

function result:draw()
	love.graphics.push()
	love.graphics.translate(self.translate_x,-self.translate_y)
	love.graphics.setColor(255,255,255,255)
	for _,result_card in pairs(self.pool) do
		if result_card.draw then result_card:draw() end
	end
	love.graphics.pop()
	if self.isScroll then
		love.graphics.setColor(material.colors("teal","A700"))
		material.fab(self.buttonUp.circle.x,self.buttonUp.circle.y,_rad,2)
		material.fab(self.buttonDown.circle.x,self.buttonDown.circle.y,_rad,2)
		self.buttonUp:draw()
		self.buttonDown:draw()
		love.graphics.push()
		love.graphics.scale((game.ps/1.5),(game.ps/1.5))
		material.icons.draw("arrow-up-bold-circle-outline",
			self.buttonUp.circle.x/(game.ps/1.5),
			self.buttonUp.circle.y/(game.ps/1.5)
		)
		material.icons.draw("arrow-down-bold-circle-outline",
			self.buttonDown.circle.x/(game.ps/1.5),
			self.buttonDown.circle.y/(game.ps/1.5)
		)
		love.graphics.pop()
	end
end

function result:generate(t)
	local gridW = math.floor((game.width - 80 * game.ps)/self.size.x)
	local xx = 0
	local yy = 0
	local maxW = 0
	for i = 0, self.result_number-1 do
		local n = (i%2) + 1
		local x,y
		y = self.pos.y + ((self.size.y + 8 * game.ps) * i)
		x = self.pos.x
		if i == self.result_number-1 then
			self.isScroll = y >= game.height - 128 * game.ps
			self.maxTranslate = y + 128 * game.ps
		end
		local txt = self.contents[i+1]
		local color = self["color" .. tostring(n)]
		local card = ResultCard({
			x=x,y=y,size=self.size,font=self.font,txt=txt,color=color})
		table.insert(t,card)
	end
	return t
end

function result:leave()
	self.translate_y = 0
	game.appbar:deactivateSortButton()
end

return result
