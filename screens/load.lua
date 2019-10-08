local class = require("modules.classic.classic")
local loading = class:extend()

local newStr
local str = {
	"LOADING THE BRAIN", "SETTING UP VOCABULARY",
	"GETTING STARTED WITH SPELLING", "WARMING UP SYNONYMS",
	"ASKING WEBSTER ABOUT MERRIAM", "ASKING MERRIAM ABOUT WEBSTER",
	"DEFINE PATIENCE", "DEFINE DEFINITION", "WHAT IS A WORD?",
	"HOW DO YOU SPELL SPELL?"
}
local timerString, timerDone
local timetonext = 0

function loading:new()
	self.spinnerRadius = game.width/8
	self.spinner = material.spinner.new(self.spinnerRadius,10 * game.ps,0.5)
	if love.system.getOS() == "Android" then
		--self.fontLoading = material.roboto("display1")
		--self.fontFooter = material.roboto("display1")
		self.fontLoading = material.roboto("title")
		self.fontFooter = material.roboto("title")
	else
		self.fontLoading = material.roboto("title")
		self.fontFooter = material.roboto("title")
	end
	self.strFooter = "by Brandon"
end

function loading:init()
	love.graphics.setDefaultFilter("nearest", "nearest")
	love.keyboard.setTextInput(false)
	math.randomseed(os.time())
end

function loading:enter(previous,...)
	algo:initDictionary()
	self.strLoading = newStr()

	timerString = timer()
	timerString:every(1.5, function()
		self.strLoading = newStr()
	end)
	timerDone = timer()
	timerDone:after(timetonext, function()
		transitions.random(screens.menu)
	end)
end

function loading:update(dt)
	if not algo.isDone then
		algo:updateSetup(dt)
	else
		timerDone:update(dt)
	end
	timerString:update(dt)
	self.spinner:update(dt)
end

function loading:draw()
	love.graphics.setBackgroundColor(material.colors.background("dark"))
	love.graphics.setColor(255,255,255,255)
	love.graphics.setColor(material.colors.mono("white", "title"))
	love.graphics.setFont(self.fontLoading)
	custom.print.center(self.strLoading, self.fontLoading,0,self.spinnerRadius*2 + 32 * game.ps)
	love.graphics.setFont(self.fontFooter)
	custom.print.footer(self.strFooter, self.fontFooter,0,32 * game.ps)
	self.spinner:draw(game.width/2, game.height/2 - 64 * game.ps)
end

newStr = function()
	local r = math.floor(math.random(1,#str))
	return string.upper(str[r])
end

return loading
