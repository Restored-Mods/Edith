local GodsFlesh = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function GodsFlesh:OnStomp(player, stompDamage, bombLanding, isDollarBill, isFruitCake)
    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_GODS_FLESH)
	if rng:RandomFloat() <= 0.2 or isDollarBill or isFruitCake then
		for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
            enemy:AddShrink(EntityRef(player), 150)
		end
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	GodsFlesh.OnStomp,
	{ Item = CollectibleType.COLLECTIBLE_GODS_FLESH, PoolFruitCake = true }
)

return GodsFlesh