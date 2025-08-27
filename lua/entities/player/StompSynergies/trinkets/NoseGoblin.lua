local NoseGoblin = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function NoseGoblin:OnStomp(player, bombLanding, isDollarBill, isFruitCake)
    local rng = player:GetTrinketRNG(TrinketType.TRINKET_NOSE_GOBLIN)
    if rng:RandomFloat() <= 0.1 then
        for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
            local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BOOGER, 0, enemy.Position, Vector.Zero, player):ToTear()
            tear:AddTearFlags(TearFlags.TEAR_BOOGER)
            tear.CollisionDamage = player.Damage
        end
    end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	NoseGoblin.OnStomp,
	{ Trinket = TrinketType.TRINKET_NOSE_GOBLIN }
)

return NoseGoblin