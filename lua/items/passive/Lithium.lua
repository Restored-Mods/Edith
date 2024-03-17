local Lithium = {}
local Helpers = include("lua.helpers.Helpers")

Lithium.DAMAGE_DECREASE_AMOUNT = -0.20
Lithium.TEARS_DECREASE_AMOUNT = -0.12
Lithium.IFRAME_INCREASE_AMOUNT = 20

local DAMAGE_DECREASE_AMOUNT = Lithium.DAMAGE_DECREASE_AMOUNT
local TEARS_DECREASE_AMOUNT = Lithium.TEARS_DECREASE_AMOUNT
local IFRAME_INCREASE_AMOUNT = Lithium.IFRAME_INCREASE_AMOUNT

---@param pillEffect PillEffect | integer
---@param player EntityPlayer
---@param flags UseFlag | integer
---@param pillColor PillColor
function Lithium:OnPillUse(pillEffect, player, flags, pillColor)
    if player:HasCollectible(EdithCompliance.Enums.CollectibleType.COLLECTIBLE_LITHIUM) then
        local data = Helpers.GetEntityData(player)
        data.LithiumUses = data.LithiumUses + 1
        if pillColor & PillColor.PILL_GIANT_FLAG > 0 then
            data.LithiumUses = data.LithiumUses + 1
        end
    end
end
EdithCompliance:AddCallback(ModCallbacks.MC_USE_PILL, Lithium.OnPillUse)

---@param player EntityPlayer
---@param cache CacheFlag
function Lithium:LithiumCache(player, cache)
    if player:HasCollectible(EdithCompliance.Enums.CollectibleType.COLLECTIBLE_LITHIUM) and not player:HasCurseMistEffect() then
        local data = Helpers.GetEntityData(player)
        local lithiumUses = data.LithiumUses
        if cache == CacheFlag.CACHE_FIREDELAY then
            local tearDiff = math.max(lithiumUses * TEARS_DECREASE_AMOUNT, -(Helpers.ToTearsPerSecond(player.MaxFireDelay) - 0.01))
            player.MaxFireDelay = Helpers.tearsUp(player.MaxFireDelay, tearDiff)
        elseif cache == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage + DAMAGE_DECREASE_AMOUNT * lithiumUses
        end
    end
end
EdithCompliance:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Lithium.LithiumCache)

---@param player EntityPlayer
function Lithium:LithiumIframe(player)
    if player:HasCollectible(EdithCompliance.Enums.CollectibleType.COLLECTIBLE_LITHIUM) then
        local data = Helpers.GetEntityData(player)
        if data.LithiumUses and (not Helpers.GetData(player).LithiumUses or (Helpers.GetData(player).Lithium ~= data.LithiumUses
        and not player:HasCurseMistEffect()))
        or EdithCompliance(player).Lithium > 0 and player:HasCurseMistEffect() then
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            player:EvaluateItems()
            Helpers.GetData(player).LithiumUses = player:HasCurseMistEffect() and 0 or data.LithiumUses
        end
    end
end
EdithCompliance:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Lithium.LithiumIframe)

function Lithium:AddPill(collectible, charge, firstTime, slot, VarData, player)
    if firstTime and collectible == EdithCompliance.Enums.CollectibleType.COLLECTIBLE_LITHIUM then
        local room = Game():GetRoom()
        local spawningPos = room:FindFreePickupSpawnPosition(player.Position, 1, true)
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, 0, spawningPos, Vector.Zero, player):ToPickup()
    end
end
EdithCompliance:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, Lithium.AddPill)

function Lithium:AfterDamage(entity, damage, flags, source, cd)
    if entity and entity:ToPlayer() then
        local player = entity:ToPlayer()
        if player:HasCollectible(EdithCompliance.Enums.CollectibleType.COLLECTIBLE_LITHIUM) then
            local data = Helpers.GetEntityData(player)
            local newDamageCD = cd + IFRAME_INCREASE_AMOUNT * (data.LithiumUses or 0)
            player:ResetDamageCooldown()
            player:SetMinDamageCooldown(newDamageCD)
        end
    end
end
EdithCompliance:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, Lithium.AfterDamage, EntityType.ENTITY_PLAYER)