local TimeItself = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param force boolean
---@param isStompPool table
function TimeItself:OnStomp(player, stompDamage, bombLanding, force, isStompPool)
	local secondHandMultiplier = player:GetTrinketMultiplier(TrinketType.TRINKET_SECOND_HAND) + 1
	if math.random() * 8 <= 2 + player.Luck * 0.4 then
		for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
			FiendFolio.AddMultiEuclidean(enemy, player, 180 * secondHandMultiplier)
		end
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	TimeItself.OnStomp,
	{ Item = FiendFolio.ITEM.COLLECTIBLE.TIME_ITSELF }
)

return TimeItself