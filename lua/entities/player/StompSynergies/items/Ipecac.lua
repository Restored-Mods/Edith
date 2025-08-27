local Ipecac = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function Ipecac:OnStomp(player, bombLanding, isDollarBill, isFruitCake)
    for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
        enemy:AddPoison(EntityRef(player), 60, player.Damage)
    end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	Ipecac.OnStomp,
	{ Item = CollectibleType.COLLECTIBLE_IPECAC, PoolFruitCake = true }
)

return Ipecac