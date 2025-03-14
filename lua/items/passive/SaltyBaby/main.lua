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
local function ShootSaltyBabyTear(familiar)
    local player = familiar.Player
    local rng = player:GetCollectibleRNG(SaltyBabyVariant)
    local baseMultiplier = -30 / baseRange
    local halfBaseHeight = baseHeight * 0.9
    local tearCount = rng:RandomInt(6, 12)

    for _ = 1, tearCount do
        local tear = familiar:FireProjectile(RandomVector())
        tear.FallingAcceleration = rng:RandomInt(150, 200) / 100

        local fallSpeedVar = rng:RandomInt(80, 120) / 100
        tear.FallingSpeed = baseMultiplier * fallSpeedVar
        tear.Height = halfBaseHeight * (rng:RandomInt(20, 120) / 100)
        tear.Scale = 1

        ChangeToEdithTear(tear)
    end
end		

---@param familiar EntityFamiliar
function SaltyBaby:OnSaltyBabyUpdate(familiar)
    familiar:FollowParent()
    familiar:AddToFollowers()

    local data = Helpers.GetData(familiar)
    local player = familiar.Player
    
    data.SaltyBabyCharge = data.SaltyBabyCharge or 0
    local shoot = {
        l = Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex),
        r = Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex),
        u = Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex),
        d = Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex)
    }

    local isShooting = (shoot.l or shoot.r or shoot.u or shoot.d)

    if isShooting == true then
        data.SaltyBabyCharge = math.min(1, data.SaltyBabyCharge + 0.025)
    else
        if data.SaltyBabyCharge >= 1 then
            ShootSaltyBabyTear(familiar)
        end
        data.SaltyBabyCharge = 0
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, SaltyBaby.OnSaltyBabyUpdate, SaltyBabyVariant)

---@param player EntityPlayer
function SaltyBaby:Cache(player)
    local numFamiliars = player:GetCollectibleNum(SaltyBabyVariant) + player:GetEffects():GetCollectibleEffectNum(SaltyBabyVariant)
	player:CheckFamiliar(SaltyBabyVariant, numFamiliars, player:GetCollectibleRNG(SaltyBabyVariant), saltyBabyDesc)
end
EdithRestored:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, SaltyBaby.Cache, CacheFlag.CACHE_FAMILIARS)

function SaltyBaby:RenderSaltyChargebar(familiar)
    local data = Helpers.GetData(familiar)

    if not data.Chargebar then
		data.Chargebar = Sprite("gfx/chargebar.anm2", true)
	end
	local Chargebar = data.Chargebar    

    local RenderPos = Isaac.WorldToScreen(familiar.Position) + Vector(10 * familiar.SpriteScale.X, -30 * familiar.SpriteScale.Y)    
    HudHelper.RenderChargeBar(Chargebar, data.SaltyBabyCharge, 1, RenderPos)
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, SaltyBaby.RenderSaltyChargebar, EdithRestored.Enums.Familiars.SALTY_BABY.Variant)

function EdithRestored:OnSaltyBabyTearDeath(tear)
    local tearParent = tear.Parent
    if not tearParent and not tearParent:ToFamiliar() then return end
    if tearParent.Variant ~= EdithRestored.Enums.Familiars.SALTY_BABY.Variant then return end

    local salt = Isaac.Spawn(EntityType.ENTITY_EFFECT, SaltCreepVar, SaltCreepSubtype, tear.Position, Vector.Zero, tear):ToEffect()
    if not salt then return end

    salt:SetTimeout(150)
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, EdithRestored.OnSaltyBabyTearDeath)