local KnockoutDrops = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param radius number
---@param knockback number
---@param doBombStomp boolean
---@param isStompPool table
function KnockoutDrops:OnStompModify(player, stompDamage, radius, knockback, doBombStomp, isStompPool)
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_KNOCKOUT_DROPS)
    local maxchance = 1 / (6 - Helpers.Clamp(player.Luck, 0, 5))
	if rng:RandomFloat() <= maxchance or isStompPool.PoolFruitCake then
		return { Knockback = knockback * 3, DoStomp = true, KnockbackDamage = true, KnockbackTime = 15 }
	end
end
EdithRestored:AddPriorityCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_MODIFY_STOMP,
	CallbackPriority.LATE,
	KnockoutDrops.OnStompModify,
	{ Item = CollectibleType.COLLECTIBLE_KNOCKOUT_DROPS, PoolFruitCake = true }
)

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param forced boolean
---@param isStompPool table
function KnockoutDrops:OnStomp(player, stompDamage, bombLanding, forced, isStompPool)
    if isStompPool.PoolFruitCake or forced then
        for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
            enemy:AddConfusion(EntityRef(player), 60, false)
        end
    end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	KnockoutDrops.OnStomp,
    { Item = CollectibleType.COLLECTIBLE_KNOCKOUT_DROPS, PoolFruitCake = true }
)

return KnockoutDrops