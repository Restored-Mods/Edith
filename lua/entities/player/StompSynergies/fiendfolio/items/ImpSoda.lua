local ImpSoda = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param radius number
---@param knockback number
---@param doBombStomp boolean
---@param isStompPool table
function ImpSoda:OnStompModify(player, stompDamage, radius, knockback, doBombStomp, isStompPool)
	if FiendFolio:shouldCriticalHit(player) then
		return { StompDamage = stompDamage * 5, DoStomp = true }
	end
end
EdithRestored:AddPriorityCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_MODIFY_STOMP,
	CallbackPriority.LATE,
	ImpSoda.OnStompModify,
	{ Item = FiendFolio.ITEM.COLLECTIBLE.IMP_SODA }
)

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param forced boolean
---@param isStompPool table
function ImpSoda:OnStomp(player, stompDamage, bombLanding, forced, isStompPool)
	if forced then
		for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
			FiendFolio:doCriticalHitFx(enemy.Position, enemy, player)
		end
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	ImpSoda.OnStomp,
	{ Item = FiendFolio.ITEM.COLLECTIBLE.IMP_SODA }
)

return ImpSoda