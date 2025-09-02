local Crucifix = {}
local Helpers = EdithRestored.Helpers

local function getStackedCrucifixDuration(player, secondHandMultiplier)
	local base = 150 
	local result = math.ceil(base * (math.log(math.max(1, player:GetCollectibleNum(FiendFolio.ITEM.COLLECTIBLE.CRUCIFIX)), 5) + 1))
	return result * secondHandMultiplier
end

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param force boolean
---@param isStompPool table
function Crucifix:OnStomp(player, stompDamage, bombLanding, force, isStompPool)
	local secondHandMultiplier = player:GetTrinketMultiplier(TrinketType.TRINKET_SECOND_HAND) + 1
	for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
		FiendFolio.MarkForMartyrDeath(enemy, player, getStackedCrucifixDuration(player, secondHandMultiplier), false)
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	Crucifix.OnStomp,
	{ Item = FiendFolio.ITEM.COLLECTIBLE.CRUCIFIX }
)

return Crucifix