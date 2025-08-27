local Terra = {}

---@param player EntityPlayer
---@param stompDamage number
---@param radius number
---@param knockback number
---@param doBombStomp boolean
function Terra:OnStompModify(player, stompDamage, radius, knockback, doBombStomp)
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_TERRA)
	if rng:RandomFloat() <= 0.25 then
		return { BreakRocks = true, StompDamage = stompDamage * rng:RandomInt(5, 20) / 10 }
	end
end
EdithRestored:AddPriorityCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_MODIFY_STOMP,
	CallbackPriority.LATE + 1,
	Terra.OnStompModify,
	{ Item = CollectibleType.COLLECTIBLE_TERRA, PoolFruitCake = true }
)

return Terra