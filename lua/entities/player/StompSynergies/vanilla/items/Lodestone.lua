local Lodestone = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function Lodestone:OnStomp(player, stompDamage, bombLanding, isDollarBill, isFruitCake)
    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_LODESTONE)
    local maxchance = 1 / (6 - Helpers.Clamp(player.Luck, 0, 5))
    if rng:RandomFloat() <= maxchance or isFruitCake then
        for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
            enemy:AddMagnetized(EntityRef(player), 150)
        end
    end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	Lodestone.OnStomp,
    { Item = CollectibleType.COLLECTIBLE_LODESTONE, PoolFruitCake = true }
)

return Lodestone