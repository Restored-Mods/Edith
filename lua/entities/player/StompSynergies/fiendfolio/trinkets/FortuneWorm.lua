local FortuneWorm = {}

---@param player EntityPlayer
---@param stompDamage number
---@param radius number
---@param knockback number
---@param doBombStomp boolean
---@param isStompPool table
function FortuneWorm:OnStompModify(player, stompDamage, radius, knockback, doBombStomp, isStompPool)
	--Fortune Stuff
	return EdithRestored.Synergies.fiendfolio.Items.LeftoverTakeout:OnStompModify(player, stompDamage, radius, knockback, doBombStomp, isStompPool)
end
EdithRestored:AddPriorityCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_MODIFY_STOMP,
	CallbackPriority.LATE,
	FortuneWorm.OnStompModify,
	{ Trinket = FiendFolio.ITEM.TRINKET.FORTUNE_WORM }
)

return FortuneWorm