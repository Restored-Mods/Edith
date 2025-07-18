local BlastBoots = {}
local sfx = SFXManager()
local timerColor = Color(1, 1, 1, 1, 0.5)
local BlastBootsID = EdithRestored.Enums.CollectibleType.COLLECTIBLE_BLASTING_BOOTS
local Helpers = EdithRestored.Helpers

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

    if not (movDir == Direction.NO_DIRECTION and not JumpLib:GetData(player).Jumping and not playerData.EdithTargetMovementPosition) then
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
    local explosion = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_EXPLOSION, 0, player.Position, Vector.Zero, nil):ToEffect()
    explosion.SpriteScale = Vector.One:Resized(player.Size) / 20
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, BlastBoots.AntiSoftlock)

---@param player EntityPlayer
---@param jumpData JumpData
---@param inPit boolean
function BlastBoots:Landing(player, jumpData, inPit)
	if not inPit then
		Helpers.Stomp(player, false, false)

		for _, v in pairs(Isaac.FindInRadius(player.Position, 55, EntityPartition.BULLET)) do
			local projectile = v:ToProjectile() ---@cast projectile EntityProjectile
			local angle = ((player.Position - projectile.Position) * -1):GetAngleDegrees()
			projectile.Velocity = Vector.FromAngle(angle):Resized(10)
			projectile:AddProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)
			projectile:AddProjectileFlags(ProjectileFlags.HIT_ENEMIES)
		end
	end
end
EdithRestored:AddCallback(JumpLib.Callbacks.ENTITY_LAND, BlastBoots.Landing, {tag = "BlastingBootsJump", type = EntityType.ENTITY_PLAYER})

---@param player EntityPlayer
---@param jumpData JumpData
function BlastBoots:EdithMidAir(player, jumpData)
	if Helpers.CantMove(player) and player.ControlsEnabled then
        local vec = Helpers.GetMovementActionVector(player)
        if vec:Length() > 0 then
            player.Velocity = Helpers.Lerp(player.Velocity, vec:Resized(8*player.MoveSpeed), 0.2)
        end
    end
end
EdithRestored:AddCallback(JumpLib.Callbacks.ENTITY_UPDATE_30, BlastBoots.EdithMidAir, {tag = "BlastingBootsJump", type = EntityType.ENTITY_PLAYER, player = EdithRestored.Enums.PlayerType.EDITH})