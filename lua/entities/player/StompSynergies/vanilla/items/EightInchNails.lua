local EightInchNails = {}

---@param player EntityPlayer
---@param stompDamage number
---@param radius number
---@param knockback number
---@param doBombStomp boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function EightInchNails:OnStompModify(player, stompDamage, radius, knockback, doBombStomp, isDollarBill, isFruitCake)
	return { Knockback = knockback + 8 }
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_MODIFY_STOMP,
	EightInchNails.OnStompModify,
	{ Item = CollectibleType.COLLECTIBLE_8_INCH_NAILS, Pool3DollarBill = true }
)

return EightInchNails