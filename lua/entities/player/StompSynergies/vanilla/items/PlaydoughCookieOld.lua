local PlaydoughCookie = {}

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param forced boolean
---@param isStompPool table
function PlaydoughCookie:OnStomp(player, stompDamage, bombLanding, forced, isStompPool)
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_PLAYDOUGH_COOKIE)
	local synergies = EdithRestored.Synergies.Items
	local effects = {
		Burn = synergies.FireMind,
		Petrify = synergies.MomsContacts,
		Charm = synergies.MomsEyeshadow,
		Slow = synergies.SpiderBite,
		Posion = synergies.Scorpio,
		Fear = synergies.MomsPerfume,
		Bait = synergies.RottenTomato,
		Freeze = synergies.Uranus,
	}
	local map = {}
	local outcomes = WeightedOutcomePicker()
	for k, _ in pairs(effects) do
		map[#map + 1] = k
		outcomes:AddOutcomeFloat(#map, 1 / 7)
	end
	local chosenEffectNum = outcomes:PickOutcome(rng)
	if type(effects[map[chosenEffectNum]].OnStomp) == "function" then
		effects[map[chosenEffectNum]]:OnStomp(player, bombLanding)
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	PlaydoughCookie.OnStomp,
	{ Item = CollectibleType.COLLECTIBLE_PLAYDOUGH_COOKIE }
)

return PlaydoughCookie
