local MysteriousLiquid = {}

---@param player EntityPlayer
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function MysteriousLiquid:OnStomp(player, bombLanding, isDollarBill, isFruitCake)
    local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, player.Position, Vector.Zero, player):ToEffect()
    creep:SetTimeout(25)
    creep.Timeout = 25
    creep.CollisionDamage = 1
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	MysteriousLiquid.OnStomp,
	{ Item = CollectibleType.COLLECTIBLE_MYSTERIOUS_LIQUID, Pool3DollarBill = true, PoolFruitCake = true }
)

return MysteriousLiquid