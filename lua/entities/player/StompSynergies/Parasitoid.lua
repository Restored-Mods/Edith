local Parasitoid = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function Parasitoid:OnStomp(player, bombLanding, isDollarBill, isFruitCake)
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_PARASITOID)
	local chance = math.min(0.5, 1 / (7 - Helpers.Clamp(player.Luck, 0, 6))) + 1
	if rng:RandomFloat() <= chance or isDollarBill or isFruitCake then
		local outcome = WeightedOutcomePicker()
		outcome:AddOutcomeWeight(FamiliarVariant.BLUE_FLY, 50)
		outcome:AddOutcomeWeight(FamiliarVariant.BLUE_SPIDER, 50)
		for _ = 1, rng:RandomInt(1,2) do
			Isaac.Spawn(EntityType.ENTITY_FAMILIAR, outcome:PickOutcome(rng), 0, player.Position, Vector.Zero, player)
		end
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	Parasitoid.OnStomp,
	{ Item = CollectibleType.COLLECTIBLE_PARASITOID, Pool3DollarBill = true, PoolFruitCake = true }
)

return Parasitoid