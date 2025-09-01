local OcularRift = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param forced boolean
---@param isStompPool table
function OcularRift:OnStomp(player, stompDamage, bombLanding, forced, isStompPool)
    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_OCULAR_RIFT)
    local maxchance = math.min(0.2, 1 / (20 - Helpers.Clamp(player.Luck, 0, 19)))
    if rng:RandomFloat() <= maxchance or isStompPool.PoolFruitCake then
        local rift = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RIFT, 0, player.Position, Vector.Zero, player):ToEffect()
        rift.Timeout = 60
        rift.CollisionDamage = player.Damage / 2
    end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	OcularRift.OnStomp,
    { Item = CollectibleType.COLLECTIBLE_OCULAR_RIFT, PoolFruitCake = true }
)

return OcularRift