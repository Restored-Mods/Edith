local Pinhead = {}
local Helpers = EdithRestored.Helpers

--- Had to borrow because local function
local function isPinheadUseSuccessful(player)
	local chance = math.max(5, 10 + (player:GetCollectibleNum(FiendFolio.ITEM.COLLECTIBLE.PINHEAD) * 10) + (player.Luck * 5))
	if math.random() * 50 <= chance then
		return true
	end
end

local function getStackedPinheadDuration(player, secondHandMultiplier)
	local base = 210 
	local result = math.ceil(base * (math.log(math.max(1, player:GetCollectibleNum(FiendFolio.ITEM.COLLECTIBLE.PINHEAD)), 5) + 1))
	return result * secondHandMultiplier
end

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
---@param force boolean
function Pinhead:OnStomp(player, stompDamage, bombLanding, isDollarBill, isFruitCake, force)
	if isPinheadUseSuccessful(player) then
		local secondHandMultiplier = getStackedPinheadDuration(player, player:GetTrinketMultiplier(TrinketType.TRINKET_SECOND_HAND) + 1)
		for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
			FiendFolio.AddSewn(enemy, player, secondHandMultiplier)
		end
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	Pinhead.OnStomp,
	{ Item = FiendFolio.ITEM.COLLECTIBLE.PINHEAD }
)

return Pinhead
