local MomsContacts = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function MomsContacts:OnStomp(player, stompDamage, bombLanding, isDollarBill, isFruitCake)
    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_MOMS_CONTACTS)
    local chance = math.min(1 / (5 - Helpers.Clamp(player.Luck * 0.15, 0, 4)), 0.5)
    if rng:RandomFloat() <= chance or isDollarBill or isFruitCake then
        for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
            enemy:AddFreeze(EntityRef(player), 60)
        end
    end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	MomsContacts.OnStomp,
    { Item = CollectibleType.COLLECTIBLE_MOMS_CONTACTS, Pool3DollarBill = true, PoolFruitCake = true }
)

return MomsContacts