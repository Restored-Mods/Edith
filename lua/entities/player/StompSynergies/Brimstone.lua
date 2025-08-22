local mod = EdithRestored

---@param player EntityPlayer
---@param inPit boolean
function mod:OnBrimStomp(player, _, inPit)
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then return end
    if inPit then return end    
	player:FireBrimstoneBall(player.Position, Vector.Zero, Vector.Zero)
end
mod:AddCallback(
	JumpLib.Callbacks.ENTITY_LAND,
	mod.OnBrimStomp,
	{ tag = "EdithJump", type = EntityType.ENTITY_PLAYER }
)