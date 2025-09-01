local YingYangOrb = {}

---@param player EntityPlayer
---@param stompDamage number
---@param radius number
---@param knockback number
---@param doBombStomp boolean
---@param isStompPool table
function YingYangOrb:OnStompModify(player, stompDamage, radius, knockback, doBombStomp, isStompPool)
	if not player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.DICHROMATIC_BUTTERFLY) then
		return EdithRestored.Synergies.fiendfolio.Items.DichromaticButterfly:OnStompModify(player, stompDamage, radius, knockback, doBombStomp, isStompPool)
	end
end
EdithRestored:AddPriorityCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_MODIFY_STOMP,
	CallbackPriority.LATE,
	YingYangOrb.OnStompModify,
	{ Trinket = FiendFolio.ITEM.TRINKET.YIN_YANG_ORB }
)

return YingYangOrb