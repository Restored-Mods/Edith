local MrMega = {}

---@param player EntityPlayer
---@param stompDamage number
---@param radius number
---@param knockback number
---@param doBombStomp boolean
function MrMega:OnStompModify(player, stompDamage, radius, knockback, doBombStomp)
	if doBombStomp then -- Mr. Mega
		return {StompDamage = stompDamage * 1.15, Radius = radius * 1.3 }
	end
end
EdithRestored:AddPriorityCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_MODIFY_STOMP,
	CallbackPriority.LATE - 1,
	MrMega.OnStompModify,
	{ Item = CollectibleType.COLLECTIBLE_MR_MEGA }
)

return MrMega