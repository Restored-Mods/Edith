local Tropicamide = {}

---@param player EntityPlayer
---@param stompDamage number
---@param radius number
---@param knockback number
---@param doBombStomp boolean
function Tropicamide:OnStompModify(player, stompDamage, radius, knockback, doBombStomp)
	return { Radius = radius * 1.06 }
end
EdithRestored:AddPriorityCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_MODIFY_STOMP,
	CallbackPriority.LATE,
	Tropicamide.OnStompModify,
	{ Item = CollectibleType.COLLECTIBLE_TROPICAMIDE }
)

return Tropicamide