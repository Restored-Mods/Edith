local BlastBoots = {}

---@param e Entity
---@param amount integer
---@param flags DamageFlag | integer
---@param source EntityRef
---@param countdown integer
---@return boolean
function BlastBoots:OnBombDamage(e, amount, flags, source, countdown)
	if e and e:ToPlayer() then
        local player = e:ToPlayer()
        if not player:HasCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_BLASTING_BOOTS) then
            return
        end
		if flags & DamageFlag.DAMAGE_EXPLOSION == DamageFlag.DAMAGE_EXPLOSION then
            JumpLib:Jump(player, {
                Height = 13,
                Speed = 1,
                Flags = JumpLib.Flags.NO_HURT_PITFALL | JumpLib.Flags.FAMILIAR_FOLLOW_ORBITALS_ONLY | JumpLib.Flags.FAMILIAR_FOLLOW_TEARCOPYING_ONLY,
                Tags = {"BlastingBootsJump"}
            })
			return false
		end
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, BlastBoots.OnBombDamage, EntityType.ENTITY_PLAYER)