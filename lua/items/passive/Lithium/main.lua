local Lithium = {}
local Helpers = include("lua.helpers.Helpers")

Lithium.DAMAGE_DECREASE_AMOUNT = -0.20
Lithium.TEARS_DECREASE_AMOUNT = -0.12
Lithium.IFRAME_INCREASE_AMOUNT = 20
Lithium.IFRAME_INCREASE_FALSEPHD_AMOUNT = 5

local DAMAGE_DECREASE_AMOUNT = Lithium.DAMAGE_DECREASE_AMOUNT
local TEARS_DECREASE_AMOUNT = Lithium.TEARS_DECREASE_AMOUNT
local IFRAME_INCREASE_AMOUNT = Lithium.IFRAME_INCREASE_AMOUNT
local IFRAME_INCREASE_FALSEPHD_AMOUNT = Lithium.IFRAME_INCREASE_FALSEPHD_AMOUNT

---@param pillEffect PillEffect | integer
---@param player EntityPlayer
---@param flags UseFlag | integer
---@param pillColor PillColor
function Lithium:OnPillUse(pillEffect, player, flags, pillColor)
    if pillColor == (EdithRestored.Enums.Pickups.Pills.PILL_LITHIUM)
    or pillColor == (EdithRestored.Enums.Pickups.Pills.PILL_HORSE_LITHIUM) then
        local uses = pillColor & PillColor.PILL_GIANT_FLAG > 0 and 2 or 1
        local effects = player:GetEffects()
        effects:AddNullEffect(EdithRestored.Enums.NullItems.LITHIUM_POSITIVE, true, uses)
        if player:HasCollectible(CollectibleType.COLLECTIBLE_PHD) and not player:HasCollectible(CollectibleType.COLLECTIBLE_FALSE_PHD) then
            player:AnimateHappy()
        else
            player:AnimateSad()
            effects:AddNullEffect(EdithRestored.Enums.NullItems.LITHIUM_NEGATIVE, true, uses)
        end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_FALSE_PHD) then
            effects:AddNullEffect(EdithRestored.Enums.NullItems.LITHIUM_FALSEPHD, true, uses)
        end
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_USE_PILL, Lithium.OnPillUse)

function Lithium:GetEffect(pillEffect, pillColor)
    if pillColor == EdithRestored.Enums.Pickups.Pills.PILL_LITHIUM then
        return EdithRestored.Enums.Pickups.PillEffects.PILLEFFECT_LITHIUM
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_GET_PILL_EFFECT, Lithium.GetEffect)

function Lithium:ReplacePill(pickup)
    if pickup:GetDropRNG():RandomFloat() <= 0.1 and PlayerManager.AnyoneHasCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_LITHIUM) then
        local pill = pickup.SubType & PillColor.PILL_GIANT_FLAG > 0 and EdithRestored.Enums.Pickups.Pills.PILL_HORSE_LITHIUM or EdithRestored.Enums.Pickups.Pills.PILL_LITHIUM
        pickup:Morph(pickup.Type, pickup.Variant, pill, true, true)
    end
end
EdithRestored:AddCallback(TSIL.Enums.CustomCallback.POST_PICKUP_INIT_FIRST, Lithium.ReplacePill, PickupVariant.PICKUP_PILL)

---@param player EntityPlayer
---@param cache CacheFlag
function Lithium:LithiumCache(player, cache)
    
    local effects = player:GetEffects()
    local lithiumUses = effects:GetNullEffectNum(EdithRestored.Enums.NullItems.LITHIUM_NEGATIVE)
    local lithiumFalsePHD = effects:GetNullEffectNum(EdithRestored.Enums.NullItems.LITHIUM_FALSEPHD)
    if cache == CacheFlag.CACHE_FIREDELAY then
        local tearDiff = math.max(lithiumUses * TEARS_DECREASE_AMOUNT - lithiumFalsePHD * 0.01, - (Helpers.ToTearsPerSecond(player.MaxFireDelay) - 0.01))
        player.MaxFireDelay = Helpers.tearsUp(player.MaxFireDelay, tearDiff)
    elseif cache == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage + DAMAGE_DECREASE_AMOUNT * lithiumUses - lithiumFalsePHD * 0.05
    end
    
end
EdithRestored:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Lithium.LithiumCache)

function Lithium:AddPill(collectible, charge, firstTime, slot, VarData, player)
    if firstTime and collectible == EdithRestored.Enums.CollectibleType.COLLECTIBLE_LITHIUM then
        local room = Game():GetRoom()
        local spawningPos = room:FindFreePickupSpawnPosition(player.Position, 1, true)
        local pill = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, EdithRestored.Enums.Pickups.Pills.PILL_LITHIUM, spawningPos, Vector.Zero, player):ToPickup()
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, Lithium.AddPill)

function Lithium:AfterDamage(entity, damage, flags, source, cd)
    if entity and entity:ToPlayer() then
        local player = entity:ToPlayer()
        local newDamageCD = cd + IFRAME_INCREASE_AMOUNT * player:GetEffects():GetNullEffectNum(EdithRestored.Enums.NullItems.LITHIUM_POSITIVE)
        + player:GetEffects():GetNullEffectNum(EdithRestored.Enums.NullItems.LITHIUM_FALSEPHD) * IFRAME_INCREASE_FALSEPHD_AMOUNT
        player:ResetDamageCooldown()
        player:SetMinDamageCooldown(newDamageCD)
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, Lithium.AfterDamage, EntityType.ENTITY_PLAYER)