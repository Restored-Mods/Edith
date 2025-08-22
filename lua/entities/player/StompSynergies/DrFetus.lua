local mod = EdithRestored
local game = Game()

---@param player EntityPlayer
---@param inPit boolean
function mod:OnDrFetusStomp(player, _, inPit)
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) then return end
    if inPit then return end    
    if mod:GetData(player).BombStomp then return end

    game:BombExplosionEffects(player.Position, player.Damage * 5, player.TearFlags, Color.Default, player, 1, true, false)
end
mod:AddCallback(
	JumpLib.Callbacks.ENTITY_LAND,
	mod.OnDrFetusStomp,
	{ tag = "EdithJump", type = EntityType.ENTITY_PLAYER }
)