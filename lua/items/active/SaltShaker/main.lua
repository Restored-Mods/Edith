local SaltShakerLocal = {}
local Helpers = include("lua.helpers.Helpers")

local SaltCreepVar = EdithRestored.Enums.Entities.SALT_CREEP.Variant
local SaltCreepSubtype = EdithRestored.Enums.Entities.SALT_CREEP.SubType

local SaltQuantity = 16
local spawnDegree = 360 / SaltQuantity

local sfx = SFXManager()

---@param rng RNG
---@param player EntityPlayer
---@param flags UseFlag | integer
function SaltShakerLocal:UseShaker(_, rng, player, flags)
    local CarBatteryUse = (flags == flags | UseFlag.USE_CARBATTERY)	
    if CarBatteryUse then return end

    local hasCarBattery = player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)
    local SaltTimeOut = hasCarBattery and 480 or 240
    local ExistintSalt = Isaac.FindByType(EntityType.ENTITY_EFFECT, SaltCreepVar, SaltCreepSubtype)

    for _, ExistSalt in ipairs(ExistintSalt) do
        ExistSalt:ToEffect():SetTimeout(1)
    end

    for i = 1, SaltQuantity do
        local salt = Isaac.Spawn(EntityType.ENTITY_EFFECT, SaltCreepVar, SaltCreepSubtype, player.Position + Vector.FromAngle(spawnDegree * i) * 60, Vector.Zero, player):ToEffect()

        if not salt then return end

        for _ = 1, math.min(2, rng:RandomInt(5)) do
            Isaac.Spawn(1000, EffectVariant.TOOTH_PARTICLE, 0, salt.Position, RandomVector() * rng:RandomFloat() * rng:RandomInt(6), player):ToEffect()
        end

        salt:SetTimeout(SaltTimeOut)
    end

    local SoundPitch = rng:RandomInt(900, 1100) / 1000
    sfx:Play(EdithRestored.Enums.SFX.SaltShaker.SHAKE, 1, 0, false, SoundPitch)

    return {Discharge = true, Remove = false, ShowAnim = true}
end
EdithRestored:AddCallback(ModCallbacks.MC_USE_ITEM, SaltShakerLocal.UseShaker, EdithRestored.Enums.CollectibleType.COLLECTIBLE_SALT_SHAKER)

local rng = RNG()

function SaltShakerLocal:SaltInit(creep)
    local sprite = creep:GetSprite()
    local randomNum = tostring(rng:RandomInt(6) + 1)
    sprite:Play("SmallBlood0" .. randomNum, true)  
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, SaltShakerLocal.SaltInit, SaltCreepVar)

---@param creep EntityEffect
function SaltShakerLocal:CreepUpdate(creep)
    if creep.SubType ~= SaltCreepSubtype then return end
    local enemies = Helpers.GetEnemies()

    for _, enemy in ipairs(enemies) do
        local distance = enemy.Position - creep.Position
        local threshold = 20 * creep.Scale
        if not (distance:Length() <= threshold and not enemy:HasEntityFlags(EntityFlag.FLAG_FEAR)) then return end
           
        enemy:AddFear(EntityRef(creep), 30)
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, SaltShakerLocal.CreepUpdate, SaltCreepVar)