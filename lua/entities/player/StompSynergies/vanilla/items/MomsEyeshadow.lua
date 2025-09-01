local MomsEyeshadow = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param forced boolean
---@param isStompPool table
function MomsEyeshadow:OnStomp(player, stompDamage, bombLanding, forced, isStompPool)
    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_MOMS_EYESHADOW)
    local chance = 1 / (10 - (Helpers.Clamp(player.Luck, 0, 27) / 3))
	if rng:RandomFloat() <= chance or isStompPool.Pool3DollarBill or isStompPool.PoolFruitCake or isStompPool.PoolPlaydoughCookie then
        for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
            enemy:AddCharmed(EntityRef(player), 60)
        end
    end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	MomsEyeshadow.OnStomp,
    { Item = CollectibleType.COLLECTIBLE_MOMS_EYESHADOW, Pool3DollarBill = true, PoolFruitCake = true, PoolPlaydoughCookie = true }
)

return MomsEyeshadow