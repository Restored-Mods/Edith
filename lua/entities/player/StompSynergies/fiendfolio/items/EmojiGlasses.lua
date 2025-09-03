local EmojiGlasses = {}

---@param player EntityPlayer
---@param stompDamage number
---@param radius number
---@param knockback number
---@param doBombStomp boolean
---@param isStompPool table
function EmojiGlasses:OnStompModify(player, stompDamage, radius, knockback, doBombStomp, isStompPool)
	if isStompPool.PoolFFEmojiGlases then
		return { StompDamage = stompDamage * 1.5 }
	end
end
EdithRestored:AddPriorityCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_MODIFY_STOMP,
	CallbackPriority.LATE,
	EmojiGlasses.OnStompModify,
	{ Item = FiendFolio.ITEM.COLLECTIBLE.EMOJI_GLASSES, PoolFFEmojiGlases = true }
)

return EmojiGlasses