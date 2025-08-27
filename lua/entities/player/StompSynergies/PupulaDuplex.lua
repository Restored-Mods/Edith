local PupulaDuplex = {}

---@param player EntityPlayer
---@param stompDamage number
---@param radius number
---@param knockback number
---@param doBombStomp boolean
function PupulaDuplex:OnStompModify(player, stompDamage, radius, knockback, doBombStomp)
	return { Radius = radius * 1.2 }
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_MODIFY_STOMP,
	PupulaDuplex.OnStompModify,
	{ Item = CollectibleType.COLLECTIBLE_PUPULA_DUPLEX, Pool3DollarBill = true }
)

return PupulaDuplex