local MomsPerfume = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param bombLanding boolean
---@param isDollarBill boolean
function MomsPerfume:OnMomsPerfumeStomp(player, bombLanding, isDollarBill)
    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_MOMS_PERFUME)
    local chance = 15 / (100 - Helpers.Clamp(player.Luck, 0, 85))
	if rng:RandomFloat() <= chance or isDollarBill then
        for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
            enemy:AddFear(EntityRef(player), 150)
        end
    end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_LANDING,
	MomsPerfume.OnMomsPerfumeStomp,
	CollectibleType.COLLECTIBLE_MOMS_PERFUME
)