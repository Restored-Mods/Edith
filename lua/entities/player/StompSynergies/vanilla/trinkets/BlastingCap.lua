local BlastingCap = {}

---@param player EntityPlayer
---@param damage number
---@param radius number
---@param hasBombs boolean
---@param isStompPool table
---@return table?
function BlastingCap:OnStompExplosion(player, damage, radius, hasBombs, isStompPool)
	local rng = player:GetTrinketRNG(TrinketType.TRINKET_BLASTING_CAP)
			if rng:RandomFloat() <= 0.1 then
				Isaac.Spawn(
					EntityType.ENTITY_PICKUP,
					PickupVariant.PICKUP_BOMB,
					0,
					player.Position,
					Vector.Zero,
					player
				)
			end
end
EdithRestored:AddPriorityCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP_EXPLOSION,
	CallbackPriority.LATE,
	BlastingCap.OnStompExplosion,
	{ Trinket = TrinketType.TRINKET_BLASTING_CAP }
)

return BlastingCap