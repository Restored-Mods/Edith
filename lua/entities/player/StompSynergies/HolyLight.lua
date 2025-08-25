local HolyLight = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param bombLanding boolean
---@param isDollarBill boolean
function HolyLight:OnHolyLightStomp(player, bombLanding, isDollarBill, isFruitCake)
    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_HOLY_LIGHT)
     local chance = math.min(1 / (10 - Helpers.Clamp(player.Luck * 0.9, 0, 9)), 1)
	if rng:RandomFloat() <= chance or isDollarBill or isFruitCake then
        for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
            local beam = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 1, enemy.Position, Vector.Zero, player):ToEffect()
        end
    end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_LANDING,
	HolyLight.OnHolyLightStomp,
	{ Item = CollectibleType.COLLECTIBLE_HOLY_LIGHT, Pool3DollarBill = true, PoolFruitCake = true }
)