local SaltyBaby = {}
local Helpers = include("lua.helpers.Helpers")

local floatDir = {[Direction.NO_DIRECTION] = "Down", [Direction.UP] = "Up", [Direction.DOWN] = "Down", [Direction.LEFT] = "Side", [Direction.RIGHT] = "Side"}
local vecDir = {[Direction.NO_DIRECTION] = Vector(0, 0), [Direction.UP] = Vector(0, -1), [Direction.DOWN] = Vector(0, 1), [Direction.LEFT] = Vector(-1, 0),[Direction.RIGHT] = Vector(1, 0)}
local fireCoolDown = 25
local chargeCoolDown = 35

local saltyBabyDesc = Isaac.GetItemConfig():GetCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_SALTY_BABY)
local function RecheckCharge(familiar)
    local data = Helpers.GetData(familiar)
    data.Charge = data.Charge or chargeCoolDown
end

---@param player EntityPlayer
---@param numLeft integer
---@param position Vector
---@param step Vector
local function SpawnSaltCreep(player, numLeft, position, step, rotation, delay)
    if numLeft <= 0 then
        return
    end
    local rng = player:GetCollectibleRNG(EdithRestored.Enums.CollectibleType.COLLECTIBLE_SALTY_BABY)
    
    local salt = Isaac.Spawn(1000, EdithRestored.Enums.Entities.SALT_CREEP.Variant, EdithRestored.Enums.Entities.SALT_CREEP.SubType, position, Vector.Zero, player):ToEffect()
    --[[for _ = 1, math.min(2, rng:RandomInt(5)) do
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TOOTH_PARTICLE, 0, salt.Position, RandomVector() * rng:RandomFloat() * rng:RandomInt(6), player):ToEffect()
    end]]
    salt.Timeout = 120
    salt:SetTimeout(120)
    salt.CollisionDamage = 0
    --salt.SortingLayer = SortingLayer.SORTING_BACKGROUND
    local bffScale = player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and 1.3 or 1
    salt.Scale = salt.Scale * bffScale
    salt.SpriteScale = salt.SpriteScale * bffScale
    local data = Helpers.GetData(salt)
    data.SaltyBabyTrail = true
    data.SaltyBabyTrailDelay = delay
    data.SaltyBabyTrailStep = step
    data.SaltyBabyTrailNum = numLeft - 1
    data.SaltyBabyTrailRotation = rotation
end

---@param player EntityPlayer
---@param cache CacheFlag | integer
function SaltyBaby:Cache(player, cache)
    local numFamiliars = player:GetCollectibleNum(EdithRestored.Enums.CollectibleType.COLLECTIBLE_SALTY_BABY) + player:GetEffects():GetCollectibleEffectNum(EdithRestored.Enums.CollectibleType.COLLECTIBLE_SALTY_BABY)
	player:CheckFamiliar(EdithRestored.Enums.Familiars.SALTY_BABY.Variant, numFamiliars, player:GetCollectibleRNG(EdithRestored.Enums.CollectibleType.COLLECTIBLE_SALTY_BABY), saltyBabyDesc)
end
EdithRestored:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, SaltyBaby.Cache, CacheFlag.CACHE_FAMILIARS)

---@param familiar EntityFamiliar
function SaltyBaby:Init(familiar)
    familiar:AddToFollowers()
    familiar.FireCooldown = fireCoolDown
    RecheckCharge(familiar)
end
EdithRestored:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, SaltyBaby.Init, EdithRestored.Enums.Familiars.SALTY_BABY.Variant)

---@param familiar EntityFamiliar
function SaltyBaby:Update(familiar)
    local sprite = familiar:GetSprite()
    local player = familiar.Player
    local data = Helpers.GetData(familiar)
    local fireDir = player:GetFireDirection()
    local tearcd = math.ceil(fireCoolDown / (player:GetTrinketMultiplier(TrinketType.TRINKET_FORGOTTEN_LULLABY) + 1))
    local chargecd = math.ceil(chargeCoolDown / (player:GetTrinketMultiplier(TrinketType.TRINKET_FORGOTTEN_LULLABY) + 1))
    local target = Helpers.GetNearestEnemy(familiar.Position)
    familiar.FireCooldown = math.max(0, familiar.FireCooldown - 1)
    RecheckCharge(familiar)
    local tearTrajectory = vecDir[fireDir]
    data.animDir = fireDir
    local tearTarget = Helpers.GetNearestEnemy(familiar.Position)
    if (player:HasCollectible(CollectibleType.COLLECTIBLE_KING_BABY, true)) and tearTarget and (not tearTarget:ToPlayer()) then
        tearTrajectory = (tearTarget.Position - familiar.Position):Normalized()
        data.animDir = Helpers.VecToDir(tearTrajectory)
    end
    if fireDir == Direction.NO_DIRECTION or familiar.FireCooldown > 0 then
        if data.Charge <= 0 then
            sprite:Play("FloatShoot"..sprite:GetAnimation():gsub("FloatCharged", ""), false)
            familiar.FireCooldown = tearcd
            data.Charge = chargecd
            SFXManager():Play(EdithRestored.Enums.SFX.SaltShaker.SHAKE, 1, 0)
            local trail_rotation = 20
            local angle = -90 -- we rotate the shot direction because we're curving two vertical creep trails
            local bffScale = player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and 1.3 or 1
            for _ = 1, 2 do
                SpawnSaltCreep(player, 9, familiar.Position + data.Trajectory:Rotated(angle):Resized(10), data.Trajectory:Rotated(angle):Resized(25 * bffScale), trail_rotation, 2)
                trail_rotation = -trail_rotation -- symmetrical trails
                angle = -angle
            end
        elseif data.Charge > 0 and data.Charge < chargecd then
            data.Charge = chargecd
        end
        if familiar.FireCooldown <= 0 then
            sprite:Play("FloatDown", false)
        end
    elseif familiar.FireCooldown <= 0 then
        data.Charge = math.max(0, data.Charge - 1)
        data.Trajectory = vecDir[fireDir]
        local vereToFire = fireDir
        if (player:HasCollectible(CollectibleType.COLLECTIBLE_KING_BABY, true)) and target and (not target:ToPlayer()) then
            data.Trajectory = (target.Position - familiar.Position):Normalized()
            vereToFire = Helpers.VecToDir(data.Trajectory)
        end
        sprite.FlipX = vereToFire == Direction.LEFT
        local floatAnim = "Float"
        if data.Charge <= 0 then
            floatAnim = floatAnim.."Charged"
        end
        if not sprite:IsPlaying(floatAnim..floatDir[vereToFire]) then
            local currentFrame = sprite:GetFrame()
            sprite:Play(floatAnim..floatDir[vereToFire], false)
            sprite:SetFrame(currentFrame)
        end
    end
    familiar:FollowParent()
end
EdithRestored:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, SaltyBaby.Update, EdithRestored.Enums.Familiars.SALTY_BABY.Variant)

---@param familiar EntityFamiliar
function SaltyBaby:Render(familiar)
    local player = familiar.Player
	local fireDir = player:GetFireDirection()
    local data = Helpers.GetData(familiar)
	--siren lullaby synergy
    local chargecd = chargeCoolDown / (player:GetTrinketMultiplier(TrinketType.TRINKET_FORGOTTEN_LULLABY) + 1)
	--animations		
    if not data.ChargeBar then
        data.ChargeBar = Sprite()
        data.ChargeBar:Load("gfx/chargebar.anm2", true)
        data.ChargeBar:Play("Disappear", true)
        data.ChargeBar:SetLastFrame()
    end
    data.ChargeBar.PlaybackSpeed = 0.5
    data.ChargeBar.Offset = Vector(10 * familiar.SpriteScale.X, -30 * familiar.SpriteScale.Y)
    RecheckCharge(familiar)
    if not Game():IsPaused() then
        if fireDir ~= Direction.NO_DIRECTION then
            if data.Charge <= 0 then
                if not data.ChargeBar:GetAnimation():match("Charged") then
                    data.ChargeBar:Play("StartCharged", true)
                end
                if data.ChargeBar:IsFinished("StartCharged") then
                    data.ChargeBar:Play("Charged", true)
                end
            else
                if not data.ChargeBar:IsPlaying("Charging") then
                    data.ChargeBar:Play("Charging", true)
                else
                    data.ChargeBar:SetFrame(math.floor((1 - data.Charge/chargecd)*100))
                end
            end
        elseif data.ChargeBar:GetAnimation() ~= "Disappear" then
            data.ChargeBar:Play("Disappear", true)
        end
        data.ChargeBar:Update()
    end
    
    if data.Charge < chargecd or data.ChargeBar:IsPlaying("Disappear") and not data.ChargeBar:IsFinished("Disappear") then
        data.ChargeBar:Render(Game():GetRoom():WorldToScreenPosition(familiar.Position), Vector.Zero, Vector.Zero)
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_RENDER, SaltyBaby.Render, EdithRestored.Enums.Familiars.SALTY_BABY.Variant)

---@param creep EntityEffect
function SaltyBaby:CreepUpdate(creep)
    local data = Helpers.GetData(creep)
    if data.SaltyBabyTrail and type(data.SaltyBabyTrailDelay) == "number" and creep.FrameCount == data.SaltyBabyTrailDelay then
        data.SaltyBabyTrailStep = data.SaltyBabyTrailStep:Rotated(data.SaltyBabyTrailRotation)
        SpawnSaltCreep(creep.SpawnerEntity:ToPlayer(), data.SaltyBabyTrailNum, creep.Position + data.SaltyBabyTrailStep, data.SaltyBabyTrailStep, data.SaltyBabyTrailRotation, data.SaltyBabyTrailDelay)
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, SaltyBaby.CreepUpdate, EdithRestored.Enums.Entities.SALT_CREEP.Variant)

function SaltyBaby:Priority(familiar)
    return FollowerPriority.SHOOTER
end
EdithRestored:AddCallback(ModCallbacks.MC_GET_FOLLOWER_PRIORITY, SaltyBaby.Priority, EdithRestored.Enums.Familiars.SALTY_BABY.Variant)
