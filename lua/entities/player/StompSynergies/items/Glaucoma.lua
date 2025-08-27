local Glaucoma = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function Glaucoma:OnStomp(player, bombLanding, isDollarBill, isFruitCake)
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_GLAUCOMA)
	if rng:RandomFloat() <= 0.05 or isFruitCake then
		for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
			enemy:AddEntityFlags(EntityFlag.FLAG_CONFUSION)
		end
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	Glaucoma.OnStomp,
	{ Item = CollectibleType.COLLECTIBLE_GLAUCOMA, PoolFruitCake = true }
)

return Glaucoma