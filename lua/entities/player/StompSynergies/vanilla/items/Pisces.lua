local Pisces = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param radius number
---@param knockback number
---@param doBombStomp boolean
---@param isStompPool table
function Pisces:OnStompModify(player, stompDamage, radius, knockback, doBombStomp, isStompPool)
	return { Knockback = knockback + 10 }
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_MODIFY_STOMP,
	Pisces.OnStompModify,
	{ Item = CollectibleType.COLLECTIBLE_PISCES, PoolFruitCake = true }
)

return Pisces