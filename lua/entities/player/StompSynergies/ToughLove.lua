local ToughLove = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param radius number
---@param knockback number
---@param doBombStomp boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function ToughLove:OnStompModify(player, stompDamage, radius, knockback, doBombStomp, isDollarBill, isFruitCake)
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_TOUGH_LOVE)
	local maxChance = 1 / (10 - Helpers.Clamp(player.Luck, 0, 9))
	if rng:RandomFloat() <= maxChance or isDollarBill then
		return { StompDamage = stompDamage * 3.2 }
	end
end
EdithRestored:AddPriorityCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_MODIFY_STOMP,
	CallbackPriority.LATE,
	ToughLove.OnStompModify,
	{ Item = CollectibleType.COLLECTIBLE_TOUGH_LOVE, Pool3DollarBill = true }
)

return ToughLove