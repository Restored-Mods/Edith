local GhostBombs = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param bombDamage number
---@param radius number
---@param hasBombs boolean
---@param isGigaBomb boolean
function GhostBombs:OnStompExplosion(player, bombDamage, radius, hasBombs, isGigaBomb)
	local ghost =
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HUNGRY_SOUL, 1, player.Position, Vector.Zero, player)
			:ToEffect()
	ghost:SetTimeout(300)
	SFXManager():Play(SoundEffect.SOUND_FLOATY_BABY_ROAR, 1, 0, false, 1.75, 0)
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP_EXPLOSION,
	GhostBombs.OnStompExplosion,
	{ Item = CollectibleType.COLLECTIBLE_GHOST_BOMBS }
)

return GhostBombs
