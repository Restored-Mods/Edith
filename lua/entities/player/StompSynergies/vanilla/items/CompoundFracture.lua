local CompoundFracture = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function CompoundFracture:OnStomp(player, stompDamage, bombLanding, isDollarBill, isFruitCake)
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_COMPOUND_FRACTURE)
	for _ = 1, rng:RandomInt(1, 3) do
		local tear = player:FireTear(player.Position, Vector.FromAngle(rng:RandomInt(1, 360)):Resized(player.ShotSpeed * Helpers.GetTrueRange(player)), false, true, false, player, 0.5)
		tear.SizeMulti = Vector.One
		tear.Size = 6
		tear:GetSprite():ReplaceSpritesheet(0, "gfx/tears_brokenbone.png", true)
		tear:ClearTearFlags(TearFlags.TEAR_BONE)
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	CompoundFracture.OnStomp,
	{ Item = CollectibleType.COLLECTIBLE_COMPOUND_FRACTURE, PoolFruitCake = true }
)

return CompoundFracture