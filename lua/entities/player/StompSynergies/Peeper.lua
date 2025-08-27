local Peeper = {}

---@param player EntityPlayer
---@param stompDamage number
---@param radius number
---@param knockback number
---@param doBombStomp boolean
function Peeper:OnStompModify(player, stompDamage, radius, knockback, doBombStomp)
	local data = EdithRestored:RunSave(player)
	if data.StompCount % 2 == 0 then
		return { StompDamage = stompDamage * 1.35 }
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_MODIFY_STOMP,
	Peeper.OnStompModify,
	CollectibleType.COLLECTIBLE_PEEPER
)

return Peeper