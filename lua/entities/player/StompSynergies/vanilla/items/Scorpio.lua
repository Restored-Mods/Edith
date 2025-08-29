local Scorpio = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function Scorpio:OnStomp(player, stompDamage, bombLanding, isDollarBill, isFruitCake)
    for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
        enemy:AddPoison(EntityRef(player), 60, player.Damage)
    end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	Scorpio.OnStomp,
	{ Item = CollectibleType.COLLECTIBLE_SCORPIO, Pool3DollarBill = true }
)

return Scorpio