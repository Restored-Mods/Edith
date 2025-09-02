local ShortFuse = {}

---@param player EntityPlayer
---@param damage number
---@param radius number
---@param hasBombs boolean
---@param isStompPool table
---@return table?
function ShortFuse:OnStompExplosion(player, damage, radius, hasBombs, isStompPool)
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
