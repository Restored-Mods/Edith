local PupulaDuplex = {}

---@param player EntityPlayer
---@param stompDamage number
---@param radius number
---@param knockback number
---@param doBombStomp boolean
---@param isStompPool table
function PupulaDuplex:OnStompModify(player, stompDamage, radius, knockback, doBombStomp, isStompPool)
	return { Radius = radius * 1.2 }
end
EdithRestored:AddPriorityCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_MODIFY_STOMP,
	CallbackPriority.LATE,
	PupulaDuplex.OnStompModify,
	{ Item = CollectibleType.COLLECTIBLE_PUPULA_DUPLEX, Pool3DollarBill = true }
)

return PupulaDuplex