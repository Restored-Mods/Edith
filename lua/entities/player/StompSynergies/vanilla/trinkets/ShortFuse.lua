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
	return { BombDamage = bombDamage * 1.15 }
end
EdithRestored:AddPriorityCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP_EXPLOSION,
	CallbackPriority.LATE,
	ShortFuse.OnStompExplosion,
	{ Trinket = TrinketType.TRINKET_SHORT_FUSE }
)

return ShortFuse