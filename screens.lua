screens = {}
screens_tbl = {}

screens.hook = function(s, current)
	local c = state.current().id
	if not current then
		if screens_tbl[c] == nil then
			screens_tbl[c] = {}
		end
		table.insert(screens_tbl[c],s)
	else
		screens_tbl[current] = {}
		table.insert(screens_tbl[current],s)
	end
end

screens.appbar = require("screens.appbar")
screens.loading = require("screens.load")
screens.menu = require("screens.menu")
screens.card = require("screens.card")
screens.result = require("screens.result")
screens.flash_card = require("screens.flash_card")
for k,v in pairs(screens) do
	if type(v) == "table" then
		v.isReady = true
		v.id = tostring(k)
	end
end
