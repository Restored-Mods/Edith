local SaltShakerLocal = {}
local Helpers = include("lua.helpers.Helpers")

---@param collectible CollectibleType | integer
---@param rng RNG
---@param player EntityPlayer
---@param flags UseFlag | integer
---@param slot ActiveSlot | integer
---@param customvardata integer
function SaltShakerLocal:UseShaker(collectible, rng, player, flags, slot, customvardata)
    for i = 0, 359, 20 do
		local salt = Isaac.Spawn(1000, EdithCompliance.Enums.Entities.SALT_CREEP.Variant, EdithCompliance.Enums.Entities.SALT_CREEP.SubType, player.Position + Vector.FromAngle(i) * 60, player.Velocity*0, player):ToEffect()
        for j = 1, math.min(2, rng:RandomInt(5)) do
            Isaac.Spawn(1000, EffectVariant.TOOTH_PARTICLE, 0, salt.Position, RandomVector() * rng:RandomFloat() * rng:RandomInt(6), player):ToEffect()
        end
        salt.Timeout = 240
        salt.SortingLayer = SortingLayer.SORTING_BACKGROUND
    end
    return true
end
EdithCompliance:AddCallback(ModCallbacks.MC_USE_ITEM, SaltShakerLocal.UseShaker, EdithCompliance.Enums.CollectibleType.COLLECTIBLE_SALT_SHAKER)

---@param creep EntityEffect
function SaltShakerLocal:CreepUpdate(creep)
    local enemies = Helpers.GetEnemies()
    for _, enemy in ipairs(enemies) do
		if (enemy.Position - creep.Position):Length() <= 20 * creep.Scale and not enemy:HasEntityFlags(EntityFlag.FLAG_FEAR) then
			enemy:AddFear(EntityRef(creep), 30)
		end
    end
    local alpha = creep.Timeout > 40 and 1 or (creep.Timeout / 40)
    local color = creep.Color;
    creep.Color = Color(color.R, color.G, color.B, alpha, color.RO, color.GO, color.BO)
    if creep.Timeout <= 0 then
        creep:Remove()
    end
end
EdithCompliance:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, SaltShakerLocal.CreepUpdate, EdithCompliance.Enums.Entities.SALT_CREEP.Variant)