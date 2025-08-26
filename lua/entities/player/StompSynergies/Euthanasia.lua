local Euthanasia = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param bombLanding boolean
---@param isDollarBill boolean
function Euthanasia:OnEuthanasiaStomp(player, bombLanding, isDollarBill, isFruitCake)
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_EUTHANASIA)
	local chance = math.min(0.25, 1 / (30 - Helpers.Clamp(player.Luck * 2, 0, 29))) + 1
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
	EdithRestored.Enums.Callbacks.ON_EDITH_LANDING,
	Euthanasia.OnEuthanasiaStomp,
	{ Item = CollectibleType.COLLECTIBLE_EUTHANASIA, Pool3DollarBill = true, PoolFruitCake = true }
)
