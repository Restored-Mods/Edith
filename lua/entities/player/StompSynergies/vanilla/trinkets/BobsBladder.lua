local ShortFuse = {}

---@param player EntityPlayer
---@param bombDamage number
---@param position Vector
---@param radius number
---@param hasBombs boolean
---@param isGigaBomb boolean
---@param isScatterBomb boolean
---@return table?
function ShortFuse:OnStompExplosion(player, bombDamage, position, radius, hasBombs, isGigaBomb, isScatterBomb)
	local creep =
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_GREEN, 0, player.Position, Vector.Zero, player)
			:ToEffect()
	creep.Timeout = 60
end
EdithRestored:AddPriorityCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP_EXPLOSION,
	CallbackPriority.LATE,
	ShortFuse.OnStompExplosion,
	{ Trinket = TrinketType.TRINKET_BOBS_BLADDER }
)

return ShortFuse
