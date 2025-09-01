local EyeSore = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param stompDamage number
---@param bombLanding boolean
---@param forced boolean
---@param isStompPool table
function EyeSore:OnStomp(player, stompDamage, bombLanding, forced, isStompPool)
    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_EYE_SORE)
    if rng:RandomFloat() <= 0.45 then
        for _ = 1, rng:RandomInt(1, 3) do
            player:FireTear(player.Position, Vector.FromAngle(rng:RandomInt(1, 360)):Resized(player.ShotSpeed * Helpers.GetTrueRange(player)), false, true, false, player)
        end
    end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP,
	EyeSore.OnStomp,
    { Item = CollectibleType.COLLECTIBLE_EYE_SORE }
)

return EyeSore