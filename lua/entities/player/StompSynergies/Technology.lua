local Technology = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
function Technology:OnTechStomp(player)
    local LandPos = Helpers.GetEdithTarget(player).Position --[[@as Vector]]
    local JumpPos = player.Position

    if not LandPos and not JumpPos then return end

    local PosDif = LandPos - JumpPos
    local dir = PosDif:Normalized()
    local len = PosDif:Length()
    local laser = player:FireTechLaser(JumpPos, LaserOffset.LASER_TECH1_OFFSET, dir)
    laser:SetMaxDistance(len)
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_JUMPING,
	Technology.OnTechStomp,
	CollectibleType.COLLECTIBLE_TECHNOLOGY
)