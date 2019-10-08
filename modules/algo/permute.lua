local args = {...}
local word = args[2]
local n = args[1]
local dictionary = args[3]

local channel = love.thread.getChannel("permutation")
local words = {}
local match = {}

function permute(n, word)
	if n == 0 then
		local _word = table.concat(word)
		table.insert(match, _word)
	else
		for i = 1, n do
			permute(n-1, word)
			local swap = n % 2 == 0 and i or 1
			word[swap] = word[n]
			word[n] = word[swap]
		end
	end
end

function check(t)
	if t then
		for k,v in pairs(t) do
			for i = 1, #dictionary do
				if v == dictionary[i] then
					words[v] = v
				end
			end
		end
	end
end

permute(n, word)
check(match)

channel:push(words)
