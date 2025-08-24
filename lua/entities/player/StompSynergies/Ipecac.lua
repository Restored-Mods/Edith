local Ipecac = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param bombLanding boolean
---@param isDollarBill boolean
function Ipecac:OnIpecacStomp(player, bombLanding, isDollarBill)
    for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
        enemy:AddPoison(EntityRef(player), 60, player.Damage)
    end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_LANDING,
	Ipecac.OnIpecacStomp,
	CollectibleType.COLLECTIBLE_IPECAC
)