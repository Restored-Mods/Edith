local TheMulligan = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param forced boolean
---@param isStompPool table
function TheMulligan:OnStomp(player, stompDamage, bombLanding, forced, isStompPool)
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_MULLIGAN)
	if
		(rng:RandomFloat() <= 0.1667 or isStompPool.PoolFruitCake or isStompPool.PoolFFEmojiGlases)
		and #Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius()) > 0
		and #Helpers.Filter(
				Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY),
				function(idx, fly)
					fly = fly:ToFamiliar()
					return fly and fly.Player and GetPtrHash(fly.Player) == GetPtrHash(player)
				end
			)
			< 30
	then
		Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, 0, player.Position, Vector.Zero, player)
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	TheMulligan.OnStomp,
	{ Item = CollectibleType.COLLECTIBLE_MULLIGAN, PoolFruitCake = true, PoolFFEmojiGlases = true }
)

return TheMulligan