local MomsEyeshadow = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function MomsEyeshadow:OnStomp(player, bombLanding, isDollarBill, isFruitCake)
    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_MOMS_EYESHADOW)
    local chance = 1 / (10 - (Helpers.Clamp(player.Luck, 0, 27) / 3))
	if rng:RandomFloat() <= chance or isDollarBill or isFruitCake then
        for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
            enemy:AddCharmed(EntityRef(player), 60)
        end
    end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	MomsEyeshadow.OnStomp,
    { Item = CollectibleType.COLLECTIBLE_MOMS_EYESHADOW, Pool3DollarBill = true, PoolFruitCake = true }
)

return MomsEyeshadow