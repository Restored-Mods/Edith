local KnockoutDrops = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param radius number
---@param knockback number
---@param doBombStomp boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function KnockoutDrops:OnStompModify(player, stompDamage, radius, knockback, doBombStomp, isDollarBill, isFruitCake)
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_KNOCKOUT_DROPS)
    local maxchance = 1 / (6 - Helpers.Clamp(player.Luck, 0, 5))
	if rng:RandomFloat() <= maxchance then
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
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
---@param force boolean
function KnockoutDrops:OnStomp(player, bombLanding, isDollarBill, isFruitCake, force)
    if isFruitCake or force then
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