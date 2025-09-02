local LawnDarts = {}
local Helpers = EdithRestored.Helpers

local function isLawnDartsUseSuccessful(player)
	local chance = (2 * player:GetCollectibleNum(FiendFolio.ITEM.COLLECTIBLE.LAWN_DARTS)) + player.Luck * 0.4
	chance = math.max(0.5, chance)
	if math.random() * 8 <= chance then
		return true
	end
end

local function getStackedLawnDartsDuration(player, secondHandMultiplier)
	local base = 180 
	local result = math.ceil(base * (math.log(math.max(1, player:GetCollectibleNum(FiendFolio.ITEM.COLLECTIBLE.LAWN_DARTS)), 5) + 1))
	return result * secondHandMultiplier
end
---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param force boolean
---@param isStompPool table
function LawnDarts:OnStomp(player, stompDamage, bombLanding, force, isStompPool)
	if isLawnDartsUseSuccessful(player) then
		local secondHandMultiplier = player:GetTrinketMultiplier(TrinketType.TRINKET_SECOND_HAND) + 1
		for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
			FiendFolio.AddBleed(enemy, player, getStackedLawnDartsDuration(player, secondHandMultiplier), player.Damage * 0.5)
		end
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	LawnDarts.OnStomp,
	{ Item = FiendFolio.ITEM.COLLECTIBLE.LAWN_DARTS }
)

return LawnDarts