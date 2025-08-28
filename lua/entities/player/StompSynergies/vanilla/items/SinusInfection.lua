local SinusInfection = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function SinusInfection:OnStomp(player, stompDamage, bombLanding, isDollarBill, isFruitCake)
    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_SINUS_INFECTION)
    if rng:RandomFloat() <= 0.2 then
        for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
            local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BOOGER, 0, enemy.Position, Vector.Zero, player):ToTear()
            tear:AddTearFlags(TearFlags.TEAR_BOOGER)
            tear.CollisionDamage = player.Damage
        end
    end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	SinusInfection.OnStomp,
	{ Item = CollectibleType.COLLECTIBLE_SINUS_INFECTION, Pool3DollarBill = true, PoolFruitCake = true }
)

return SinusInfection