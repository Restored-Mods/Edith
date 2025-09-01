local LittleHorn = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param forced boolean
---@param isStompPool table
function LittleHorn:OnStomp(player, stompDamage, bombLanding, forced, isStompPool)
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_LITTLE_HORN)
	local chance = math.min(0.25, 1 / (30 - Helpers.Clamp(player.Luck * 2, 0, 29)))
	if rng:RandomFloat() <= chance or isStompPool.Pool3DollarBill or isStompPool.PoolFruitCake then
		for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius(), true, nil, nil, false, true)) do
			local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, 1, 0, enemy.Position, Vector.Zero, player):ToTear()
			tear:AddTearFlags(TearFlags.TEAR_HORN)
			tear.CollisionDamage = 0.001
			Isaac.CreateTimer(function() tear:Remove() end, 2, 1, false)
		end
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	LittleHorn.OnStomp,
	{ Item = CollectibleType.COLLECTIBLE_LITTLE_HORN, Pool3DollarBill = true, PoolFruitCake = true }
)

return LittleHorn