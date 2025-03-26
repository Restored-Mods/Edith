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

local SaltCreepVar = EdithRestored.Enums.Entities.SALT_CREEP.Variant
local SaltCreepSubtype = EdithRestored.Enums.Entities.SALT_CREEP.SubType
local SaltyBabyVariant = EdithRestored.Enums.Familiars.SALTY_BABY.Variant

---@param familiar EntityFamiliar
local function ShootSaltyBabyTear(familiar, hasBFFS)
    local player = familiar.Player
    local rng = player:GetCollectibleRNG(EdithRestored.Enums.CollectibleType.COLLECTIBLE_SALTY_BABY)
    local baseMultiplier = -70 / baseRange
    local halfBaseHeight = baseHeight * 1.1
    local tearCount = rng:RandomInt(6, 12)

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
    familiar.FireCooldown = 0
    familiar:AddToFollowers()
end
EdithRestored:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, SaltyBaby.OnSaltyBabyInit, SaltyBabyVariant)

---@param familiar EntityFamiliar
function SaltyBaby:OnSaltyBabyUpdate(familiar)
    familiar:FollowParent()
    local player = familiar.Player
    
    local lulabyMult = player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) and 2 or 1

    local shoot = {
        l = Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex),
        r = Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex),
        u = Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex),
        d = Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex)
    }

    local isShooting = (shoot.l or shoot.r or shoot.u or shoot.d)

    if isShooting == true then
        familiar.FireCooldown = math.min(1000, familiar.FireCooldown + 25 * lulabyMult)
    else
        if familiar.FireCooldown / 1000 >= 1 then
            ShootSaltyBabyTear(familiar, player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS))
        end
        familiar.FireCooldown = 0
    end
    local sprite = familiar:GetSprite()
    local anim = familiar.FireCooldown / 1000 >= 1 and "FloatChargedDown" or "FloatDown"
    if not sprite:IsPlaying(anim) then
        sprite:Play(anim, false)
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, SaltyBaby.OnSaltyBabyUpdate, SaltyBabyVariant)

---@param player EntityPlayer
function SaltyBaby:Cache(player)
    local numFamiliars = player:GetCollectibleNum(EdithRestored.Enums.CollectibleType.COLLECTIBLE_SALTY_BABY) + player:GetEffects():GetCollectibleEffectNum(EdithRestored.Enums.CollectibleType.COLLECTIBLE_SALTY_BABY)
	player:CheckFamiliar(SaltyBabyVariant, numFamiliars, player:GetCollectibleRNG(EdithRestored.Enums.CollectibleType.COLLECTIBLE_SALTY_BABY), saltyBabyDesc)
end
EdithRestored:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, SaltyBaby.Cache, CacheFlag.CACHE_FAMILIARS)

function SaltyBaby:RenderSaltyChargebar(familiar)
    local data = Helpers.GetData(familiar)

    if not data.Chargebar then
		data.Chargebar = Sprite("gfx/chargebar.anm2", true)
	end
	local Chargebar = data.Chargebar
    Chargebar.Offset = Vector(10 * familiar.SpriteScale.X, -30 * familiar.SpriteScale.Y)
    local RenderPos = Isaac.WorldToScreen(familiar.Position)
    HudHelper.RenderChargeBar(Chargebar, familiar.FireCooldown / 1000, 1, RenderPos)
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, SaltyBaby.RenderSaltyChargebar, EdithRestored.Enums.Familiars.SALTY_BABY.Variant)

function EdithRestored:OnSaltyBabyTearDeath(tear)
    local tearParent = tear.Parent
    if not tearParent or not tearParent:ToFamiliar() then return end
    if tearParent.Variant ~= EdithRestored.Enums.Familiars.SALTY_BABY.Variant then return end

    local salt = Isaac.Spawn(EntityType.ENTITY_EFFECT, SaltCreepVar, SaltCreepSubtype, tear.Position, Vector.Zero, tear):ToEffect()
    if not salt then return end

    salt:SetTimeout(30)
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, EdithRestored.OnSaltyBabyTearDeath)