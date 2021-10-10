local class = require("modules.classic.classic")
local card = class:extend()
local vec = require("modules.hump.vector")
local screen_result = require("screens.result")

local getRandomColor
local sqr = function(n)
	return n*n
end

local equiv = {
	[3] = "three",
	[4] = "four",
	[5] = "five",
	[6] = "six",
	[7] = "seven"
}
local pos = {}
local colors = {}
local list_colors = {
	"red","pink","purple","deep-purple","indigo","blue","cyan","teal","lime","yellow","amber","orange"
}

local padding
local time = 0.75

function card:new(id, contents)
	self.debug_x, self.debug_y = 0,0
	padding = 24 * game.ps
	self.isClicked = false
	for i = 3, 7 do
		local n = math.floor(math.random(1,#list_colors))
		local random = list_colors[n]
		colors[i] = {material.colors(random,"400")}
	end
	self.id = id
	self.group = equiv[id]
	self.content = contents
	self.nResult = #contents
	config.save(config.getLog(),"RESULT OF "
		.. tostring(self.id) .. " : " .. self.nResult)
	local g = state.current():getCard()
	self.w = (g.w/3) - padding
	self.h = ((game.height - g.h - g.y)/3) - padding

	self.maxPos = vec(g.x,g.y + g.h + padding)
	self.maxSize = vec(g.w,g.h/2)

	if love.system.getOS() == "Android" then
		if self.h > 100 then
			self.font = material.roboto("display4")
		elseif self.h > 60 then
			self.font = material.roboto("display3")
		elseif self.h > 30 then
			self.font = material.roboto("display2")
		else
			self.font = material.roboto("display1")
		end
	else
		self.font = material.roboto("display3")
	end

	self.font_small = material.roboto("caption")

	local row
	if id >= 3 and id <= 5 then
		row = padding
	else
		row = self.h + padding * 2
	end
	pos = {
		[3] = vec(padding/2, row),
		[4] = vec(self.w+padding+padding/2, row),
		[5] = vec(self.w*2+(padding*2)+padding/2, row),
		[6] = vec(padding/2, row),
		[7] = vec(self.w+(padding)+padding/2, row)
	}
	self.x = g.x
	self.y = g.y + g.h

	self.card = {
		x = self.x, y = self.y, w = self.w, h = self.h
	}
	self.card.p = material.roundrect(
		self.card.x,self.card.y,self.card.w,self.card.h,2*game.ps,2*game.ps
	)
	self.card.ripple = material.ripple.custom(function()
		love.graphics.polygon("fill",unpack(self.card.p))
		love.graphics.polygon("line",unpack(self.card.p))
	end, (sqr(self.card.w) + sqr(self.card.h))^0.5)
	self.target = pos[id]
	self.color = colors[id]
	self.isMouseHover = false
	self.hasRippled = false
	self.rippleColor = getRandomColor()
	self.isDone = false
	self.immediate = false

	self.flux = flux.to(self.card, time, {
			x = self.x + self.target.x,
			y = self.y + self.target.y
		}
	):onupdate(function()
		self.card.p = material.roundrect(
			self.card.x,self.card.y,self.card.w,self.card.h,
			2*game.ps,2*game.ps
		)
	end):oncomplete(function()
		self.isDone = true
	end)
end

function card:quick()
	flux.to(self.card,0.5, {
			x = self.x + self.target.x,
			y = self.y + self.target.y
		}
	):onupdate(function()
		self.card.p = material.roundrect(
			self.card.x,self.card.y,self.card.w,self.card.h,
			2*game.ps,2*game.ps
		)
	end):oncomplete(function()
		self.isDone = true
	end)
end

function card:update(dt)
end

function card:draw()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setColor(self.color[1],self.color[2],self.color[3],self.color[4])
	if self.isMouseHover then
		love.graphics.setColor(material.colors.mono("black","disabled"))
	end
	custom.rectangle.card(self.card,self.card.p)
	love.graphics.setColor(0,0,0,self.color[4])
	if self.isMouseHover then
		love.graphics.setColor(material.colors.mono("white","disabled"))
	end

	local cy = (self.card.y + self.card.h/2) - self.font:getHeight(self.id) + 16
	love.graphics.setFont(self.font)
	love.graphics.print(self.id,
		(self.card.x + self.card.w/2) - self.font:getWidth(self.id)/2, cy
	)

	love.graphics.setFont(self.font_small)
	local txt = "letters word"
	love.graphics.print("letters word",
		(self.card.x + self.card.w/2) - self.font_small:getWidth(txt)/2,
		cy + self.font:getHeight(self.id) + 8
	)

	love.graphics.setColor(self.rippleColor)
	self.card.ripple:draw()

	if _debug then
		love.graphics.setColor(255,0,0,255)
		love.graphics.line(0,self.debug_y,game.width,self.debug_y)
		love.graphics.line(self.debug_x,0,self.debug_x,game.height)
	end
end

function card:mousepressed(x,y,b,istouch)
	local mx,my = x/game.ratio,y/game.ratio
	if b == 1 then
		if mx > self.card.x and mx < self.card.x + self.w and
			my > self.card.y and my < self.card.y + self.h then
			self.immediate = true
		end
	end
end

function card:mousereleased(x,y,b,istouch)
	local mx,my = x/game.ratio,y/game.ratio
	if b == 1 then
		if mx > self.card.x and mx < self.card.x + self.w and
			my > self.card.y and my < self.card.y + self.h then
			if self.isDone and not self.isClicked then
				transitions.random(screen_result,self)
			end
		end
	end
	self.card.ripple:fade()
end

function card:touchreleased(id,x,y,dx,dy,p)
	local mx,my = x/game.ratio,y/game.ratio
	if mx > self.card.x and mx < self.card.x + self.w and
		my > self.card.y and my < self.card.y + self.h then
		--self.immediate = true
		self.card.ripple:fade()
	end
end

function card:touchpressed(id,x,y,dx,dy,p)
	local mx,my = x/game.ratio, y/game.ratio
	if mx > self.card.x and mx < self.card.x + self.w and
		my > self.card.y and my < self.card.y + self.h then
		self.immediate = true
		if self.isDone then
			transitions.random(screen_result,self)
		end
		self.card.ripple:fade()
	end
	self.debug_x, self.debug_y = 0,0
end

getRandomColor = function()
	local n = math.floor(math.random(1,#list_colors))
	local random = list_colors[n]
	return {material.colors(random,"400")}
end

return card
