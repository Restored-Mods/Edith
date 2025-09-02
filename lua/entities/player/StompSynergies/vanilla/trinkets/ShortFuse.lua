local ShortFuse = {}

---@param player EntityPlayer
---@param damage number
---@param radius number
---@param hasBombs boolean
---@param isStompPool table
---@return table?
function ShortFuse:OnStompExplosion(player, damage, radius, hasBombs, isStompPool)
	return { BombDamage = damage * 1.15 }
end
EdithRestored:AddPriorityCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP_EXPLOSION,
	CallbackPriority.LATE,
	ShortFuse.OnStompExplosion,
	{ Trinket = TrinketType.TRINKET_SHORT_FUSE }
)

return ShortFuse