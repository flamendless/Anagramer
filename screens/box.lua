local class = require("modules.classic.classic")
local box = class:extend()
local help_about = require("screens.help_about")

local sqr = function(n)
	return n*n
end

local icons = {
	HOME = "home",
	HELP = "help",
	ABOUT = "information",
	FOLLOW = "twitter",
	RATE = "star",
	SUPPORT = "help",
	EXIT = "exit-to-app",
}

local func = {
	HOME = function()
		transitions.random(screens.menu)
		game.drawer:hide()
	end,
	HELP = function()
		transitions.random(help_about("help"),"once")
		game.drawer:hide()
	end,
	ABOUT = function()
		transitions.random(help_about("about"),"once")
		game.drawer:hide()
	end,
	FOLLOW = function()
		love.system.openURL("http://twitter.com/flamendless")
	end,
	RATE = function()
		love.system.openURL(game.rate_link)
	end,
	SUPPORT = function()
		if love.system.getOS() == "Android" then
			adm.tryShowInterstitial()
			--adm.requestRewardedAd(ads.id.reward)
			--adm.tryShowRewardedAd()
			--print("initializing reward")
			--print("or initializing interstitial")
			--if _test then
				--love.ads.requestRewardedAd(ads.test.reward)
				--love.ads.requestInterstitial(ads.test.inter)
			--else
				--love.ads.requestRewardedAd(ads.id.reward)
				--love.ads.requestInterstitial(ads.id.inter)
			--end
			--if love.ads.isRewardedAdLoaded() then
				--print("show reward ad")
				--love.ads.showRewardedAd()
			--elseif love.ads.isInterstitialLoaded() then
				--print("show interstitial ad")
				--love.ads.showInterstitial()
			--end
		end
  end,
	EXIT = function()
		local esc = love.window.showMessageBox("Confirm Exit",
			"Are you sure you want to quit?",
			{
				"Yes","No",escapebutton = 0
			}
		)
		if esc == 1 then
			love.event.quit()
		end
	end,
}
local _rad

function box:new(id,str,x,y,w,h,appbar)
	self.str = string.upper(str)
	self.icon = icons[self.str]
	self.x = x
	self.y = y
	self.w = w
	self.h = h
	self.color = {material.colors.mono("black","text")}
	if love.system.getOS() == "Android" then
		--self.font = material.roboto("display3")
		self.font = material.roboto("display1")
		self.ty = self.y + self.font:getHeight(self.str)/2
	else
		self.font = material.roboto("headline")
		self.ty = self.y + self.font:getHeight(self.str)
	end
	_rad = appbar.barHeader.h/3
	self.fab = material.ripple.circle(
		_rad + 16 * game.ps,
		self.y + self.h/2,
		_rad
	)
	self.fab.circle.ty = appbar.fabMenu.circle.y
	self.button = {
		x = self.x,
		y = self.y,
		w = self.w,
		h = self.h
	}
	self:buttonUpdate()
end

function box:buttonUpdate()
	self.button.p = material.roundrect(
		self.button.x,
		self.button.y,
		self.button.w,self.button.h,2*game.ps,2*game.ps
	)
	self.button.ripple = material.ripple.custom(function()
		love.graphics.polygon("fill",unpack(self.button.p))
		love.graphics.polygon("line",unpack(self.button.p))
	end, (sqr(self.button.w) + sqr(self.button.h))^0.5)
end

function box:update(dt)
	self.fab:update(dt)
	self.button.ripple:update(dt)
end

function box:draw()
	love.graphics.setColor(self.color)
	love.graphics.setFont(self.font)
	love.graphics.print(self.str,
		self.fab.circle.x + _rad + 32 * game.ps,
		self.ty
	)

	--fab
	love.graphics.setColor(material.colors("teal","A700"))
	material.fab(self.fab.circle.x,self.fab.circle.y,
		_rad,3)
	self.fab:draw()
	love.graphics.push()
	love.graphics.scale((game.ps/1.5),(game.ps/1.5))
	material.icons.draw(self.icon,
		self.fab.circle.x/(game.ps/1.5),
		self.fab.circle.y/(game.ps/1.5)
	)
	love.graphics.pop()
	love.graphics.setColor(material.colors.mono("black","divider"))
	love.graphics.rectangle("line",
		self.x,self.y,self.w,self.h)
	self.button.ripple:draw()
end

function box:pressed(mx,my)
	self.button.ripple:start(mx,my)
	self.fab:start(self.fab.circle.x,self.fab.circle.y,material.colors("red","A200"))
	if func[self.str] then
		func[self.str]()
	end
end

function box:mousepressed(x,y,b)
	local mx,my = x,y
	if b == 1 then
		custom.collisions.box(mx,my,self.button,{0,6,0,6}, function()
			self:pressed(mx,my)
		end)
	end
end

function box:mousereleased(x,y,b)
	self.fab:fade()
	self.button.ripple:fade()
end

function box:touchpressed(id,x,y)
	local mx,my = x,y
end

function box:touchreleased(id,x,y)
	self.fab:fade()
	self.button.ripple:fade()
	local mx,my = x,y
	custom.collisions.box(mx,my,self.button,{0,6,0,6}, function()
		self:pressed(mx,my)
	end)
end

return box
