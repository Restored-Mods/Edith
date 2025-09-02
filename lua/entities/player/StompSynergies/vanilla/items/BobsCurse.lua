local BobsCurse = {}
local Helpers = EdithRestored.Helpers

---@param player EntityPlayer
---@param bombDamage number
---@param radius number
---@param hasBombs boolean
---@param isGigaBomb boolean
function BobsCurse:OnStompExplosion(player, bombDamage, radius, hasBombs, isGigaBomb)
	if
			player:HasCollectible(CollectibleType.COLLECTIBLE_BOBS_CURSE)
			or player:GetBombFlags() & TearFlags.TEAR_POISON > 0
		then
			local poisonCloud = Isaac.Spawn(
				EntityType.ENTITY_EFFECT,
				EffectVariant.SMOKE_CLOUD,
				0,
				player.Position,
				Vector.Zero,
				player
			):ToEffect()
			poisonCloud:SetTimeout(150)
			if player:HasCollectible(CollectibleType.COLLECTIBLE_MR_MEGA) then
				poisonCloud.SpriteScale = Vector(1.75, 1.75)
			end
		end
end
EdithRestored:AddCallback(
	EdithRestored.Enums.Callbacks.ON_EDITH_STOMP_EXPLOSION,
	BobsCurse.OnStompExplosion,
	{ Item = CollectibleType.COLLECTIBLE_BOBS_CURSE }
)

return BobsCurse