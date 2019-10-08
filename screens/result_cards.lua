local classic = require("modules.classic.classic")
local ResultCard = classic:extend()

function ResultCard:new(t)
	for k,v in pairs(t) do
		self[k] = v
	end
	self.card = {
		x = self.x,
		y = self.y,
		w = self.size.x,
		h = self.size.y
	}
	self.card.p = material.roundrect(
		self.card.x,self.card.y,self.card.w,self.card.h,2*game.ps,2*game.ps
	)
end

function ResultCard:update(dt)

end

function ResultCard:draw()
	love.graphics.setColor(self.color)
	custom.rectangle.card(self.card,self.card.p)
	love.graphics.setFont(self.font)
	love.graphics.setColor(material.colors.mono("white"))
	love.graphics.print(self.txt,
		(self.card.x + self.card.w/2) - self.font:getWidth(self.txt)/2,
		(self.card.y + self.card.h/2) - self.font:getHeight(self.txt)/2
	)
end

return ResultCard
