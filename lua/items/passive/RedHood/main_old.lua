local RedHoodLocal = {}
local Helpers = include("lua.helpers.Helpers")
local lastRoomIdx = nil
local usedCard = false
local pressedMapButton = 0
local moonPhases = 4

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

local function GiveRedHoodPower(player, num, shoulProc)
    local reset = false
    local data = Helpers.GetEntityData(player)
    if not data.RedHoodCounter then
        data.RedHoodCounter = 0
    end
    data.RedHoodCounter = math.min(moonPhases, data.RedHoodCounter + num)
    reset = data.RedHoodCounter < 0
    data.RedHoodCounter = math.max(0, data.RedHoodCounter)
    print(data.RedHoodCounter)
    local effects = player:GetEffects()
    local numeffects = player:HasCollectible(CollectibleType.COLLECTIBLE_DOG_TOOTH) and 2 or 1
    if shoulProc then
        if data.RedHoodCounter >= moonPhases and not reset then
            if not effects:HasNullEffect(EdithCompliance.Enums.NullItems.RED_HOOD) then
                SFXManager():Play(SoundEffect.SOUND_ISAAC_ROAR, 1, 0, false, 0.7)
            end
            if effects:GetNullEffectNum(EdithCompliance.Enums.NullItems.RED_HOOD) < numeffects then
                effects:AddNullEffect(EdithCompliance.Enums.NullItems.RED_HOOD)
            end
        elseif effects:HasNullEffect(EdithCompliance.Enums.NullItems.RED_HOOD) then
            effects:RemoveNullEffect(EdithCompliance.Enums.NullItems.RED_HOOD, numeffects)
        end
    end
end

local function SetRedHoodPower(player, num, shouldProc)
    local data = Helpers.GetEntityData(player)
    if not data.RedHoodCounter then
        data.RedHoodCounter = 0
    end
    data.RedHoodCounter = math.max(0, num)
    GiveRedHoodPower(player, 0, shouldProc)
end

function RedHoodLocal:StompyEffect(player)
    local effects = player:GetEffects()
    local data = Helpers.GetData(player)
    if player:HasCollectible(EdithCompliance.Enums.CollectibleType.COLLECTIBLE_RED_HOOD) then
        if not data.LunaNullItems then
            data.LunaNullItems = effects:GetNullEffectNum(NullItemID.ID_LUNA)
        end
        if data.LunaNullItems < effects:GetNullEffectNum(NullItemID.ID_LUNA) then
            SetRedHoodPower(player, moonPhases, not Game():GetRoom():IsClear())
        end
        data.LunaNullItems = effects:GetNullEffectNum(NullItemID.ID_LUNA)
    end
    if effects:HasNullEffect(EdithCompliance.Enums.NullItems.RED_HOOD) then
        if not effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_LEO) and effects:HasNullEffect(EdithCompliance.Enums.NullItems.RED_HOOD) then
            effects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_LEO, false)
        end
        local exists = false
        for _, swipe in ipairs(Isaac.FindByType(EdithCompliance.Enums.Entities.WEREWOLF_SWIPE.Type, EdithCompliance.Enums.Entities.WEREWOLF_SWIPE.Variant, 0)) do
            swipe = swipe:ToEffect()
            local parent = swipe.Parent
            if GetPtrHash(parent) == GetPtrHash(player) then
                exists = true
                break
            end
        end
        if not exists then
            local swipe = Isaac.Spawn(EdithCompliance.Enums.Entities.WEREWOLF_SWIPE.Type, EdithCompliance.Enums.Entities.WEREWOLF_SWIPE.Variant, 0, player.Position, Vector.Zero, player):ToEffect()
            swipe:FollowParent(player)
            local sprite = swipe:GetSprite()
            sprite:Play("Swing2", true)
            sprite:SetLastFrame()
        end
    end
end
EdithCompliance:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, RedHoodLocal.StompyEffect, 0)

function RedHoodLocal:SwipesInit(effect)
    local sprite = effect:GetSprite()
    sprite:Play("Swing2", true)
    sprite:SetLastFrame()
end
EdithCompliance:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, RedHoodLocal.SwipesInit, EdithCompliance.Enums.Entities.WEREWOLF_SWIPE.Variant)

function RedHoodLocal:Swipes(effect)
    local player = effect.Parent
    if not player or not player:ToPlayer() then
        effect:Remove()
        return
    end
    player = player:ToPlayer()
    if not player:GetEffects():HasNullEffect(EdithCompliance.Enums.NullItems.RED_HOOD) then
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
EdithCompliance:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, RedHoodLocal.Swipes, EdithCompliance.Enums.Entities.WEREWOLF_SWIPE.Variant)

function RedHoodLocal:NewRoom()
    local level = Game():GetLevel()
    local previousRoomDesc = level:GetRoomByIdx(level:GetPreviousRoomIndex())
    local curentRoomDesc = level:GetCurrentRoomDesc()
    for _, player in ipairs(Helpers.GetPlayersByCollectible(EdithCompliance.Enums.CollectibleType.COLLECTIBLE_RED_HOOD)) do
        if player:GetEffects():HasNullEffect(EdithCompliance.Enums.NullItems.RED_HOOD) then
            previousRoomDesc.Clear = false
        end
        if not usedCard then        
            local dog = player:HasCollectible(CollectibleType.COLLECTIBLE_DOG_TOOTH) and 1 or 0
            if player:GetEffects():GetNullEffectNum(EdithCompliance.Enums.NullItems.RED_HOOD) > dog then
                GiveRedHoodPower(player, -moonPhases, true)
            elseif lastRoomIdx ~= nil and lastRoomIdx ~= level:GetCurrentRoomIndex() 
            and not Game():GetRoom():IsClear() and curentRoomDesc.VisitedCount < 2 and previousRoomDesc.Clear == true then
                GiveRedHoodPower(player, 1, true)
            end
        end
    end
    
    usedCard = false
    lastRoomIdx = level:GetPreviousRoomIndex()
end
EdithCompliance:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, RedHoodLocal.NewRoom)

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
        pressedMapButton = math.min(pressedMapButton + 1, 15)
    else
        pressedMapButton = math.max(0, pressedMapButton - 1)
    end
    if not Helpers.IsMenuing() then
        for _, p in ipairs(Helpers.GetPlayersByCollectible(EdithCompliance.Enums.CollectibleType.COLLECTIBLE_RED_HOOD)) do     
            local pData = Helpers.GetEntityData(p)
            if type(pData.RedHoodCounter) == "number" then
                local pos = Isaac.WorldToScreen(p.Position)
                local data = Helpers.GetData(p)
                local alpha = pressedMapButton / 15
                if not data.MoonPhaseIndicator then
                    data.MoonPhaseIndicator = Sprite()
                    data.MoonPhaseIndicator:Load("gfx/effects/effect_mooneffect.anm2", true)
                end
                data.MoonPhaseIndicator.Color = Color(1, 1, 1, alpha)
                data.MoonPhaseIndicator:Play(moonPhaseAnim[pData.RedHoodCounter + 1])
                data.MoonPhaseIndicator:SetFrame(14)
                data.MoonPhaseIndicator.Offset = Vector(0, -45)
                data.MoonPhaseIndicator:Render(pos)
            end
        end
    end
end

EdithCompliance:AddCallback(ModCallbacks.MC_POST_RENDER, RedHoodLocal.MoonCounter)

function RedHoodLocal:UseCard(card, player, flag)
    if card == Card.CARD_MOON then
        GiveRedHoodPower(player, 1, false)
        usedCard = true
    elseif card == Card.CARD_REVERSE_MOON then
        GiveRedHoodPower(player, -1, true)
        usedCard = true
    end
end
EdithCompliance:AddCallback(ModCallbacks.MC_USE_CARD, RedHoodLocal.UseCard)

---@param player EntityPlayer
---@param cache CacheFlag | integer
function RedHoodLocal:Cache(player, cache)
    local effects = player:GetEffects()
    if effects:HasNullEffect(EdithCompliance.Enums.NullItems.RED_HOOD) then
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
EdithCompliance:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, RedHoodLocal.Cache)