local RottenTomato = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param forced boolean
---@param isStompPool table
function RottenTomato:OnStomp(player, stompDamage, bombLanding, forced, isStompPool)
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_ROTTEN_TOMATO)
	local maxchance = 1 / (6 - Helpers.Clamp(player.Luck, 0, 5))
	if rng:RandomFloat() <= maxchance or isStompPool.PoolFruitCake or isStompPool.PoolPlaydoughCookie then
		for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
			enemy:AddBaited(EntityRef(player), 180)
		end
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	RottenTomato.OnStomp,
	{ Item = CollectibleType.COLLECTIBLE_ROTTEN_TOMATO, PoolFruitCake = true, PoolPlaydoughCookie = true }
)

return RottenTomato