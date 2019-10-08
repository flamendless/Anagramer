local args = {...}

local le = require("love.event")

local input = args[1]
local dict = args[2]
local fastdict = args[3]

local channel = love.thread.getChannel("getResult")
local final = {}
local matchOne, matchTwo

local count = function(t)
	local n = 0
	for k,v in pairs(t) do
		n = n + 1
	end
	return n
end

local function lettersort(s)
	local letters = {}
	if s.gmatch then
		for c in s:gmatch(".") do
			table.insert(letters,c)
		end
	end
	table.sort(letters)
	return table.concat(letters)
end

local function unique(str)
	local out = ""
	for s in str:gmatch(".") do
		if not out:find(s) then out = out .. s end
	end
	return out
end

local function _match(input)
	local str = unique(input)
	if str == input then
		--no duplicated char
		matchOne(input)
	else
		--duplicated char
		matchTwo(input)
	end
end

function matchOne(input)
	local sorted = lettersort(input)
	for match, words in pairs(fastdict) do
		local c = channel:peek()
		if c == "kill" then
			return
		end
		local previous = 0
		local matches = true
		for c in match:gmatch(".") do
			local pos = sorted:find(c)
			if not pos or pos <= previous then
				matches = false
				break
			end
			previous = pos
		end
		if matches then
			for _,word in ipairs(words) do
				final[word] = word
			end
		end
	end
end

function matchTwo(input)
	local sorted = lettersort(input)
	for match, words in pairs(fastdict) do
		local c = channel:peek()
		if c == "kill" then
			return
		end
		local previous = 0
		local matches = true
		for c in match:gmatch(".") do
			local pos = sorted:find(c, previous + 1)
			if not pos then
				matches = false
				break
			end
			previous = pos
		end
		if matches then
			for _,word in ipairs(words) do
				final[word] = word
			end
		end
	end
end

_match(input)
channel:push(final)
