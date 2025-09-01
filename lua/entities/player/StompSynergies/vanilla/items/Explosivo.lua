local Explosivo = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param rng RNG
---@param bombLanding boolean
---@param forced boolean
---@param isStompPool table
function Explosivo:OnStomp(player, stompDamage, rng, bombLanding, forced, isStompPool)
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_EXPLOSIVO)
	if rng:RandomFloat() <= 0.25 or isStompPool.PoolFruitCake then
		for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
			local tear = player:FireTear(enemy.Position, Vector.Zero, false ,true, false, player)
			tear:AddTearFlags(TearFlags.TEAR_STICKY)
			tear:ChangeVariant(TearVariant.EXPLOSIVO)
			tear.CollisionDamage = player.Damage
			tear.FallingAcceleration = 1
		end
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	Explosivo.OnStomp,
	{ Item = CollectibleType.COLLECTIBLE_EXPLOSIVO, PoolFruitCake = true }
)

return Explosivo