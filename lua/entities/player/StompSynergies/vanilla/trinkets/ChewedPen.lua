local BallOfTar = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function BallOfTar:OnStomp(player, stompDamage, bombLanding, isDollarBill, isFruitCake)
	local rng = player:GetTrinketRNG(TrinketType.TRINKET_CHEWED_PEN)
	local chance = 1 / (10 - (Helpers.Clamp(player.Luck * 0.5, 0, 9)))
	if rng:RandomFloat() <= chance then
		for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
			enemy:AddSlowing(EntityRef(player), 60, 1, Color(0.15, 0.15, 0.15, 1, 0, 0, 0))
		end
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	BallOfTar.OnStomp,
	{ Trinket = TrinketType.TRINKET_CHEWED_PEN }
)

return BallOfTar