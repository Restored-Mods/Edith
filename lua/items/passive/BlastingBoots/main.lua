local BlastBoots = {}

---@param player EntityPlayer
---@param flags DamageFlag | integer
function BlastBoots:PreBombDamage(player, _, flags)
    if flags & DamageFlag.DAMAGE_EXPLOSION == 0 or not player:HasCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_BLASTING_BOOTS) then return end

    JumpLib:Jump(player, {
        Height = 13,
        Speed = 1,
        Flags = JumpLib.Flags.NO_HURT_PITFALL | JumpLib.Flags.FAMILIAR_FOLLOW_ORBITALS_ONLY | JumpLib.Flags.FAMILIAR_FOLLOW_TEARCOPYING_ONLY,
        Tags = {"BlastingBootsJump"}
    })

    return false
end
EdithRestored:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, BlastBoots.PreBombDamage)