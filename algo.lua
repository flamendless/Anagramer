local class = require("modules.classic.classic")
local algo = class:extend()

--OLD METHOD

local dict = "modules/dictionary.txt"
local initThreadPath = "modules/init.lua"
local combinationThreadPath = "modules/algo/combination.lua"
local permutationThreadPath = "modules/algo/permute.lua"

local dictionary = {}
local dictionary_seven = {}

--for tables with key-value indexes, since # doesnt work with it
local function count(t)
	local n = 0
	for k,v in pairs(t) do
		n = n + 1
	end
	return n
end
local function countAll(t)
	local n = 0
	for k,v in pairs(t) do
		if type(v) == "table" then
			for x,y in pairs(v) do
				n = n + 1
			end
		end
	end
	return n
end

function algo:new()
	self.isDone = false
	self:setup()
end

function algo:initDictionary()
	local thread = love.thread.newThread(initThreadPath)
	thread:start("old")
	self.thread = thread
	self.channel2 = love.thread.getChannel("initChannelforDictionary")
	self.channel3 = love.thread.getChannel("initChannelforDictionary7")
end

function algo:update()
	if self.thread and self.thread:isRunning() then
		local d = self.channel2:pop()
		local d7 = self.channel3:pop()
		if type(d) == "table" then
			dictionary = d
		end
		if type(d7) == "table" then
			dictionary_seven = d7
		end
	else
		if dictionary[1] ~= nil and dictionary_seven[1] ~= nil then
			self.isDone = true
		end
	end
end

function algo:setup()
	self.match = {}
	self.allWords = {
		three = {},
		four = {},
		five = {},
		six = {},
		seven = {},
	}
end

function algo:combination(word)
	local max
	if #word == 7 then max = 6
	else max = #word
	end
	for i = 3, max do
		self:getCombination(i, word)
	end
	if #word == 7 then
		self:getPermutation(#word, word)
	end
end

function algo:getCombination(i,word)
	local thread = love.thread.newThread(combinationThreadPath)
	thread:start(i,word)
	local channel = love.thread.getChannel("combination" .. i)
	local str
	if i == 3 then str = "three"
	elseif i == 4 then str = "four"
	elseif i == 5 then str = "five"
	elseif i == 6 then str = "six"
	end
	local _words = channel:demand()
	self.allWords[str] = self:check(_words)
end

function algo:getPermutation(n, word)
	local thread = love.thread.newThread(permutationThreadPath)
	thread:start(n, word, dictionary_seven)
	local channel = love.thread.getChannel("permutation")
	local s = channel:demand()
	self.allWords["seven"] = s
end

--check if the word matches a dictionary entry
function algo:check(t)
	local word = {}
	if t then
		for k,v in pairs(t) do
			for i = 1, #dictionary do
				if v == dictionary[i] then
					word[v] = v
				end
			end
		end
	end
	return word
end

function algo:finish()
	if not isEmpty(self.match) then
		self:setup()
	end
end

return algo
