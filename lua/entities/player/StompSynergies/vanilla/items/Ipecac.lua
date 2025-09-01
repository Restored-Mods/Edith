local Ipecac = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param forced boolean
---@param isStompPool table
function Ipecac:OnStomp(player, stompDamage, bombLanding, forced, isStompPool)
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