local ALumpOfCoal = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param radius number
---@param knockback number
---@param doBombStomp boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function ALumpOfCoal:OnJump(player, stompDamage, radius, knockback, doBombStomp, isDollarBill, isFruitCake)
	local data = EdithRestored:GetData(player)
	data.LumpOfCoalPreJumpPosition = player.Position
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_JUMPING,
	ALumpOfCoal.OnJump,
	{Item = CollectibleType.COLLECTIBLE_LUMP_OF_COAL }
)

---@param player EntityPlayer
---@param stompDamage number
---@param radius number
---@param knockback number
---@param doBombStomp boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function ALumpOfCoal:OnStompModify(player, stompDamage, radius, knockback, doBombStomp, isDollarBill, isFruitCake)
    local data = EdithRestored:GetData(player)
	if data.LumpOfCoalPreJumpPosition then
		local extraDamage = (player.Position - data.LumpOfCoalPreJumpPosition):Length() / 40
		return {StompDamage = stompDamage + extraDamage }
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_MODIFY_STOMP,
	ALumpOfCoal.OnStompModify,
    { Item = CollectibleType.COLLECTIBLE_LUMP_OF_COAL, PoolFruitCake = true }
)

return ALumpOfCoal