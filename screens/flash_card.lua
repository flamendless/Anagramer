local class = require("modules.classic.classic")
local flash_card = class:extend()
local vec = require("modules.hump.vector")

local padding
local timer = 3

function flash_card:new(msg)
	padding = 16 * game.ps
	local g = state.current():getCard()
	self.msg = string.upper(msg) or ""
	self.pos = vec(g.x, game.height - 64 * game.ps)
	self.target = vec(g.x, g.y + g.h + padding)
	self.size = vec(g.w, g.h/2)
	self.color = {material.colors("red","A400")}
	self.alpha = 0
	self.font = material.roboto("display1")
	self.card = {
		x = self.pos.x, y = self.pos.y, w = self.size.x, h = self.size.y
	}
	self.card.p = material.roundrect(
		self.card.x, self.card.y,self.card.w,self.card.h,2,2
	)
	
	flux.to(self.pos,timer,{
			x = self.target.x,
			y = self.target.y
		}
	):onupdate(function()
		self.card = {
			x = self.pos.x, y = self.pos.y, w = self.size.x, h = self.size.y
		}
		self.card.p = material.roundrect(
			self.card.x,self.card.y,self.card.w,self.card.h,2,2
		)
	end)
	flux.to(self,timer,{
			alpha = 255
		}
	)
end

function flash_card:update(dt)

end

function flash_card:draw()
	love.graphics.setColor(255,255,255,255)
	love.graphics.setColor(self.color[1],self.color[2],self.color[3],self.alpha)
	custom.rectangle.card(self.card, self.card.p)
	love.graphics.setColor(0,0,0,self.alpha)
	love.graphics.setFont(self.font)
	love.graphics.print(self.msg, 
		(self.card.x + self.size.x/2) - self.font:getWidth(self.msg)/2,
		(self.card.y + self.size.y/2) - self.font:getHeight(self.msg)/2
	)

end

return flash_card
