local Apple = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param radius number
---@param knockback number
---@param doBombStomp boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function Apple:OnStompModify(player, stompDamage, radius, knockback, doBombStomp, isDollarBill, isFruitCake)
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_APPLE)
	local maxChance = 1 / (15 - Helpers.Clamp(player.Luck, 0, 14))
	if rng:RandomFloat() <= maxChance or isDollarBill then
		return { StompDamage = stompDamage * 4 }
	end
end
EdithRestored:AddPriorityCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_MODIFY_STOMP,
	CallbackPriority.LATE,
	Apple.OnStompModify,
	{ Item = CollectibleType.COLLECTIBLE_APPLE, Pool3DollarBill = true }
)

return Apple