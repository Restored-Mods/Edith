local Stye = {}

---@param player EntityPlayer
---@param stompDamage number
---@param radius number
---@param knockback number
---@param doBombStomp boolean
function Stye:OnStompModify(player, stompDamage, radius, knockback, doBombStomp)
	local data = EdithRestored:RunSave(player)
	if data.StompCount % 2 == 0 then
		return { StompDamage = stompDamage * 1.28 }
	end
end
EdithRestored:AddPriorityCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_MODIFY_STOMP,
	CallbackPriority.LATE - 1,
	Stye.OnStompModify,
	{ Item = CollectibleType.COLLECTIBLE_STYE }
)

return Stye