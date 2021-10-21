local ads = {}

local ids = {
	banner = "ca-app-pub-1904940380415570/3754691928",
	inter = "ca-app-pub-1904940380415570/2796833472",
	reward = "ca-app-pub-1904940380415570/1591563010",
}

local test = {
	banner = "ca-app-pub-3940256099942544/6300978111",
	inter = "ca-app-pub-3940256099942544/1033173712",
	reward = "ca-app-pub-3940256099942544/5224354917",
}

if _test then
	ads.ads = test
	print("using test ads")
else
	ads.ads = ids
	print("using real ads")
end

return ads
