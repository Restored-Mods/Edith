local PawnBaby = {}
local Helpers = include("lua.helpers.Helpers")

local pawnBabyDesc = Isaac.GetItemConfig():GetCollectible(TC_SaltLady.Enums.CollectibleType.COLLECTIBLE_PAWN_BABY)
local fireCoolDown = 20

local floatDir = {[Direction.NO_DIRECTION] = "Down", [Direction.UP] = "Up", [Direction.DOWN] = "Down", [Direction.LEFT] = "Side", [Direction.RIGHT] = "Side"}
local vecDir = {[Direction.NO_DIRECTION] = Vector(0, 0), [Direction.UP] = Vector(0, -1), [Direction.DOWN] = Vector(0, 1), [Direction.LEFT] = Vector(-1, 0),[Direction.RIGHT] = Vector(1, 0)}

---@param player EntityPlayer
---@param cache CacheFlag | integer
function PawnBaby:Cache(player, cache)
    local numFamiliars = player:GetCollectibleNum(TC_SaltLady.Enums.CollectibleType.COLLECTIBLE_PAWN_BABY) + player:GetEffects():GetCollectibleEffectNum(TC_SaltLady.Enums.CollectibleType.COLLECTIBLE_PAWN_BABY)
	player:CheckFamiliar(TC_SaltLady.Enums.Familiars.PAWN_BABY.Variant, numFamiliars, player:GetCollectibleRNG(TC_SaltLady.Enums.CollectibleType.COLLECTIBLE_PAWN_BABY), pawnBabyDesc)
end
TC_SaltLady:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, PawnBaby.Cache, CacheFlag.CACHE_FAMILIARS)

---@param familiar EntityFamiliar
function PawnBaby:Init(familiar)
    familiar:AddToFollowers()
    familiar.FireCooldown = 5
    familiar.State = 0
end
TC_SaltLady:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, PawnBaby.Init, TC_SaltLady.Enums.Familiars.PAWN_BABY.Variant)

local function ChangeToSaltTear(tear)
	tear:ChangeVariant(TearVariant.ROCK)
	tear.Color = Color(
		tear.Color.R + 0.8, 
		tear.Color.G + 1, 
		tear.Color.B + 1, 
		tear.Color.A, 
		tear.Color.RO, 
		tear.Color.GO, 
		tear.Color.BO
	)
end

---@param familiar EntityFamiliar
function PawnBaby:Update(familiar)    
    local sprite = familiar:GetSprite()
    local player = familiar.Player
    local data = Helpers.GetData(familiar)
    local fireDir = player:GetFireDirection()
    local tearcd = math.ceil(fireCoolDown / (player:GetTrinketMultiplier(TrinketType.TRINKET_FORGOTTEN_LULLABY) + 1))
    local bffBonus = player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and 1 or 0
    familiar.FireCooldown = math.max(0, math.min(familiar.FireCooldown - 1, tearcd))
    if familiar.State == 0 then
        data.EnPassantCooldown = data.EnPassantCooldown and (math.max(0, data.EnPassantCooldown - 1)) or 0
        if fireDir ~= Direction.NO_DIRECTION then
            local tearTrajectory = vecDir[fireDir]
            if player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED) or player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK) then
                tearTrajectory = player:GetAimDirection()
            end
            data.animDir = fireDir
            local tearTarget = Helpers.GetNearestEnemy(familiar.Position)
            if (player:HasCollectible(CollectibleType.COLLECTIBLE_KING_BABY, true)) and tearTarget and (not tearTarget:ToPlayer()) then
                tearTrajectory = (tearTarget.Position - familiar.Position):Normalized()
                data.animDir = Helpers.VecToDir(tearTrajectory)
            end
            sprite.FlipX = data.animDir == Direction.LEFT
            if familiar.FireCooldown <= 0 then
                local trajectory = tearTrajectory * 9 + player.Velocity
                if trajectory:Length() < 9 then
                    trajectory:Resize(9)
                end
                local tear = familiar:FireProjectile(Vector.Zero)
                tear.Velocity = trajectory
                --local tear = Isaac.Spawn(2, 0, 0, familiar.Position + vecDir[data.animDir]:Resized(5), trajectory, familiar):ToTear()
                tear.Scale = 0.6 + 0.2 * bffBonus
                ChangeToSaltTear(tear)
                tear.CollisionDamage = 3.5 * (1 + bffBonus)
                if familiar:GetDropRNG():RandomInt(5) == 1 then
                    tear:AddTearFlags(TearFlags.TEAR_FEAR)
                    tear.Color = Color(0.4, 0.15, 0.38, 1, 0., 0, 0.)
                end
                if player:HasTrinket(TrinketType.TRINKET_BABY_BENDER) then
                    tear:AddTearFlags(TearFlags.TEAR_HOMING)
                    tear.Color = Color(0.4, 0.15, 0.38, 1, 0.27843, 0, 0.4549)         
                end
                sprite:Play("FloatShoot"..floatDir[data.animDir], false)
                familiar.FireCooldown = tearcd
            elseif (familiar.FireCooldown > 0) and (familiar.FireCooldown <= tearcd - tearcd/2) and (data.animDir ~= nil) and (not sprite:IsPlaying("Float"..floatDir[data.animDir])) then
                sprite:Play("Float"..floatDir[data.animDir], false)
            end
        --after shooting, go back to idle animation
        else
            if (familiar.FireCooldown <= 0) then
                sprite:Play("Float"..floatDir[fireDir], false)
            end
        end
        familiar:FollowParent()
    else
        if data.EnPassant then
            if not data.EnPassant:IsDead() then
                familiar.Position = data.EnPassant.Position
            else
                data.EnPassant = nil
                familiar.Velocity = Vector.Zero
            end
        end
        if sprite:IsFinished("Jump") then
            sprite:Play("Land", true)
        end
        if sprite:IsFinished("Land") then
            familiar.State = 0
            familiar:AddToFollowers()
        end
        if sprite:IsEventTriggered("Land") and data.EnPassant then
            SFXManager():Play(SoundEffect.SOUND_FETUS_FEET, 1.2, 0, false, 0.8, 0)
            if data.EnPassant:IsBoss() then
                data.EnPassant:TakeDamage(data.EnPassant.MaxHitPoints / 5, DamageFlag.DAMAGE_CRUSH, EntityRef(familiar), 30)
            else
                data.EnPassant:Kill()
            end
            familiar.Velocity = Vector.Zero
            data.EnPassant = nil
        end
    end
end
TC_SaltLady:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, PawnBaby.Update, TC_SaltLady.Enums.Familiars.PAWN_BABY.Variant)

---@param familiar EntityFamiliar
---@param collider Entity
---@param low boolean
function PawnBaby:Colliding(familiar, collider, low)    
    if familiar.State ~= 0 then return end
    local sprite = familiar:GetSprite()
    local data = Helpers.GetData(familiar)
    if collider:ToNPC() and data.EnPassantCooldown and data.EnPassantCooldown <= 0 then
        local npc = collider:ToNPC()
        if npc:IsActiveEnemy() and npc:IsVulnerableEnemy() then
            local rng = npc:GetDropRNG()
            if rng:RandomInt(2) == 1 then
                data.EnPassant = npc
                familiar.State = 1
                familiar:RemoveFromFollowers()
                sprite:Play("Jump", true)
            end
            data.EnPassantCooldown = 60
        end
    end
end
TC_SaltLady:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, PawnBaby.Colliding, TC_SaltLady.Enums.Familiars.PAWN_BABY.Variant)