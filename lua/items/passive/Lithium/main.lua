local Lithium = {}
local Helpers = include("lua.helpers.Helpers")

Lithium.IFRAME_INCREASE_AMOUNT = 20
Lithium.IFRAME_INCREASE_FALSEPHD_AMOUNT = 5

local IFRAME_INCREASE_AMOUNT = Lithium.IFRAME_INCREASE_AMOUNT
local IFRAME_INCREASE_FALSEPHD_AMOUNT = Lithium.IFRAME_INCREASE_FALSEPHD_AMOUNT

local LithiumPill = EdithRestored.Enums.Pickups.Pills.PILL_LITHIUM
local LithiumHorsePill = EdithRestored.Enums.Pickups.Pills.PILL_HORSE_LITHIUM

local LithiumID = EdithRestored.Enums.CollectibleType.COLLECTIBLE_LITHIUM

local StatsDownPills = {
    PillEffect.PILLEFFECT_LUCK_DOWN,
    PillEffect.PILLEFFECT_SHOT_SPEED_DOWN,
    PillEffect.PILLEFFECT_RANGE_DOWN,
    PillEffect.PILLEFFECT_SPEED_DOWN,
    PillEffect.PILLEFFECT_TEARS_DOWN,
}

local RNG = RNG()

function Lithium:InitRNG(isContinue)
    RNG:SetSeed(Game():GetSeeds():GetStartSeed(), 35)
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Lithium.InitRNG)

---@param pillEffect PillEffect | integer
---@param player EntityPlayer
---@param flags UseFlag | integer
---@param pillColor PillColor
function Lithium:OnPillUse(pillEffect, player, flags, pillColor)
    if not (pillColor == (LithiumPill) or pillColor == (LithiumHorsePill)) then return end
    local uses = pillColor & PillColor.PILL_GIANT_FLAG > 0 and 2 or 1    
    local effects = player:GetEffects()

    effects:AddNullEffect(EdithRestored.Enums.NullItems.LITHIUM_POSITIVE, true, uses)

    if player:HasCollectible(CollectibleType.COLLECTIBLE_FALSE_PHD) then
        player:AddBlackHearts(2)
        effects:AddNullEffect(EdithRestored.Enums.NullItems.LITHIUM_FALSEPHD, true, uses)
    end

    if player:HasCollectible(CollectibleType.COLLECTIBLE_PHD) then
        player:AnimateHappy()
        return
    end

    local randomNum = RNG:RandomInt(1, #StatsDownPills)
    player:UsePill(StatsDownPills[randomNum], PillColor.PILL_NULL, UseFlag.USE_NOANNOUNCER | UseFlag.USE_NOHUD)
end
EdithRestored:AddCallback(ModCallbacks.MC_USE_PILL, Lithium.OnPillUse)

function Lithium:GetEffect(pillEffect, pillColor)
    if pillColor == EdithRestored.Enums.Pickups.Pills.PILL_LITHIUM then
        return EdithRestored.Enums.Pickups.PillEffects.PILLEFFECT_LITHIUM
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_GET_PILL_EFFECT, Lithium.GetEffect)

---@param pickup EntityPickup
function Lithium:ReplacePill(pickup)
    if pickup.SubType == EdithRestored.Enums.Pickups.Pills.PILL_LITHIUM
    or pickup.SubType == EdithRestored.Enums.Pickups.Pills.PILL_HORSE_LITHIUM
    or not PlayerManager.AnyoneHasCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_LITHIUM)
    or pickup:GetDropRNG():RandomFloat() > 0.1 then return end

    local pill = pickup.SubType & PillColor.PILL_GIANT_FLAG ~= 0 and EdithRestored.Enums.Pickups.Pills.PILL_HORSE_LITHIUM or EdithRestored.Enums.Pickups.Pills.PILL_LITHIUM

    pickup:Morph(pickup.Type, pickup.Variant, pill, true, true)
end
EdithRestored:AddCallback(TSIL.Enums.CustomCallback.POST_PICKUP_INIT_FIRST, Lithium.ReplacePill, PickupVariant.PICKUP_PILL)

function Lithium:AddPill(_, _, firstTime, _, _, player)
    if not firstTime then return end

    TSIL.EntitySpecific.SpawnPickup(
        PickupVariant.PICKUP_PILL,
        EdithRestored.Enums.Pickups.Pills.PILL_LITHIUM,
        Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 1, true),
        Vector.Zero,
        player
    )
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, Lithium.AddPill, EdithRestored.Enums.CollectibleType.COLLECTIBLE_LITHIUM)

---@param entity Entity
function Lithium:AfterDamage(entity)
    local player = entity and entity:ToPlayer()
    if not player then return end

    local pos = player:GetEffects():GetNullEffectNum(EdithRestored.Enums.NullItems.LITHIUM_POSITIVE)
    local neg = player:GetEffects():GetNullEffectNum(EdithRestored.Enums.NullItems.LITHIUM_FALSEPHD)
    if pos + neg == 0 then return end

    local cd = player:GetDamageCooldown()

    player:ResetDamageCooldown()
    player:SetMinDamageCooldown(cd + pos * IFRAME_INCREASE_AMOUNT + neg * IFRAME_INCREASE_FALSEPHD_AMOUNT)
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, Lithium.AfterDamage, EntityType.ENTITY_PLAYER)