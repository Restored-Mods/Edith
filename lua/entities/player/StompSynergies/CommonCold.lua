local CommonCold = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param bombLanding boolean
---@param isDollarBill boolean
function CommonCold:OnCommonColdStomp(player, bombLanding, isDollarBill)
    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_COMMON_COLD)
    local chance = 1 / (4 - Helpers.Clamp(player.Luck * 0.25, 0, 3))
    if rng:RandomFloat() <= chance or isDollarBill then
        for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
            enemy:AddPoison(EntityRef(player), 30, player.Damage * 2)
        end
    end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_LANDING,
	CommonCold.OnCommonColdStomp,
	CollectibleType.COLLECTIBLE_COMMON_COLD
)