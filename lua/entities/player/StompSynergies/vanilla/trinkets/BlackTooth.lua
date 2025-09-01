local BlackTooth = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param radius number
---@param knockback number
---@param doBombStomp boolean
---@param isStompPool table
function BlackTooth:OnStompModify(player, stompDamage, radius, knockback, doBombStomp, isStompPool)
    local rng = player:GetTrinketRNG(TrinketType.TRINKET_BLACK_TOOTH)
    local maxchance = 1 / (33 - Helpers.Clamp(player.Luck, 0, 32))
    if rng:RandomFloat() <= maxchance then
        return {stompDamage = stompDamage * 2, DoStomp = true}
    end
end
EdithRestored:AddPriorityCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_MODIFY_STOMP,
    CallbackPriority.LATE,
	BlackTooth.OnStompModify,
	{ Trinket = TrinketType.TRINKET_BLACK_TOOTH }
)

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param forced boolean
---@param isStompPool table
function BlackTooth:OnStomp(player, stompDamage, bombLanding, forced, isStompPool)
    if forced then
        for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
            enemy:AddPoison(EntityRef(player), 40, player.Damage)
        end
    end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	BlackTooth.OnStomp,
	{ Trinket = TrinketType.TRINKET_BLACK_TOOTH }
)

return BlackTooth