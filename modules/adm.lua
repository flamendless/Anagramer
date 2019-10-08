local adm = {}

function adm.showBanner() if not love.ads then return nil end
	if not adm.bannerIsVisible then
		love.ads.showBanner()
		adm.bannerIsVisible = true
	end
end

function adm.hideBanner() if not love.ads then return nilg end
	if adm.bannerIsVisible then
		love.ads.hideBanner()
		adm.bannerIsVisible = false
	end
end

function adm.tryShowInterstitial(resultWhenNoSupport, onSuccess, onCloseAfterSuccess, onFail)
	love.interstitialClosed = function() 
		if love.ads then love.ads.requestInterstitial(adm.interstitialId) end
		if onCloseAfterSuccess then onCloseAfterSuccess() end
	end
	love.interstitialFailedToLoad = onFail
	local result, noSupport
	if love.ads then 
		result = love.ads.isInterstitialLoaded()
		if result then
			love.ads.showInterstitial()
		end
	else
		result = resultWhenNoSupport
		noSupport = true
	end
	if result and onSuccess then
		onSuccess()
	elseif not result and onFail then
		onFail()
	end
	if noSupport and result and onCloseAfterSuccess then
		onCloseAfterSuccess()
	end
	return result
end

function adm.requestRewardedAd(id)
	if love.ads then
		love.ads.requestRewardedAd(id)
	end
end

function adm.tryShowRewardedAd(resultWhenNoSupport, onSuccess, onCloseAfterSuccess, onFail)
	love.rewardedAdDidStop = onCloseAfterSuccess
	love.rewardedAdFailedToLoad = onFail
	local result, noSupport
	if love.ads then 
		result = love.ads.isRewardedAdLoaded()
		if result then
			love.ads.showRewardedAd()
		end
	else
		result = resultWhenNoSupport
		noSupport = true
	end
	if result and onSuccess then
		onSuccess()
	elseif not result and onFail then
		onFail()
	end
	if noSupport and result and onCloseAfterSuccess then
		onCloseAfterSuccess()
	end
	return result
end

function adm.init(bannerId, bannerPos, interstitialId, hideBannerOnStartup) if not love.ads then return nil end -- mobile support only
	adm.interstitialId = interstitialId
	adm.bannerId = bannerId
	adm.bannerPos = bannerPos or "bottom"
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
end

return adm
