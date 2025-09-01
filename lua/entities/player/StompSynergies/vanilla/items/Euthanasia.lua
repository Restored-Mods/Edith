local Euthanasia = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param forced boolean
---@param isStompPool table
function Euthanasia:OnStomp(player, stompDamage, bombLanding, forced, isStompPool)
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_EUTHANASIA)
	local chance = math.min(0.25, 1 / (30 - Helpers.Clamp(player.Luck * 2, 0, 29))) + 1
	if rng:RandomFloat() <= chance or isStompPool.Pool3DollarBill or isStompPool.PoolFruitCake then
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