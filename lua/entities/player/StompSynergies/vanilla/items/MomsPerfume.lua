local MomsPerfume = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param forced boolean
---@param isStompPool table
function MomsPerfume:OnStomp(player, stompDamage, bombLanding, forced, isStompPool)
    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_MOMS_PERFUME)
    local chance = 15 / (100 - Helpers.Clamp(player.Luck, 0, 85))
	if rng:RandomFloat() <= chance or isStompPool.Pool3DollarBill or isStompPool.PoolFruitCake then
        for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
            enemy:AddFear(EntityRef(player), 150)
        end
    end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	MomsPerfume.OnStomp,
	{ Item = CollectibleType.COLLECTIBLE_MOMS_PERFUME, Pool3DollarBill = true, PoolFruitCake = true }
)

return MomsPerfume