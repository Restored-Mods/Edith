local PinkyEye = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
---@param forced boolean
function PinkyEye:OnStomp(player, stompDamage, bombLanding, isDollarBill, isFruitCake, forced)
    local rng = player:GetTrinketRNG(TrinketType.TRINKET_PINKY_EYE)
    local maxchance = 1 / (10 - Helpers.Clamp(player.Luck * 0.5, 0, 9))
    if rng:RandomFloat() <= maxchance or forced then
        for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
            enemy:AddPoison(EntityRef(player), 40, player.Damage)
        end
    end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	PinkyEye.OnStomp,
	{ Trinket = TrinketType.TRINKET_PINKY_EYE }
)

return PinkyEye