local mod = EdithRestored

---@param player EntityPlayer
function mod:OnTechStomp(player)
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) then return end
    
    local LandPos = mod.Helpers.GetEdithTarget(player).Position --[[@as Vector]]
    local JumpPos = player.Position --[[@as Vector]]

    if not LandPos and not JumpPos then return end

    local PosDif = LandPos - JumpPos
    local dir = PosDif:Normalized()
    local len = PosDif:Length()
    local laser = player:FireTechLaser(JumpPos, LaserOffset.LASER_TECH1_OFFSET, dir)
    laser:SetMaxDistance(len)
end
mod:AddCallback(
	JumpLib.Callbacks.POST_ENTITY_JUMP,
	mod.OnTechStomp,
	{ tag = "EdithJump", type = EntityType.ENTITY_PLAYER }
)