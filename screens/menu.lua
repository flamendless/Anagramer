local class = require("modules.classic.classic")
local menu = class:extend()

local sqr, count, countAll, getLastIndex
local cards = {}
local _x = 32
local _diff = 24
local _btnH, _btnW
local numResult = 0

local ads_counter = 0
local show_counter = 1
local show_rate = 0

function menu:enter(previous)
	if count(cards) > 0 then
		for k,v in pairs(cards) do
			v.isClicked = false
			v.isMouseHover = false
		end
	end
	if love.system.getOS() == "Android" and not _isPro and _isAPK then
		ads_counter = ads_counter + 1
		show_ads()
		--love.ads.showBanner()
		--show interstitial every other 3 times
		--if ads_counter % 3 == 0 then
			--if _test then
				--love.ads.requestInterstitial(ads.test.inter)
			--else
				--love.ads.requestInterstitial(ads.id.inter)
			--end
			--print("Interstitial ready: " .. tostring(love.ads.isInterstitialLoaded()))
			--if love.ads.isInterstitialLoaded() then
				--love.ads.showInterstitial()
				--print("Interstitial should have loaded ..")
			--end
		--end
	end
	appbar:reset()
	--create rate popup
	if previous.id == "result" and user.isRated == false then
		if show_rate % 3 == 0 then
			timer.after(0.5, function()
				local window_rate = love.window.showMessageBox("Support",
					"Enjoying the app? Rate it :) ",
					{
						"Like It", "Later", escapebutton = 0
					}
				)
				if window_rate == 1 then
					love.system.openURL(game.rate_link)
					print(game.rate_link)
					user.isRated = true
					config.user(true)
				end
				show_rate = show_rate + 1
			end)
		end
	end
end

function menu:new()
	appbar = screens.appbar()
	self.isGenerating = false
	self.isTyping = false
	self.canGenerate = false
	self.cleanup_count = 0
	self.barHeader = appbar.barHeader
	self.cardTitle = {
		x = _x * game.ps,
		y = self.barHeader.h + _diff * game.ps,
		w = game.width - _x * 2 * game.ps,
		h = game.height/4
	}

	self.txt1 = {}
	if love.system.getOS() == "Android" then
		self.txt1.font = material.roboto("display2")
	else
		self.txt1.font = material.roboto("headline")
	end
	self.txt1.str = string.upper("Type Below")
	self.txt1.default = string.upper("Type Below")
	self.txt1.str2 = string.upper("GENERATING. PLEASE WAIT")
	self.txt1.str3 = string.upper("RESULT: " .. numResult)
	self.txt1.str4 = string.upper("CLEANING UP")
	self.txt1.x = game.width/2 - self.txt1.font:getWidth(self.txt1.str)/2
	self.txt1.y = self.cardTitle.y + _diff * game.ps

	self.div1 = {}
	self.div1.x = self.cardTitle.x + _diff * game.ps
	self.div1.x2 = self.cardTitle.x + self.cardTitle.w - 16 * game.ps
	self.div1.y = self.txt1.y + self.txt1.font:getHeight(self.txt1.str) + 8 * game.ps

	self.input = {}
	self.input.str = ""
	if love.system.getOS() == "Android" then
		self.input.font = material.roboto("display1")
	else
		self.input.font = material.roboto("headline")
	end
	self.input.x = game.width/2

	self.cursor = {}
	self.cursor.x = game.width/2
	self.cursor.y = self.div1.y + 16 * game.ps
	self.input.y = self.cursor.y
	self.cursor.y2 = self.cursor.y + self.input.font:getHeight("")

	self.div2 = {}
	self.div2.y = self.cursor.y2 + 16 * game.ps

	self.textbox = {}
	self.textbox.x = self.cardTitle.x
	self.textbox.y = self.div1.y
	self.textbox.w = self.cardTitle.w
	self.textbox.h = self.div2.y - self.div1.y

	self.cursor.alpha = 1
	self.cursor.timer = timer()
	self.cursor.timer:every(0.5, function()
		local t = 0.25
		if self.cursor.alpha >= 1 then
			flux.to(self.cursor,t,{alpha=0})
		elseif self.cursor.alpha <= 0 then
			flux.to(self.cursor,t,{alpha=1})
		end
	end)

	self.button = {
		y = (self.cardTitle.y + self.cardTitle.h)/2 + 8 * game.ps,
		txt = "TAP HERE", txt2 = "GENERATE WORDS",
		pressed = false, txtDraw = true,
		colorButton = {material.colors("cyan","800")},
		colorText = {material.colors.mono("white")},
		colorButtonDisabled = {material.colors.mono("black","disabled")},
		colorTextDisabled = {material.colors.mono("white","disabled")}
	}

	self.button.font = material.roboto("button")
	_btnH = 32
	_btnW = 64

	self.button.colorButtonDraw = self.button.colorButton
	self.button.colorTextDraw = self.button.colorText
	self.button.h = self.button.font:getHeight(self.button.txt) + _btnH
	self.button.w = self.button.font:getWidth(self.button.txt) + _btnW
	self.button.x = game.width/2 - self.button.w/2
	self:buttonUpdate()

	self.btnClose = {
		w = (self.div2.y - self.div1.y)/2,
		h = (self.div2.y - self.div1.y)/2
	}
	self.btnClose.y = math.floor((self.div1.y + self.div2.y)/2 - self.btnClose.h/2)
	self.btnClose.x = self.div1.x2 - self.btnClose.w/2 - 16 * game.ps
	self.btnClose.p = material.roundrect(self.btnClose.x,self.btnClose.y,
		self.btnClose.w,self.btnClose.h,2*game.ps,2*game.ps)
	self.btnClose.ripple = material.ripple.custom(function()
		love.graphics.polygon("fill",unpack(self.btnClose.p))
		love.graphics.polygon("line",unpack(self.btnClose.p))
	end, (sqr(self.btnClose.w) + sqr(self.btnClose.h))^0.5)

	self:cardUpdate()

	local _rad = game.width/12
	self.spinner = material.spinner.new(_rad * game.ps ,24 * game.ps,0.5)
	game.menu = self
end

function menu:switchColor()
	if self.button.colorButtonDraw == self.button.colorButton then
		if #app.typed < 3 or self.isGenerating then
			self.button.colorButtonDraw = self.button.colorButtonDisabled
			self.button.colorTextDraw = self.button.colorTextDisabled
			self.canGenerate = false
		end
	else
		if #app.typed > 2 and not self.isGenerating then
			self.button.colorButtonDraw = self.button.colorButton
			self.button.colorTextDraw = self.button.colorText
			self.canGenerate = true
		end
	end
end

function menu:update(dt)
	self.input.str = string.upper(app.typed)
	self.txt1.x = game.width/2 - self.txt1.font:getWidth(self.txt1.str)/2
	self.input.x = game.width/2 - self.input.font:getWidth(self.input.str)/2
	self.cursor.x = game.width/2 + self.input.font:getWidth(self.input.str)/2 + 6
	if not self.isGenerating then
		self.cursor.timer:update(dt)
	end
	self.button.ripple:update(dt)
	self.btnClose.ripple:update(dt)
	algo:update(dt)
	if self.button.pressed and self.isGenerating then
		self.spinner:update(dt)
	end
	if self.isTyping then
		self:switchColor()
	end
	if algo.complete then
		for k,v in pairs(cards) do
			v:update(dt)
		end
		if count(cards) ~= 0 then
			self.canGenerate = false
		end
	end
end

function menu:draw()
	love.graphics.setBackgroundColor(material.colors.background("light"))
	love.graphics.setColor(1, 1, 1, 1)
	--outline
	love.graphics.setColor(material.colors.background("dark"))
	if self.cardOutline then
		custom.rectangle.card(self.cardOutline,self.cardOutline.p)
	end
	--title card
	love.graphics.setColor(material.colors.background("light"))
	if self.cardTitle then
		custom.rectangle.card(self.cardTitle,self.cardTitle.p)
	end
	--title text
	if self.isTyping then
		love.graphics.setColor(material.colors.mono("black","headline"))
		love.graphics.setFont(self.txt1.font)
		love.graphics.print(self.txt1.str, self.txt1.x, self.txt1.y)
		--divider 1
		love.graphics.setColor(material.colors.mono("black","divider"))
		love.graphics.line(self.div1.x, self.div1.y, self.div1.x2, self.div1.y)
		--divider 2
		love.graphics.line(self.div1.x, self.div2.y, self.div1.x2, self.div2.y)
		--close button
		love.graphics.setColor(material.colors("grey"))
		custom.rectangle.card(self.btnClose, self.btnClose.p)
		love.graphics.push()
		love.graphics.scale((game.ps/1.5),(game.ps/1.5))
		material.icons.draw("close-box",
			(self.btnClose.x + self.btnClose.w/2)/(game.ps/1.5),
			(self.btnClose.y + self.btnClose.h/2)/(game.ps/1.5)
		)
		love.graphics.pop()
		self.btnClose.ripple:draw()
		--cursor
		if not self.isGenerating then
			love.graphics.setColor(0,0,0,self.cursor.alpha)
			love.graphics.line(self.cursor.x,self.cursor.y,self.cursor.x,self.cursor.y2)
		end
		--input text
		love.graphics.setColor(material.colors.mono("black","headline"))
		love.graphics.setFont(self.input.font)
		love.graphics.print(self.input.str,self.input.x,self.input.y)
	end

	--button
	love.graphics.setColor(self.button.colorButtonDraw)
	custom.rectangle.card(self.button,self.button.p)
	love.graphics.setColor(self.button.colorTextDraw)
	love.graphics.setFont(self.button.font)
	if self.button.txtDraw then
		love.graphics.print(self.button.txt,
			self.button.x + self.button.w/2 - self.button.font:getWidth(self.button.txt)/2,
		self.button.y + self.button.h/2 - self.button.font:getHeight(self.button.txt)/2
		)
	end
	self.button.ripple:draw()

	--spinner
	if self.isGenerating then
		love.graphics.setColor(material.colors("teal"))
		self.spinner:draw(game.width/2, game.height - game.height/3)
	end

	--results
	if algo.complete then
		--display cards per word letter count
		for k,v in pairs(cards) do
			v:draw()
		end
	end
	if game.drawer then
		if game.drawer:getStatus() then
			--blur
			love.graphics.setColor(0,0,0,150/255)
			love.graphics.rectangle("fill",0,0,game.width,game.height)
		end
	end
end

function menu:mousepressed(x,y,b,istouch)
	local mx,my = x/game.ratio,y/game.ratio
	custom.collisions.box(mx,my,self.button,{0,6,0,6}, function()
		self:action(mx,my)
	end)
	custom.collisions.box(mx,my,self.textbox,{0,6,0,6}, function()
		if self.canType and not self.isGenerating then
			love.keyboard.setTextInput(true)
		end
	end)
	custom.collisions.box(mx,my,self.btnClose,{0,6,0,6},function()
		self.btnClose.ripple:start(mx,my,material.colors("teal"))
		app.typed = ""
		--algo:setup()
		self:cleanup()
	end)
	if cards then
		for k,v in pairs(cards) do
			if v.mousepressed then v:mousepressed(x,y,b,istouch) end
			if v.immediate then
				for n,m in pairs(cards) do
					m.flux:stop()
					m:quick()
				end
			end
		end
	end
end

function menu:mousereleased(x,y,b,istouch)
	local mx,my = x/game.ratio,y/game.ratio
	self.button.ripple:fade()
	self.btnClose.ripple:fade()
	if cards then
		for k,v in pairs(cards) do
			if v.mousereleased then v:mousereleased(x,y,b,istouch) end
		end
	end
end

function menu:touchpressed(id,x,y,dx,dy,p)
	if cards then
		for k,v in pairs(cards) do
			if v.touchpressed then v:touchpressed(id,x,y,dx,dy,p) end
			if v.immediate then
				for n,m in pairs(cards) do
					m.flux:stop()
					m:quick()
				end
			end
		end
	end
end

function menu:touchreleased(id,x,y,dx,dy,p)
	if cards then
		for k,v in pairs(cards) do
			if v.touchreleased then v:touchreleased(id,x,y,dx,dy,p) end
			--if v.immediate then
				--for n,m in pairs(cards) do
					--m.flux:stop()
					--m:quick()
				--end
			--end
		end
	end
	self.button.ripple:fade()
	self.btnClose.ripple:fade()
end

function menu:keyreleased(key)
	if key == "escape" then
		local esc = love.window.showMessageBox("Confirm Exit",
			"Are you sure you want to quit?",
			{
				"Yes","No", escapebutton = 0
			}
		)
		if esc == 1 then
			love.event.quit()
		end
	end
end

function menu:leave()
end

function menu:buttonUpdate()
	self.button.p = material.roundrect(self.button.x,self.button.y,self.button.w,self.button.h,2*game.ps,2*game.ps)
	self.button.ripple = material.ripple.custom(function()
		love.graphics.polygon("fill",unpack(self.button.p))
		love.graphics.polygon("line",unpack(self.button.p))
	end, (sqr(self.button.w) + sqr(self.button.h))^0.5)
end

function menu:cardUpdate()
	--self.cardTitle.h = self.button.y
	self.cardTitle.p = material.roundrect(
		self.cardTitle.x, self.cardTitle.y,
		self.cardTitle.w, self.cardTitle.h,2*game.ps,2*game.ps
	)
	self.cardOutline = {
		x = self.cardTitle.x - 1,
		y = self.cardTitle.y - 1,
		w = self.cardTitle.w + 2,
		h = self.cardTitle.h + 2
	}
	self.cardOutline.p = material.roundrect(
		self.cardOutline.x, self.cardOutline.y,
		self.cardOutline.w, self.cardOutline.h,2*game.ps,2*game.ps
	)
end

function menu:getStatus()
	return self.isTyping
end

function menu:cardSetup(t)
	numResult = countAll(t)
	self.txt1.str3 = string.upper("RESULT: " .. numResult)
	self.txt1.str = self.txt1.str3
	print("RESULT: " .. numResult)
	config.save(config.getLog(),"TOTAL RESULT: " .. numResult)
	self.isGenerating = false
	self.button.txt = "CLEAR"
	if t then
		local i
		for k,v in pairs(t) do
			i = k
			local card = screens.card(i, t[i])
			cards[i] = card
		end
	end
end

function menu:raise(lvl)
	self.isGenerating = false
	self.isRaised = true
	if lvl == "empty" then
		local flashCard = screens.flash_card("no result. try again")
		cards[1] = flashCard
	end
end

function menu:getCard()
	return self.cardTitle
end

function menu:cleanup()
	local fin = 0
	self.cleanup_count = self.cleanup_count + 1
	if count(cards) ~= 0 then
		if self.isRaised then
			flux.to(cards[1],0.25,{
				alpha = 0
			}):oncomplete(function()
				app.typed = ""
				cards = {}
				algo:setup()
				self.canGenerate = true
				self.canType = true
				self.isRaised = false
			end)
		else
			if self.cleanup_count > 1 then
				if self.flux_cleanup then
					self.flux_cleanup:stop()
				end
				for k,v in pairs(cards) do
					flux.to(v.color,0.25, {
							[4] = 0
						}
					):oncomplete(function()
					self.cleanup_count = 0
						self.button.txt = self.button.txt2
						self.txt1.str = self.txt1.default
						app.typed = ""
						cards = {}
						algo:setup()
						self.canGenerate = true
						self.canType = true
					end)
				end
			else
				if count(cards) ~= 0 then
					--if cards[#cards].isDone then
					if getLastIndex(cards).isDone then
						self.txt1.str = self.txt1.str4
						for k,v in pairs(cards) do
							self.flux_cleanup = flux.to(v.color, 0.5, {
									[4] = 0
								}
							):oncomplete(function()
								fin = fin + 1
								if fin >= count(cards) then
									self.button.txt = self.button.txt2
									self.txt1.str = self.txt1.default
									app.typed = ""
									cards = {}
									algo:setup()
									self.canGenerate = true
									self.canType = true
								end
							end)
						end
					end
				end
			end
		end
	end
end

function menu:action(mx,my)
	if #app.typed ~= 0 then
		self.button.ripple:start(mx,my)
	end
	--love.keyboard.setTextInput(true)
	self.canType = true
	if not self.isTyping then
		self.button.txtDraw = false
		flux.to(self.button,0.5,{
			y = self.div2.y + _diff/2 * game.ps
		}
		):onupdate(function()
			self.cardTitle.h = self.button.y - self.cardTitle.y + self.button.h + _diff/2 * game.ps
			self:cardUpdate()
			self:buttonUpdate()
		end):oncomplete(function()
			self.isTyping = true
			self.button.txt = self.button.txt2
			local bw = self.cardTitle.w/4
			local dw = self.button.font:getWidth(self.button.txt) + bw
			local dh = self.button.font:getHeight(self.button.txt) + _btnH
			flux.to(self.button,0.5,{h=dh})
			flux.to(self.button,0.5,{w=dw}):onupdate(function()
				self.button.x = game.width/2 - self.button.w/2
				self:buttonUpdate()
			end):oncomplete(function()
				self.button.txtDraw = true
			end)
		end)
	elseif self.isTyping then
		love.keyboard.setTextInput(true)
		self.button.pressed = true
		if not self.isGenerating and #app.typed > 2 then
			if self.canGenerate then
				love.keyboard.setTextInput(false)
				--self.txt1.str = self.txt1.str2
				print(app.typed)
				config.save(config.getLog(),app.typed)
				algo:generate()
				self.isGenerating = true
				self.canType = false
			else
				self:cleanup()
			end
		end
	end
end

sqr = function(n)
	return n*n
end

count = function(t)
	local n = 0
	if t then
		for k,v in pairs(t) do n = n+1 end
	end
	return n
end

countAll = function(t)
	local n = 0
	if t then
		for k,v in pairs(t) do
			n = n + #v
		end
	end
	return n
end

getLastIndex = function(t)
	local i
	for k,v in pairs(t) do
		print(k,v)
		i = v
	end
	return i
end

return menu
