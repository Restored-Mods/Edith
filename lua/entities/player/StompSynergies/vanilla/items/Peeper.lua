local Peeper = {}

---@param player EntityPlayer
---@param stompDamage number
---@param radius number
---@param knockback number
---@param doBombStomp boolean
---@param isStompPool table
function Peeper:OnStompModify(player, stompDamage, radius, knockback, doBombStomp, isStompPool)
	local data = EdithRestored:RunSave(player)
	if data.StompCount % 2 == 0 then
		return { StompDamage = stompDamage * 1.35 }
	end
end
EdithRestored:AddPriorityCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_MODIFY_STOMP,
	CallbackPriority.LATE,
	Peeper.OnStompModify,
	{ Item = CollectibleType.COLLECTIBLE_PEEPER }
)

return Peeper