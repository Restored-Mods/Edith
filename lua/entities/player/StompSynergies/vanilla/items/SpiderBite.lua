local SpiderBite = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param forced boolean
---@param isStompPool table
function SpiderBite:OnStomp(player, stompDamage, bombLanding, forced, isStompPool)
    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_SPIDER_BITE)
    local chance = 1 / (4 - (Helpers.Clamp(player.Luck, 0, 15) / 5))
	if rng:RandomFloat() <= chance or isStompPool.PoolFruitCake or isStompPool.PoolPlaydoughCookie then
        for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
            enemy:AddSlowing(EntityRef(player), 75, 1, Color(1,1,1.3, 1, 0.156863, 0.156863, 0.156863))
        end
    end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	SpiderBite.OnStomp,
	{ Item = CollectibleType.COLLECTIBLE_SPIDER_BITE, PoolFruitCake = true, PoolPlaydoughCookie = true }
)

return SpiderBite