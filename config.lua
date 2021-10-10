local conf = {}
local ser = require("modules.ser")
local lume = require("modules.lume.lume")

local file_log = "log.txt"
local file_user = "user.lua"
local fastdict = "fastdict.lua"

local ending = "\r\n========"

function conf.getLog() return file_log end
function conf.getUser() return file_user end

local function count(t)
	local n = 0
	for k,v in pairs(t) do
		n = n + 1
	end
	return n
end

local function getFileName(str)
	return str:match("(.+)%..+")
end

function conf.init()
	print("Initializing")
	--default
	if love.filesystem.getInfo(file_user) then
		user = require(getFileName(file_user))
	else
		user.isLog = true
		user.isFree = true
		user.isRated = false
	end
	conf.log()
	conf.user()
	print("Finished")
end

function conf.getFD()
	local tbl = {}
	for i = 1, 4 do
		tbl[i] = require("modules.fd"..i)
	end
	for i = 2,4 do lume.extend(tbl[1], tbl[i]) end
	return tbl[1]
end

function conf.log()
	if user.isLog then
		if not love.filesystem.getInfo(file_log) then
			print("Creating log file")
			local f = love.filesystem.newFile(file_log)
			f:open("r")
			love.filesystem.write(file_log, "FIRST LAUNCH"
				.. "\r\n" .. os.date()
				.. "\r\nWIDTH: " .. tostring(love.graphics.getWidth())
				.. "\r\nHEIGHT: " .. tostring(love.graphics.getHeight())
				.. "\r\nPIXEL SCALE: " .. tostring(love.window.getDPIScale())
			)
			f:close()
		else
			print("Log file already exists")
			love.filesystem.append(file_log, "\r\n========"
				.. "\r\n" .. os.date()
			)
		end
	end
end

function conf.user(override)
	if not override then
		if not love.filesystem.getInfo(file_user) then
			print("Creating user configuration file")
			local f = love.filesystem.newFile(file_user)
			local save = ser(user)
			f:open("r")
			love.filesystem.write(file_user,save)
			f:close()
		else
			local file = getFileName(file_user)
			user = require(file)
			print("User File Values")
			print(inspect(user))
		end
	else
		print("Overriding user configuration file")
		local f = love.filesystem.newFile(file_user)
		local save = ser(user)
		print(inspect(user))
		f:open("r")
		love.filesystem.write(file_user,save)
		f:close()
	end
end

function conf.save(file_name,str,isEnd)
	if love.filesystem.getInfo(file_name) then
		if isEnd then
			love.filesystem.append(file_name,ending)
		else
			love.filesystem.append(file_name,"\r\n" .. tostring(str))
		end
	else
		local file = love.filesystem.newFile(file_name)
		file:open("r")
		love.filesystem.write(file_name,str)
		file:close()
	end
end

return conf
