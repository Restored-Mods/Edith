local ChemicalPeel = {}

---@param player EntityPlayer
---@param stompDamage number
---@param radius number
---@param knockback number
---@param doBombStomp boolean
function ChemicalPeel:OnStompModify(player, stompDamage, radius, knockback, doBombStomp)
	local data = EdithRestored:RunSave(player)
	if data.StompCount % 2 == 0 then
		return { StompDamage = stompDamage + 2 }
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_MODIFY_STOMP,
	ChemicalPeel.OnStompModify,
	{Item = CollectibleType.COLLECTIBLE_CHEMICAL_PEEL }
)

return ChemicalPeel