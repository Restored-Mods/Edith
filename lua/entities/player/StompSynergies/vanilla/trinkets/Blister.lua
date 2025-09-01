local Blister = {}

---@param player EntityPlayer
---@param stompDamage number
---@param radius number
---@param knockback number
---@param doBombStomp boolean
---@param isStompPool table
function Blister:OnStompModify(player, stompDamage, radius, knockback, doBombStomp, isStompPool)
    return {Knockback = knockback + 8}
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_MODIFY_STOMP,
	Blister.OnStompModify,
	{ Trinket = TrinketType.TRINKET_BLISTER }
)

return Blister