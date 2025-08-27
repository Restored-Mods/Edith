local Euthanasia = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function Euthanasia:OnStomp(player, bombLanding, isDollarBill, isFruitCake)
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_EUTHANASIA)
	local chance = math.min(0.25, 1 / (30 - Helpers.Clamp(player.Luck * 2, 0, 29))) + 1
	if rng:RandomFloat() <= chance or isDollarBill or isFruitCake then
		for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
			if not enemy:IsBoss() then
				enemy:Kill()
			else
				enemy:TakeDamage(player.Damage * 3, 0, EntityRef(player), 0)
			end
		end
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	Euthanasia.OnStomp,
	{ Item = CollectibleType.COLLECTIBLE_EUTHANASIA, Pool3DollarBill = true, PoolFruitCake = true }
)

return Euthanasia