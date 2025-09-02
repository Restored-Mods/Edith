local HypnoRing = {}
local Helpers = EdithRestored.Helpers

local function isHypnoRingUseSuccessful(player)
	local chance = (5 * player:GetCollectibleNum(FiendFolio.ITEM.COLLECTIBLE.HYPNO_RING)) + math.min(player.Luck, 10) / 3
	chance = math.min(math.max(1, chance), 20)
	if math.random() * 25 <= chance then
		return true
	end
end

local function getStackedHypnoRingDuration(player, secondHandMultiplier)
	local base = 180 * secondHandMultiplier 
	local result = math.ceil(base * (math.log(math.max(1, player:GetCollectibleNum(FiendFolio.ITEM.COLLECTIBLE.HYPNO_RING)), 10) + 1))
	return result * secondHandMultiplier
end

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param force boolean
---@param isStompPool table
function HypnoRing:OnStomp(player, stompDamage, bombLanding, force, isStompPool)
	if isHypnoRingUseSuccessful(player) then
		local secondHandMultiplier = player:GetTrinketMultiplier(TrinketType.TRINKET_SECOND_HAND) + 1
		for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
			FiendFolio.AddDrowsy(enemy, player, 60, getStackedHypnoRingDuration(player, secondHandMultiplier))
		end
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	HypnoRing.OnStomp,
	{ Item = FiendFolio.ITEM.COLLECTIBLE.HYPNO_RING	 }
)

return HypnoRing