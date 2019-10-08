local args = {...}

local le = require("love.event")
local lt = require("love.timer")

local fastdict = {}
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

if args[1] == "old" then
	local dict = "modules/dictionary.txt"
	local dict7 = "modules/dictionary_seven.txt"
	local dictionary = {}
	local dictionary7 = {}

	local channel2 = love.thread.getChannel("initChannelforDictionary")
	local channel3 = love.thread.getChannel("initChannelforDictionary7")

	for line in love.filesystem.lines(dict) do
		table.insert(dictionary, line)
	end
	for line in love.filesystem.lines(dict7) do
		table.insert(dictionary7, line)
	end

	channel2:push(dictionary)
	channel3:push(dictionary7)

elseif args[1] == "new" then
	local i = 0
	local dict = "modules/dictionary_3to7.txt"
	local dictionary = {}
	local fd_channel = love.thread.getChannel("fastdict")
	local channel = love.thread.getChannel("initChannelforDictionary")
	local content = love.filesystem.read(dict)
	for line in content:gmatch("[^\r\n]+") do
		table.insert(dictionary, line)
		i = i + 1
		if i * 0.001 == math.floor(i * 0.001) then
			lt.sleep(0.02)
		end
		local msg = channel:peek()
		if msg == "kill" then return end
	end
	--for _,v in ipairs(dictionary) do
		--local sorted = lettersort(v)
		--fastdict[sorted] = fastdict[sorted] or {}
		--table.insert(fastdict[sorted],v)
	--end

	--bottleneck in 0.10.2
	--for line in love.filesystem.lines(dict) do
		--table.insert(dictionary,line)
		--local msg = channel:peek()
		--if msg == "kill" then return end
	--end
	fd_channel:push(fastdict)
	channel:push(dictionary)
end
