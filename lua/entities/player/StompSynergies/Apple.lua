local Apple = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param radius number
---@param knockback number
---@param doBombStomp boolean
function Apple:OnStompModify(player, stompDamage, radius, knockback, doBombStomp)
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_APPLE)
	local AppleChance = rng:RandomInt(1, 100)
	local maxChance = 1 / (15 - Helpers.Clamp(player.Luck, 0, 14))
	if AppleChance <= maxChance then
		return { StompDamage = stompDamage * 4 }
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_MODIFY_STOMP,
	Apple.OnStompModify,
	{ Item = CollectibleType.COLLECTIBLE_APPLE, Pool3DollarBill = true }
)

return Apple