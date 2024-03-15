local RedHoodLocal = {}
local Helpers = include("lua.helpers.Helpers")
local pressedMapButton = 0
local moonPhases = 8
local phaseTimerMax = 900
local phaseChecker = nil
local moonPhaseSprite = Sprite()
moonPhaseSprite:Load("gfx/effects/effect_mooneffect.anm2", true)
moonPhaseSprite.Color = Color(1, 1, 1, 0)

local moonPhaseAnim = {
    [1] = "NewMoon",
    [2] = "WaxingCrescent",
    [3] = "FirstQuarter",
    [4] = "WaxingGibbous",
    [5] = "FullMoon",
    [6] = "WaningGibbous",
    [7] = "ThirdQuarter",
    [8] = "WaningCrescent",
}

local function GetCurrentMoonPhase()
    return TSIL.SaveManager.GetPersistentVariable(TC_SaltLady, "MoonPhase")
end

local function SetMoonPhase(phase)
    phase = type(phase) == "number" and math.ceil(phase) or GetCurrentMoonPhase()
    TSIL.SaveManager.SetPersistentVariable(TC_SaltLady, "MoonPhase", phase)
end

local function GetPhaseFromTime(time)
    if type(time) ~= "number" then return -1 end
    return math.floor(time / phaseTimerMax)
end

local function GetMoonPhaseFromTime(time)
    local currentPhase = GetPhaseFromTime(time)
    if currentPhase == -1 then return 0 end
    return currentPhase % moonPhases + 1
end

local function AdvanceMoonPhase(step)
    step = type(step) == "number" and step or 0
    local currentPhase = GetCurrentMoonPhase()
    local newPhase = currentPhase + step
    while newPhase < 1 do
        newPhase = newPhase + moonPhases
    end
    while newPhase > moonPhases do
        newPhase = newPhase - moonPhases
    end
    TSIL.SaveManager.SetPersistentVariable(TC_SaltLady, "MoonPhase", newPhase)
    for _, player in pairs(Helpers.GetPlayersByCollectible(TC_SaltLady.Enums.CollectibleType.COLLECTIBLE_RED_HOOD + 1)) do
        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, TC_SaltLady.Enums.Entities.MOON_PHASE.Variant, 0, player.Position, Vector.Zero, player):ToEffect()
        effect.SpriteOffset = Vector(0, -20 * player.SpriteScale.Y)
        effect.DepthOffset = 5
        effect:FollowParent(player)
    end
end

local function CheckClaws(player)
    local exists = false
    for _, swipe in ipairs(Isaac.FindByType(TC_SaltLady.Enums.Entities.WEREWOLF_SWIPE.Type, TC_SaltLady.Enums.Entities.WEREWOLF_SWIPE.Variant, 0)) do
        swipe = swipe:ToEffect()
        local parent = swipe.Parent
        if GetPtrHash(parent) == GetPtrHash(player) then
            exists = true
            break
        end
    end
    if not exists then
        local swipe = Isaac.Spawn(TC_SaltLady.Enums.Entities.WEREWOLF_SWIPE.Type, TC_SaltLady.Enums.Entities.WEREWOLF_SWIPE.Variant, 0, player.Position, Vector.Zero, player):ToEffect()
        swipe:FollowParent(player)
        local sprite = swipe:GetSprite()
        sprite:Play("Swing2", true)
        sprite:SetLastFrame()
    end
end

function RedHoodLocal:TimerInit(isContinue)
    phaseChecker = Game().TimeCounter
    if not isContinue then
        SetMoonPhase(1)
    end
end
TC_SaltLady:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, RedHoodLocal.TimerInit)

function RedHoodLocal:TheTimer()
    if not phaseChecker then phaseChecker = Game().TimeCounter end
    if GetPhaseFromTime(Game().TimeCounter) ~= -1 and GetMoonPhaseFromTime(phaseChecker) ~= GetMoonPhaseFromTime(Game().TimeCounter) then
        local difference = GetPhaseFromTime(phaseChecker) - GetPhaseFromTime(Game().TimeCounter)
        local mul = 1
        if difference > 0 then
            mul = -1
        end
        difference = math.abs(difference)
        AdvanceMoonPhase(difference * mul)
        
        phaseChecker = Game().TimeCounter
    end
end
TC_SaltLady:AddCallback(ModCallbacks.MC_POST_UPDATE, RedHoodLocal.TheTimer)

function RedHoodLocal:MoonPhaseInit(effect)
    local sprite = effect:GetSprite()
    sprite:Play(moonPhaseAnim[GetCurrentMoonPhase()], true)
end
TC_SaltLady:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, RedHoodLocal.MoonPhaseInit, TC_SaltLady.Enums.Entities.MOON_PHASE.Variant)

function RedHoodLocal:MoonPhaseUpdate(effect)
    local player = effect.Parent
    local sprite = effect:GetSprite()
    if not player or not player:ToPlayer() or sprite:IsFinished() then
        effect:Remove()
    end
end
TC_SaltLady:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, RedHoodLocal.MoonPhaseUpdate, TC_SaltLady.Enums.Entities.MOON_PHASE.Variant)

---@param player EntityPlayer
function RedHoodLocal:StompyEffect(player)
    local effects = player:GetEffects()
    local data = Helpers.GetData(player)
    if player:HasCollectible(TC_SaltLady.Enums.CollectibleType.COLLECTIBLE_RED_HOOD + 1) then
        if not data.LunaNullItems then
            data.LunaNullItems = effects:GetNullEffectNum(NullItemID.ID_LUNA)
        end
        if data.LunaNullItems < effects:GetNullEffectNum(NullItemID.ID_LUNA) then
            SetMoonPhase(5)
        end
        data.LunaNullItems = effects:GetNullEffectNum(NullItemID.ID_LUNA)
        if GetCurrentMoonPhase() == 5 then
            if not effects:HasNullEffect(TC_SaltLady.Enums.NullItems.RED_HOOD) then
                SFXManager():Play(SoundEffect.SOUND_ISAAC_ROAR, 1, 0, false, 0.7)
                effects:AddNullEffect(TC_SaltLady.Enums.NullItems.RED_HOOD)
                player:TakeDamage(1, DamageFlag.DAMAGE_NOKILL, EntityRef(player), 30)
            end
        elseif effects:HasNullEffect(TC_SaltLady.Enums.NullItems.RED_HOOD) then
            effects:RemoveNullEffect(TC_SaltLady.Enums.NullItems.RED_HOOD)
        end
    elseif effects:HasNullEffect(TC_SaltLady.Enums.NullItems.RED_HOOD) then
        effects:RemoveNullEffect(TC_SaltLady.Enums.NullItems.RED_HOOD)
    end
    if effects:HasNullEffect(TC_SaltLady.Enums.NullItems.RED_HOOD) then
        if not effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_LEO) and effects:HasNullEffect(TC_SaltLady.Enums.NullItems.RED_HOOD) then
            effects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_LEO, false)
        end
        CheckClaws(player)
    end
end
TC_SaltLady:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, RedHoodLocal.StompyEffect, 0)

function RedHoodLocal:DamageReduction(entity, amount, flags, source, cd)
    if entity then
        local player = entity:ToPlayer()
        local effects = player:GetEffects()
        if effects:HasNullEffect(TC_SaltLady.Enums.NullItems.RED_HOOD) then
            return {Damage = 1.0, DamageFlags = flags, DamageCountdown = cd}
        end
    end
end
TC_SaltLady:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, RedHoodLocal.DamageReduction, EntityType.ENTITY_PLAYER)

function RedHoodLocal:SwipesInit(effect)
    local sprite = effect:GetSprite()
    sprite:Play("Swing2", true)
    sprite:SetLastFrame()
end
TC_SaltLady:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, RedHoodLocal.SwipesInit, TC_SaltLady.Enums.Entities.WEREWOLF_SWIPE.Variant)

function RedHoodLocal:Swipes(effect)
    local player = effect.Parent
    if not player or not player:ToPlayer() or GetCurrentMoonPhase() ~= 5 then
        effect:Remove()
        return
    end
    player = player:ToPlayer()
    if not player:GetEffects():HasNullEffect(TC_SaltLady.Enums.NullItems.RED_HOOD) then
        effect:Remove()
        return
    end
    local sprite = effect:GetSprite()
    local blackList = Helpers.GetData(effect)
    blackList.HitBlacklist = blackList.HitBlacklist or {}
    if sprite:IsFinished("Swing") or sprite:IsFinished("Swing2") then
        local closest
        for _,enemy in pairs(Helpers.Filter(Helpers.GetEnemies(), function(_, enemy) return enemy.Position:Distance(player.Position) <= 60 end)) do
            if not closest or enemy.Position:Distance(player.Position) <= closest.Position:Distance(player.Position) then
                closest = enemy
            end
        end
        if closest then
            blackList.HitBlacklist = {}
            SFXManager():Play(SoundEffect.SOUND_WHIP_HIT, 1, 2, false)
            local anim = "Swing"
            anim = sprite:GetAnimation() == "Swing" and anim.."2" or anim
            sprite:Play(anim, true)
            effect.SpriteRotation = (player.Position - closest.Position):GetAngleDegrees() + 90
            SFXManager():Play(SoundEffect.SOUND_WHIP_HIT, 1, 2, false, 1.2)
        end
    end
    local capsule = effect:GetNullCapsule("tip")
    -- Search for all enemies within the capsule.
    for _, enemy in ipairs(Isaac.FindInCapsule(capsule, EntityPartition.ENEMY)) do
        -- Make sure it can be hurt.
        if enemy:IsVulnerableEnemy()
        and enemy:IsActiveEnemy()
        and not blackList.HitBlacklist[GetPtrHash(enemy)] then
            -- Now hurt it.
            enemy:TakeDamage(player.Damage * 1.5, 0, EntityRef(player), 0)
            -- Add it to the blacklist, so it can't be hurt again.
            blackList.HitBlacklist[GetPtrHash(enemy)] = true

            -- Do some fancy effects, while we're at it.
            enemy:BloodExplode()
            enemy:MakeBloodPoof(enemy.Position, nil, 0.5)
            --SFXManager():Play(SoundEffect.SOUND_DEATH_BURST_LARGE)
            SFXManager():Play(SoundEffect.SOUND_MEATY_DEATHS)
            enemy:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
        end
    end
end
TC_SaltLady:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, RedHoodLocal.Swipes, TC_SaltLady.Enums.Entities.WEREWOLF_SWIPE.Variant)

function RedHoodLocal:MoonCounter()
    if Game():GetRoom():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT then return end
    local pressed = false
    for _,p in ipairs(Helpers.GetPlayers(false)) do
        if Input.IsActionPressed(ButtonAction.ACTION_MAP, p.ControllerIndex) then
            pressed = true
            break
        end
    end
    if pressed then
        pressedMapButton = math.min(15, pressedMapButton + 1)
    else
        pressedMapButton = math.max(0, pressedMapButton - 1)
    end
    if not Helpers.IsMenuing() and not Game():IsPaused() and PlayerManager.AnyoneHasCollectible(TC_SaltLady.Enums.CollectibleType.COLLECTIBLE_RED_HOOD + 1) then
        local pos = Vector(Isaac.GetScreenWidth() / 2 - 60, 20)
        moonPhaseSprite.Color = Color(1, 1, 1, pressedMapButton / 15)
        moonPhaseSprite:Play(moonPhaseAnim[GetCurrentMoonPhase()], true)
        moonPhaseSprite:SetFrame(14)
        moonPhaseSprite:Render(pos)
    end
end

TC_SaltLady:AddCallback(ModCallbacks.MC_POST_RENDER, RedHoodLocal.MoonCounter)

function RedHoodLocal:UseCard(card, player, flag)
    if card == Card.CARD_MOON then
        AdvanceMoonPhase(1)
    elseif card == Card.CARD_REVERSE_MOON then
        AdvanceMoonPhase(-1)
    end
end
TC_SaltLady:AddCallback(ModCallbacks.MC_USE_CARD, RedHoodLocal.UseCard)

---@param player EntityPlayer
---@param cache CacheFlag | integer
function RedHoodLocal:Cache(player, cache)
    local effects = player:GetEffects()
    if effects:HasNullEffect(TC_SaltLady.Enums.NullItems.RED_HOOD) then
        if cache == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage + 5
        elseif cache == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = Helpers.tearsUp(player.MaxFireDelay, 2.5)
        elseif cache == CacheFlag.CACHE_RANGE then
            player.TearRange = Helpers.rangeUp(player.TearRange, 5)
        elseif cache == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = math.max(1, player.MoveSpeed + 0.8)
        end
    end
end
TC_SaltLady:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, RedHoodLocal.Cache)