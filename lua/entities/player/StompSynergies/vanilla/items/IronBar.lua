local IronBar = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function IronBar:OnStomp(player, stompDamage, bombLanding, isDollarBill, isFruitCake)
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_IRON_BAR)
	local chance = 1 / (10 - (Helpers.Clamp(player.Luck, 0, 27) / 3))
	if rng:RandomFloat() <= chance or isDollarBill or isFruitCake then
		for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
			enemy:AddConfusion(EntityRef(player), 120, false)
		end
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	IronBar.OnStomp,
	{ Item = CollectibleType.COLLECTIBLE_IRON_BAR, Pool3DollarBill = true, PoolFruitCake = true }
)

return IronBar