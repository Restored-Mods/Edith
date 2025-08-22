local mod = EdithRestored

---@param player EntityPlayer
---@param inPit boolean
function mod:OnTechXStomp(player, _, inPit)
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) then return end
    if inPit then return end    
	local techLaser = player:FireTechXLaser(player.Position, Vector.Zero, 30, player, 1)
    techLaser:SetTimeout(30)
end
mod:AddCallback(
	JumpLib.Callbacks.ENTITY_LAND,
	mod.OnTechXStomp,
	{ tag = "EdithJump", type = EntityType.ENTITY_PLAYER }
)