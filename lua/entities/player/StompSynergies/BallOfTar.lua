local BallOfTar = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param bombLanding boolean
---@param isDollarBill boolean
function BallOfTar:OnBallOfTarStomp(player, bombLanding, isDollarBill)
    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_BALL_OF_TAR)
    local chance = 1 / (10 - (Helpers.Clamp(player.Luck, 0, 27) / 3))
	if rng:RandomFloat() <= chance or isDollarBill then
        for _, enemy in ipairs(Helpers.GetEnemiesInRadius(player.Position, Helpers.GetStompRadius())) do
            enemy:AddSlowing(EntityRef(player), 60, 1, Color(0.15, 0.15, 0.15, 1, 0, 0, 0))
        end
    end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_LANDING,
	BallOfTar.OnBallOfTarStomp,
	CollectibleType.COLLECTIBLE_BALL_OF_TAR
)