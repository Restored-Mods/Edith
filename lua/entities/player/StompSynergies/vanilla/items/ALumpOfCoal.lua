local ALumpOfCoal = {}

---@param player EntityPlayer
---@param stompDamage number
---@param radius number
---@param knockback number
---@param doBombStomp boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function ALumpOfCoal:OnStompModify(player, stompDamage, radius, knockback, doBombStomp, isDollarBill, isFruitCake)
    local data = EdithRestored:GetData(player)
	if data.PreJumpPosition then
		local extraDamage = (player.Position - data.PreJumpPosition):Length() / 40
		return {StompDamage = stompDamage + extraDamage }
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_MODIFY_STOMP,
	ALumpOfCoal.OnStompModify,
    { Item = CollectibleType.COLLECTIBLE_LUMP_OF_COAL, PoolFruitCake = true }
)

return ALumpOfCoal