local ToyPiano = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param forced boolean
---@param isStompPool table
function ToyPiano:OnStomp(player, stompDamage, bombLanding, forced, isStompPool)
	if math.random() * 9 <= 2 + player.Luck * 2.5 / 12 then
		local secondHandMultiplier = player:GetTrinketMultiplier(TrinketType.TRINKET_SECOND_HAND) + 1
		for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
			FiendFolio.AddDoom(enemy, player, 180 * secondHandMultiplier, 3, player.Damage * 5)
		end
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	ToyPiano.OnStomp,
	{ Item = FiendFolio.ITEM.COLLECTIBLE.TOY_PIANO }
)

return ToyPiano
