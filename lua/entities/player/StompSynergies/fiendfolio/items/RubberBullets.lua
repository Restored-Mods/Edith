local RubberBullets = {}
local Helpers = EdithRestored.Helpers

local function isRubberBulletsUseSuccessful(player)
	local chance = math.min(12.5, (5 * player:GetCollectibleNum(FiendFolio.ITEM.COLLECTIBLE.RUBBER_BULLETS)) + player.Luck * 0.75)
	chance = math.max(1, chance)
	if math.random() * 25 <= chance then
		return true
	end
end

local function getStackedRubberBulletsDuration(player, secondHandMultiplier)
	local base = 120 
	local result = math.ceil(base * (math.log(math.max(1, player:GetCollectibleNum(FiendFolio.ITEM.COLLECTIBLE.RUBBER_BULLETS)), 5) + 1))
	return result * secondHandMultiplier
end

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param force boolean
---@param isStompPool table
function RubberBullets:OnStomp(player, stompDamage, bombLanding, force, isStompPool)
	if isRubberBulletsUseSuccessful(player) then
		local secondHandMultiplier = player:GetTrinketMultiplier(TrinketType.TRINKET_SECOND_HAND) + 1
		for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
			FiendFolio.AddBruise(enemy, player, getStackedRubberBulletsDuration(player, secondHandMultiplier), 1, 1)
		end
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	RubberBullets.OnStomp,
	{ Item = FiendFolio.ITEM.COLLECTIBLE.RUBBER_BULLETS }
)

return RubberBullets