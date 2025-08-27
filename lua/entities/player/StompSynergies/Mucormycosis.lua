local Mucormycosis = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function Mucormycosis:OnStomp(player, bombLanding, isDollarBill, isFruitCake)
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_MUCORMYCOSIS)
	if rng:RandomFloat() <= 0.25 or isDollarBill or isFruitCake then
		for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
			local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, 1, 0, enemy.Position, Vector.Zero, player):ToTear()
			tear:AddTearFlags(TearFlags.TEAR_SPORE)
			tear:ChangeVariant(TearVariant.SPORE)
			tear.CollisionDamage = player.Damage
		end
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	Mucormycosis.OnStomp,
	{ Item = CollectibleType.COLLECTIBLE_MUCORMYCOSIS, PoolFruitCake = true }
)

return Mucormycosis