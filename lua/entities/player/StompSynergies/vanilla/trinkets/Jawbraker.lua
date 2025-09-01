local Jawbreaker = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param radius number
---@param knockback number
---@param doBombStomp boolean
---@param isStompPool table
function Jawbreaker:OnStompModify(player, stompDamage, radius, knockback, doBombStomp, isStompPool)
	local rng = player:GetTrinketRNG(TrinketType.TRINKET_JAW_BREAKER)
	local maxChance = 1 / (10 - Helpers.Clamp(player.Luck, 0, 9))
	if rng:RandomFloat() <= maxChance then
		return { StompDamage = stompDamage * 3.2 }
	end
end
EdithRestored:AddPriorityCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_MODIFY_STOMP,
	CallbackPriority.LATE,
	Jawbreaker.OnStompModify,
	{ Trinket = TrinketType.TRINKET_JAW_BREAKER }
)

return Jawbreaker