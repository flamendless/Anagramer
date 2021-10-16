local class = require("modules.classic.classic")
local box = class:extend()
local help_about = require("screens.help_about")

local sqr = function(n)
	return n*n
end

local function show_ty_fn()
	love.window.showMessageBox("Thank you for supporting the developer",
		"Thank you for supporting the developer",
		{ "Okay",escapebutton = 1 }
	)
end

local function show_fail_fn()
	love.window.showMessageBox("No ad is available for now. Try again later",
		"No ad is available for now. Try again later",
		{ "Okay",escapebutton = 1 }
	)
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
		love.system.openURL("http://twitter.com/flam8studio")
	end,
	RATE = function()
		love.system.openURL(game.rate_link)
	end,

	SUPPORT = function()
		adm.requestRewardedAd(ads.ads.reward)
		adm.requestInterstitial(ads.ads.inter)
		local c = love.window.showMessageBox("Suport the developer via interstitial or video ad",
			"Suport the developer via interstitial or video ad",
			{ "Interstitial","Video","Cancel",escapebutton = 3 }
		)
		if c == 1 then
			local show_ty = adm.tryShowInterstitial(nil, show_ty_fn, show_fail_fn)
			print("interstitial: " .. tostring(show_ty))
		elseif c == 2 then
			local show_ty = adm.tryShowRewardedAd(nil, show_ty_fn, show_fail_fn)
			print("rewarded: " .. tostring(show_ty))
		elseif c == 3 then
			return
		end
	end,

	EXIT = function()
		local esc = love.window.showMessageBox("Confirm Exit",
			"Are you sure you want to quit?",
			{
				"Yes","No",escapebutton = 2
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
	self.can_press = true
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

function box:mousepressed(x,y,b,istouch)
	local mx,my = x,y
	if b == 1 or istouch then
		local res = custom.collisions.box(mx,my,self.button,{0,6,0,6}, function()
			self:pressed(mx,my)
		end)
		return res
	end
end

function box:mousereleased(x,y,b,istouch)
	self.fab:fade()
	self.button.ripple:fade()
end

-- function box:touchpressed(id,x,y)
-- 	local mx,my = x,y
-- 	local res = custom.collisions.box(mx,my,self.button,{0,6,0,6}, function()
-- 		self:pressed(mx,my)
-- 	end)
-- 	return res
-- end
--
-- function box:touchreleased(id,x,y)
-- 	self.fab:fade()
-- 	self.button.ripple:fade()
-- end

return box
