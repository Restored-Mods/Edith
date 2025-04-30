local SaltyBaby = {}
local Helpers = include("lua.helpers.Helpers")

local saltyBabyDesc = Isaac.GetItemConfig():GetCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_SALTY_BABY)

local function ChangeToEdithTear(tear)
	tear:ChangeVariant(TearVariant.ROCK)
	tear.Color = Color(
		tear.Color.R + 0.8 + (tear.Parent.Color.R - 1), 
		tear.Color.G + 1 + (tear.Parent.Color.G - 1), 
		tear.Color.B + 1 + (tear.Parent.Color.B - 1), 
		tear.Color.A + (tear.Parent.Color.A - 1), 
		tear.Color.RO + tear.Parent.Color.RO, 
		tear.Color.GO + tear.Parent.Color.GO, 
		tear.Color.BO + tear.Parent.Color.BO
	)
end

local baseRange = 6.5
local baseHeight = -23.45	
local maxBlocks = 6

local SaltCreepVar = EdithRestored.Enums.Entities.SALT_CREEP.Variant
local SaltCreepSubtype = EdithRestored.Enums.Entities.SALT_CREEP.SubType
local SaltyBabyVariant = EdithRestored.Enums.Familiars.SALTY_BABY.Variant

---@param familiar EntityFamiliar
local function ShootSaltyBabyTear(familiar, minTears, maxTears)
    local player = familiar.Player
    local rng = player:GetCollectibleRNG(EdithRestored.Enums.CollectibleType.COLLECTIBLE_SALTY_BABY)
    local baseMultiplier = -70 / baseRange
    local halfBaseHeight = baseHeight * 1.1
    local tearCount = rng:RandomInt(minTears, maxTears)
    local hasBFFS = player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)

    for _ = 1, tearCount do
        local tear = familiar:FireProjectile(RandomVector():Resized(1))
        tear.Velocity = tear.Velocity * rng:RandomInt(2, 6) / 10
        tear.FallingAcceleration = rng:RandomInt(70, 160) / 100
        local fallSpeedVar = rng:RandomInt(180, 220) / 100
        tear.FallingSpeed = baseMultiplier * fallSpeedVar
        tear.Height = halfBaseHeight
        tear.Scale = 1
        tear.CollisionDamage = tear.CollisionDamage * rng:RandomInt(8, 12) / 10
        if hasBFFS then
            tear.CollisionDamage = tear.CollisionDamage * 1.25
        end
        ChangeToEdithTear(tear)
        tear:Update()
    end
end		

---@param familiar EntityFamiliar
function SaltyBaby:OnSaltyBabyInit(familiar)
    familiar:AddToFollowers()
end
EdithRestored:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, SaltyBaby.OnSaltyBabyInit, SaltyBabyVariant)

---@param familiar EntityFamiliar
function SaltyBaby:OnSaltyBabyUpdate(familiar)
    familiar:FollowParent()

    local colCapsule = familiar:GetCollisionCapsule()
    local famData = EdithRestored:GetData(familiar)
    local sprite = familiar:GetSprite()

    famData.CurrentBlocks = famData.CurrentBlocks or 0
    famData.IsShattered = famData.IsShattered or false

    for _, proj in ipairs(Isaac.FindInCapsule(colCapsule, EntityPartition.BULLET)) do
        if not famData.IsShattered then 
            ShootSaltyBabyTear(familiar, 3, 6)
            proj:Die()
            famData.CurrentBlocks = famData.CurrentBlocks + 1
            
            sprite:Play("FloatChargedDown", false)

            if famData.CurrentBlocks >= maxBlocks then
                famData.IsShattered = true
                SFXManager():Play(SoundEffect.SOUND_GLASS_BREAK)
                sprite:Play("BrokenDown", true)
            end
        end
    end

    if sprite:GetAnimation() == "FloatChargedDown" then
        if sprite:GetFrame() == 15 then
            sprite:Play("FloatDown", true)
        end
    end

    if famData.IsShattered then
        if familiar.FrameCount % 10 == 0 then
            Isaac.Spawn(EntityType.ENTITY_EFFECT, SaltCreepVar, SaltCreepSubtype, familiar.Position, Vector.Zero, familiar):ToEffect() 
        end
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, SaltyBaby.OnSaltyBabyUpdate, SaltyBabyVariant)

function SaltyBaby:RestoreSaltyBabyState()
    local saltyBabies = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, SaltyBabyVariant)

    for _, saltybaby in ipairs(saltyBabies) do
        local sprite = saltybaby:GetSprite()

        local famData = EdithRestored:GetData(saltybaby)
        famData.IsShattered = false
        famData.CurrentBlocks = 0

        sprite:Play("FloatDown", true)
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, SaltyBaby.RestoreSaltyBabyState)

---@param player EntityPlayer
function SaltyBaby:Cache(player)
    local numFamiliars = player:GetCollectibleNum(EdithRestored.Enums.CollectibleType.COLLECTIBLE_SALTY_BABY) + player:GetEffects():GetCollectibleEffectNum(EdithRestored.Enums.CollectibleType.COLLECTIBLE_SALTY_BABY)
	player:CheckFamiliar(SaltyBabyVariant, numFamiliars, player:GetCollectibleRNG(EdithRestored.Enums.CollectibleType.COLLECTIBLE_SALTY_BABY), saltyBabyDesc)
end
EdithRestored:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, SaltyBaby.Cache, CacheFlag.CACHE_FAMILIARS)

function EdithRestored:OnSaltyBabyTearDeath(tear)
    local tearParent = tear.Parent
    if not tearParent or not tearParent:ToFamiliar() then return end
    if tearParent.Variant ~= EdithRestored.Enums.Familiars.SALTY_BABY.Variant then return end

    local salt = Isaac.Spawn(EntityType.ENTITY_EFFECT, SaltCreepVar, SaltCreepSubtype, tear.Position, Vector.Zero, tear):ToEffect()
    if not salt then return end

    salt:SetTimeout(30)
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, EdithRestored.OnSaltyBabyTearDeath)