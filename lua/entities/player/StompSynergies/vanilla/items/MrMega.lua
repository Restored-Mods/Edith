local MrMega = {}

---@param player EntityPlayer
---@param bombDamage number
---@param position Vector
---@param radius number
---@param hasBombs boolean
---@param isGigaBomb boolean
---@param isScatterBomb boolean
---@return table?
function MrMega:OnStompExposion(player, bombDamage, position, radius, hasBombs, isGigaBomb, isScatterBomb)
	local damage = bombDamage
	if not isGigaBomb then
		damage = damage * 1.85
	end
	return {BombDamage = damage, Radius = radius * 1.3 }
end
EdithRestored:AddPriorityCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP_EXPLOSION,
	CallbackPriority.LATE,
	MrMega.OnStompExposion,
	{ Item = CollectibleType.COLLECTIBLE_MR_MEGA }
)

return MrMega