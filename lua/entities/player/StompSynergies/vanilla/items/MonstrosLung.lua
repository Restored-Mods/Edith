local MonstrosLung = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param isDollarBill boolean
---@param isFruitCake boolean
function MonstrosLung:OnStomp(player, stompDamage, bombLanding, isDollarBill, isFruitCake)
    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_MONSTROS_LUNG)
    for _ = 1, 14 do
        local tear = player:FireTear(player.Position, Vector.FromAngle(rng:RandomInt(1, 360)):Resized(player.ShotSpeed * Helpers.GetTrueRange(player)), false, true, false, player)
        tear.SizeMulti = Vector.One:Resized(rng:RandomInt(90, 133) / 100)
        tear.FallingSpeed = rng:RandomInt(-15, -3)
        tear.Height = rng:RandomInt(-20, -10)
        tear.FallingAcceleration = rng:RandomInt(500, 600) / 1000
    end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	MonstrosLung.OnStomp,
	{ Item = CollectibleType.COLLECTIBLE_MONSTROS_LUNG }
)

return MonstrosLung