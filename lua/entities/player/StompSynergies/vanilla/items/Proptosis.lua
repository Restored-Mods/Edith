local Proptosis = {}

---@param player EntityPlayer
---@param stompDamage number
---@param radius number
---@param knockback number
---@param doBombStomp boolean
---@param isStompPool table
function Proptosis:OnStompModify(player, stompDamage, radius, knockback, doBombStomp, isStompPool)
	return { DoProptosis = true }
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_MODIFY_STOMP,
	Proptosis.OnStompModify,
	{ Item = CollectibleType.COLLECTIBLE_PROPTOSIS, Pool3DollarBill = true, PoolFruitCake = true, PoolPlaydoughCookie = true }
)

return Proptosis