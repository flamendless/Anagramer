local class = require("modules.classic.classic")
local algo = class:extend()

--NEW METHOD, thanks to @bartbes

local dictionary = {}
local dict = "modules/dictionary_3to7.txt"
local initThreadPath = "modules/init.lua"
local threadLetterSort = "modules/algo/lettersort.lua"
local count, printAll, isNil

local _isGenerate = false

function algo:new()
	if _isGenerate then
		self.fd = {}
	else
		self.fd = config.getFD()
	end
	self.isDone = false
	self.complete = false
	self:setup()
end

function algo:initDictionary()
	local thread = love.thread.newThread(initThreadPath)
	thread:start("new")
	self.thread = thread
	self.channel = love.thread.getChannel("initChannelforDictionary")
	self.fd_channel = love.thread.getChannel("fastdict")
end

function algo:stop()
	if self.thread and self.thread:isRunning() then
		self.channel:push("kill")
	end
	if self.resultThread and self.resultThread:isRunning() then
		self.resultChannel:push("kill")
	end
end

function algo:updateSetup(dt)
	if self.thread and self.thread:isRunning() then
		local d = self.channel:pop()
		if _isGenerate then
			local fd = self.fd_channel:pop()
			if type(fd) == "table" then
				self.fd = fd
			end
		end
		if type(d) == "table" then
			config.save(config.getLog(),"Dictionary: " .. tostring(count(d)))
			dictionary = d
		end
	else
		if _isGenerate then
			if self.fd then
				local tbls = {}
				for i = 1, 4 do
					tbls[i] = {}
				end
				local i = 1
				local c = count(self.fd)/4
				for k,v in pairs(self.fd) do
					if i < c then
						tbls[1][k] = v
					elseif i < c * 2 then
						tbls[2][k] = v
					elseif i < c * 3 then
						tbls[3][k] = v
					elseif i < c * 4 then
						tbls[4][k] = v
					end
					i = i + 1
				end
				local sers = {}
				for i = 1, 4 do
					sers[i] = ser(tbls[i])
				end
				for i = 1, 4 do
					local name = "fd" .. i .. ".lua"
					local file = love.filesystem.newFile(name)
					file:open("r")
					love.filesystem.write(name,sers[i])
					file:close()
				end
			end
		end
		self.isDone = true
	end
end

function algo:setup()
	self.match = {}
	self.final = {}
	self.complete = false
end

function algo:generate()
	self:setup()
	local input = app.typed
	local thread = love.thread.newThread(threadLetterSort)
	local channel = love.thread.getChannel("getResult")
	thread:start(string.lower(input),dictionary,self.fd)
	self.resultThread = thread
	self.resultChannel = channel
end

function algo:update(dt)
	if self.resultThread and self.resultThread:isRunning() then
		local c = self.resultChannel:pop()
		if type(c) == "table" then
			self.match = c
			self:sort()
		end
	end
end

function algo:sort()
	for k,v in pairs(self.match) do
		if self.final[#v] == nil then
			self.final[#v] = {}
		end
		table.insert(self.final[#v],v)
	end
	if count(self.final) == 0 then
		state.current():raise("empty")
	else
		state.current():cardSetup(self.final)
	end
	self.complete = true
end

count = function(t)
	local count = 0
	for k,v in pairs(t) do
		count = count + 1
	end
	return count
end

printAll = function(t)
	for k,v in pairs(t) do
		if type(v) == "table" then
			for n,m in pairs(v) do
				print(m)
			end
		end
	end
end

return algo
