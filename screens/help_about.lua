local class = require("modules.classic.classic")
local HelpAbout = class:extend()

local str = {
	help =
	"Anagramer is an Anagram Solver app. Anagrams are words or phrases that are created by rearranging the letters of another word or phrase.\n\nExample is the word\n 'silent', one of its anagrams is 'listen'.",
	about = "This tool is inspired by Wordscapes.\n\nCredits to:\nPositive07 for the material-love library,\nAuahDark for helping me alot,\nBartbes for helping me with the algorithm,\nMartin Fellis and bio1712 for the Android port of LOVE,\nand ofcourse, the Love2D community!\n\nThanks to the following testers:\nCristelle Dawn Francia,\nJead Vidallo,\nIan Plaus,\nLoise Astillero,\nEarl Saturay,\nCyril Elijah Aurino\n"
}


function HelpAbout:new(id)
	self.id = id
	self.font = material.roboto("title")
	self.card = {
		x = 32 * game.ps,
		y = game.appbar.barHeader.h + 48 * game.ps,
		w = game.width - 64 * game.ps,
		h = game.height - (game.appbar.barHeader.h + 48 * game.ps) * 2
	}
	self.card.p = material.roundrect(
		self.card.x,self.card.y,
		self.card.w,self.card.h,2*game.ps,2*game.ps
	)
	self.cardOutline = {
		x = self.card.x - 1,
		y = self.card.y - 1,
		w = self.card.w + 2,
		h = self.card.h + 2,
	}
	self.cardOutline.p = material.roundrect(
		self.cardOutline.x,self.cardOutline.y,
		self.cardOutline.w,self.cardOutline.h,
		2*game.ps,2*game.ps
	)
	self.str = str[self.id]
end

function HelpAbout:update(dt)

end

function HelpAbout:draw()
	love.graphics.setBackgroundColor(material.colors.background("light"))
	love.graphics.setColor(255,255,255)
	love.graphics.setColor(material.colors.background("dark"))
	custom.rectangle.card(self.cardOutline,self.cardOutline.p)
	love.graphics.setColor(material.colors.background("light"))
	custom.rectangle.card(self.card,self.card.p)
	love.graphics.setColor(material.colors.mono("black","text"))
	love.graphics.setFont(self.font)
	love.graphics.printf(self.str,
		self.card.x + 16 * game.ps,
		self.card.y + 32 * game.ps,
		self.card.w - 32 * game.ps, "center")
end

function HelpAbout:keypressed(key)
	if key == "escape" then
		transitions.random(game.menu,"once")
		game.drawer:hide()
	end
end

return HelpAbout
