local SulfuricAcid = {}

---@param player EntityPlayer
---@param stompDamage number
---@param radius number
---@param knockback number
---@param doBombStomp boolean
---@param isStompPool boolean
function SulfuricAcid:OnStompModify(player, stompDamage, radius, knockback, doBombStomp, isStompPool)
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_SULFURIC_ACID)
	if rng:RandomFloat() <= 0.25 then
		return { BreakRocks = true }
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_MODIFY_STOMP,
	SulfuricAcid.OnStompModify,
	{ Item = CollectibleType.COLLECTIBLE_SULFURIC_ACID, PoolFruitCake = true }
)

return SulfuricAcid