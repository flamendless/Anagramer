local args = {...}
local word = args[2]
local i = args[1]

local channel = love.thread.getChannel("combination" .. i)

local words = {}

if i == 3 then
	for x = 1, #word do
		for y = 1, #word do
			for z = 1, #word do
				if word[x] ~= word[y] and word[x] ~= word[z] and
					word[y] ~= word[z] then
					local _word = {}
					table.insert(_word, word[x])
					table.insert(_word, word[y])
					table.insert(_word, word[z])
					local __word = table.concat(_word)
					table.insert(words, __word)
				end
			end
		end
	end

elseif i == 4 then
	for a = 1, #word do
		for b = 1, #word do
			for c = 1, #word do
				for d = 1, #word do
					if word[a] ~= word[b] and word[a] ~= word[c] and word[a] ~= word[d] and word[b] ~= word[c] and word[b] ~= word[d] and word[c] ~= word[d] then
						local _word = {}
						table.insert(_word, word[a])
						table.insert(_word, word[b])
						table.insert(_word, word[c])
						table.insert(_word, word[d])
						local __word = table.concat(_word)
						table.insert(words, __word)
					end
				end
			end
		end
	end

elseif i == 5 then
	for a = 1, #word do
		for b = 1, #word do
			for c = 1, #word do
				for d = 1, #word do
					for e = 1, #word do
						if word[a] ~= word[b] and word[a] ~= word[c] and word[a] ~= word[d] and word[a] ~= word[e] and word[b] ~= word[c] and word[b] ~= word[d] and word[b] ~= word[e] and word[c] ~= word[d] and word[c] ~= word[e] and word[d] ~= word[e] then
							local _word = {}
							table.insert(_word, word[a])
							table.insert(_word, word[b])
							table.insert(_word, word[c])
							table.insert(_word, word[d])
							table.insert(_word, word[e])
							local __word = table.concat(_word)
							table.insert(words, __word)
						end
					end
				end
			end
		end
	end

elseif i == 6 then
	for a = 1, #word do
		for b = 1, #word do
			for c = 1, #word do
				for d = 1, #word do
					for e = 1, #word do
						for f = 1, #word do
							if word[a] ~= word[b] and word[a] ~= word[c] and word[a] ~= word[d] and word[a] ~= word[e] and word[a] ~= word[f] and word[b] ~= word[c] and word[b] ~= word[d] and word[b] ~= word[e] and word[b] ~= word[f] and word[c] ~= word[d] and word[c] ~= word[e] and word[c] ~= word[f] and word[d] ~= word[e] and word[d] ~= word[f] and word[e] ~= word[f] then
								local _word = {}
								table.insert(_word, word[a])
								table.insert(_word, word[b])
								table.insert(_word, word[c])
								table.insert(_word, word[d])
								table.insert(_word, word[e])
								table.insert(_word, word[f])
								local __word = table.concat(_word)
								table.insert(words, __word)
							end
						end
					end
				end
			end
		end
	end
end

channel:push(words)
