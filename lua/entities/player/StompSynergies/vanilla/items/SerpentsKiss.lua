local SerpentsKiss = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param rng RNG
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function SerpentsKiss:OnStomp(player, stompDamage, rng, bombLanding, isDollarBill, isFruitCake)
    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_SERPENTS_KISS)
    if rng:RandomFloat() <= 0.25 then
        for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
            enemy:AddPoison(EntityRef(player), 60, player.Damage)
        end
    end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	SerpentsKiss.OnStomp,
	{ Item = CollectibleType.COLLECTIBLE_SERPENTS_KISS, PoolFruitCake = true }
)

return SerpentsKiss