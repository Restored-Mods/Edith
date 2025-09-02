local BlastingCap = {}

---@param player EntityPlayer
---@param bombDamage number
---@param position Vector
---@param radius number
---@param hasBombs boolean
---@param isGigaBomb boolean
---@param isScatterBomb boolean
---@return table?
function BlastingCap:OnStompExplosion(player, bombDamage, position, radius, hasBombs, isGigaBomb, isScatterBomb)
	local rng = player:GetTrinketRNG(TrinketType.TRINKET_BLASTING_CAP)
			if rng:RandomFloat() <= 0.1 then
				Isaac.Spawn(
					EntityType.ENTITY_PICKUP,
					PickupVariant.PICKUP_BOMB,
					0,
					position,
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