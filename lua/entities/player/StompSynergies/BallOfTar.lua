local BallOfTar = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function BallOfTar:OnStomp(player, bombLanding, isDollarBill, isFruitCake)
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_BALL_OF_TAR)
	local chance = 1 / (10 - (Helpers.Clamp(player.Luck, 0, 27) / 3))
	if rng:RandomFloat() <= chance or isDollarBill or isFruitCake then
		for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
			enemy:AddSlowing(EntityRef(player), 60, 1, Color(0.15, 0.15, 0.15, 1, 0, 0, 0))
		end
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_BLACK, 0, player.Position, Vector.Zero, player)
			:ToEffect().Timeout =
			60
	end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	BallOfTar.OnStomp,
	{ Item = CollectibleType.COLLECTIBLE_BALL_OF_TAR, Pool3DollarBill = true, PoolFruitCake = true }
)

return BallOfTar