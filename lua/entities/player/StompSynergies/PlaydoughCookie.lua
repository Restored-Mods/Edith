local PlaydoughCookie = {}

---@param player EntityPlayer
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function PlaydoughCookie:OnStomp(player, bombLanding, isDollarBill, isFruitCake)
    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_PLAYDOUGH_COOKIE)
    local synergies = EdithRestored.Synergies
    local effects = {
        Burn = synergies.FireMind,
        Freeze = synergies.MomsContacts,
        Charm = synergies.MomsEyeshadow,
        Slow = synergies.SpiderBite,
        Posion = synergies.Scorpio,
        Fear = synergies.MomsPerfume,
        Bait = synergies.RottenTomato
    }
    local map = {}
    local outcomes = WeightedOutcomePicker()
    for k,_ in pairs(effects) do
        map[#map+1] = k
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
    CollectibleType.COLLECTIBLE_PLAYDOUGH_COOKIE
)

return PlaydoughCookie