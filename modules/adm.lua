local adm = {}

function adm.init(bannerId, bannerPos, interstitialId, hideBannerOnStartup, rewardedId)
	if not love.ads then return end -- mobile support only
	adm.bannerId = bannerId
	adm.interstitialId = interstitialId
	adm.bannerPos = bannerPos or "bottom"
	adm.rewardedId = rewardedId
	if adm.bannerId then
		love.ads.createBanner(adm.bannerId, adm.bannerPos)
		if not hideBannerOnStartup then
			adm.showBanner()
			adm.bannerIsVisible = true
		end
	end
	if adm.interstitialId then
		love.ads.requestInterstitial(adm.interstitialId)
	end
	if adm.rewardedId then
		love.ads.requestRewardedAd(adm.rewardedId)
	end
end

function adm.showBanner()
	if not love.ads then return end
	if not adm.bannerIsVisible then
		love.ads.showBanner()
		adm.bannerIsVisible = true
	end
end

function adm.hideBanner()
	if not love.ads then return end
	if adm.bannerIsVisible then
		love.ads.hideBanner()
		adm.bannerIsVisible = false
	end
end

function adm.tryShowInterstitial(onSuccess, onCloseAfterSuccess, onFail)
	love.interstitialClosed = function()
		if love.ads then love.ads.requestInterstitial(adm.interstitialId) end
		if onCloseAfterSuccess then onCloseAfterSuccess() end
	end
	love.interstitialFailedToLoad = onFail
	local result = false
	if love.ads then
		result = love.ads.isInterstitialLoaded()
		if result then
			love.ads.showInterstitial()
		end
	end
	if result and onSuccess then
		onSuccess()
	elseif not result and onFail then
		onFail()
	end
	return result
end

function adm.requestInterstitial(id)
	if love.ads then
		love.ads.requestInterstitial(id or adm.interstitialId)
	end
end

function adm.requestRewardedAd(id)
	if love.ads then
		love.ads.requestRewardedAd(id or adm.rewardedId)
	end
end

function adm.tryShowRewardedAd(onSuccess, onCloseAfterSuccess, onFail)
	love.rewardedAdDidStop = function()
		if love.ads then love.ads.requestRewardedAd(adm.rewardedId) end
		if onCloseAfterSuccess then onCloseAfterSuccess() end
	end
	love.rewardedAdFailedToLoad = onFail
	local result = false
	if love.ads then
		result = love.ads.isRewardedAdLoaded()
		if result then
			love.ads.showRewardedAd()
		end
	end
	if result and onSuccess then
		onSuccess()
	elseif not result and onFail then
		onFail()
	end
	return result
end

return adm
