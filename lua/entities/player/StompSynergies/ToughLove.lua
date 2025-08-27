local ToughLove = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param radius number
---@param knockback number
---@param doBombStomp boolean
function ToughLove:OnStompModify(player, stompDamage, radius, knockback, doBombStomp)
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_TOUGH_LOVE)
	local ToughLoveChance = rng:RandomInt(1, 100)
	local maxChance = 1 / (10 - Helpers.Clamp(player.Luck, 0, 9))
	if ToughLoveChance <= maxChance then
		return { StompDamage = stompDamage * 3.2 }
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_MODIFY_STOMP,
	ToughLove.OnStompModify,
	{ Item = CollectibleType.COLLECTIBLE_TOUGH_LOVE, Pool3DollarBill = true }
)

return ToughLove