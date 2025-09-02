local PrankCookie = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param force boolean
---@param isStompPool table
function PrankCookie:OnStomp(player, stompDamage, bombLanding, force, isStompPool)
	local secondHandMultiplier = player:GetTrinketMultiplier(TrinketType.TRINKET_SECOND_HAND) + 1
	for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
		FiendFolio:prankCookieRollLaserEffect(player, enemy, EntityRef(player), secondHandMultiplier)
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	PrankCookie.OnStomp,
	{ Item = FiendFolio.ITEM.COLLECTIBLE.PRANK_COOKIE }
)

return PrankCookie