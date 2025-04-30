local BlastBoots = {}
local sfx = SFXManager()
local timerColor = Color(1, 1, 1, 1, 0.5)
local BlastBootsID = EdithRestored.Enums.CollectibleType.COLLECTIBLE_BLASTING_BOOTS

local BootsJumpInfo = {
    Height = 13,
    Speed = 1,
    Flags = JumpLib.Flags.NO_HURT_PITFALL | JumpLib.Flags.FAMILIAR_FOLLOW_ORBITALS | JumpLib.Flags.FAMILIAR_FOLLOW_TEARCOPYING,
    Tags = {"BlastingBootsJump"}
}

---@param player EntityPlayer
---@param flags DamageFlag | integer
function BlastBoots:PreBombDamage(player, _, flags)
    if flags & DamageFlag.DAMAGE_EXPLOSION == 0 or not player:HasCollectible(BlastBootsID) then return end
    JumpLib:Jump(player, BootsJumpInfo)
    return false
end
EdithRestored:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, BlastBoots.PreBombDamage)

---@param player EntityPlayer
function BlastBoots:AntiSoftlock(player)
    if not player:HasCollectible(BlastBootsID) then return end
    local playerData = EdithRestored:GetData(player)
    local movDir = player:GetMovementDirection()

    playerData.Antisoftlocktimer = playerData.Antisoftlocktimer or 150

    if not (movDir == Direction.NO_DIRECTION and not JumpLib:GetData(player).Jumping) then
        playerData.Antisoftlocktimer = 150
        return
    end

    playerData.Antisoftlocktimer = math.max(playerData.Antisoftlocktimer - 1, 0)
    local timer = playerData.Antisoftlocktimer

    if (timer <= 30 and timer > 0 and timer % 10 == 0)  then
        sfx:Play(SoundEffect.SOUND_BEEP, 1)
        player:SetColor(timerColor, 8, 1, true, false)
    end

    if timer ~= 0 then return end
    playerData.Antisoftlocktimer = 150
    JumpLib:Jump(player, BootsJumpInfo)

---@diagnostic disable-next-line: param-type-mismatch
    EdithRestored.Game:BombExplosionEffects(player.Position, 0, 0, Color.Default, player, 1, false, false, 0)
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, BlastBoots.AntiSoftlock)