local RedHoodLocal = {}
local Helpers = include("lua.helpers.Helpers")
local pressedMapButton = 0
local lastGreedWave = nil
local moonPhaseSprite = Sprite()
moonPhaseSprite:Load("gfx_cedith/ui/moon_phase.anm2", true)
moonPhaseSprite.PlaybackSpeed = 0.5

local animatePhase = 0
local preRedMoonAnim = 0

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

local function GetRedMoonPhase()
    return TSIL.SaveManager.GetPersistentVariable(EdithCompliance, "MoonPhaseWolf") == true
end

local function SetRedMoonPhase(bool)
    TSIL.SaveManager.SetPersistentVariable(EdithCompliance, "MoonPhaseWolf", bool)
end

local function GetSpritesheet()
    local postfix = "_blue"
    if GetRedMoonPhase() == true then
        postfix = "_red"
    end
    return "gfx_cedith/ui/moon_phase"..postfix..".png"
end

local function SetRedMoonPhaseSprites()
    for i = 0, 1 do
        moonPhaseSprite:ReplaceSpritesheet(i, GetSpritesheet(), true)
    end
end

local function PlayMoonPhase(animate)
    local phase = Helpers.GetCurrentMoonPhase()
    if animate then
        if preRedMoonAnim > 0 then
            phase = preRedMoonAnim
        end
        if moonPhaseSprite:GetAnimation() ~= moonPhaseAnim[phase] then
            moonPhaseSprite:Play(moonPhaseAnim[phase], true)
        elseif moonPhaseSprite:IsFinished() then
            pressedMapButton = 0
            animatePhase = 0
            preRedMoonAnim = 0
        end
        moonPhaseSprite:Update()
        if moonPhaseSprite:GetFrame() == 10 and moonPhaseSprite:GetLayer(0):GetSpritesheetPath() ~= GetSpritesheet() then
            SetRedMoonPhaseSprites()
            if preRedMoonAnim > 0 then
                local frame = moonPhaseSprite:GetFrame()
                moonPhaseSprite:Play(moonPhaseAnim[Helpers.GetCurrentMoonPhase()], true)
                moonPhaseSprite:SetFrame(frame)
                preRedMoonAnim = 0
            end
        end
    else
        moonPhaseSprite:Play(moonPhaseAnim[phase], true)
        moonPhaseSprite:SetFrame(14)
        preRedMoonAnim = 0
    end
    if moonPhaseSprite:GetFrame() >= 14 and moonPhaseSprite:GetLayer(0):GetSpritesheetPath() ~= GetSpritesheet() then
        SetRedMoonPhaseSprites()
    end
    
end

---@param player EntityPlayer
local function CheckClaws(player)
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

---@param isContinue boolean
function RedHoodLocal:MoonPhaseInit(isContinue)
    if not isContinue then
        Helpers.SetMoonPhase(1)
        SetRedMoonPhase(false)
    end
    animatePhase = 0
    SetRedMoonPhaseSprites(isContinue and GetRedMoonPhase())
end
EdithCompliance:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.LATE, RedHoodLocal.MoonPhaseInit)

---@param player EntityPlayer
function RedHoodLocal:StompyEffect(player)
    local effects = player:GetEffects()
    local data = Helpers.GetData(player)
    if player:HasCollectible(EdithCompliance.Enums.CollectibleType.COLLECTIBLE_RED_HOOD) then
        if not data.LunaNullItems then
            data.LunaNullItems = effects:GetNullEffectNum(NullItemID.ID_LUNA)
        end
        if data.LunaNullItems < effects:GetNullEffectNum(NullItemID.ID_LUNA) then
            preRedMoonAnim = Helpers.GetCurrentMoonPhase() + 1
            animatePhase = 1
            Helpers.SetMoonPhase(5)
        end
        data.LunaNullItems = effects:GetNullEffectNum(NullItemID.ID_LUNA)
        if GetRedMoonPhase() then
            if not effects:HasNullEffect(EdithCompliance.Enums.NullItems.RED_HOOD) then
                effects:AddNullEffect(EdithCompliance.Enums.NullItems.RED_HOOD)
                SFXManager():Play(SoundEffect.SOUND_ISAAC_ROAR, 1, 0, false, 0.7)
            end
        elseif effects:HasNullEffect(EdithCompliance.Enums.NullItems.RED_HOOD) then
            effects:RemoveNullEffect(EdithCompliance.Enums.NullItems.RED_HOOD)
        end
    elseif effects:HasNullEffect(EdithCompliance.Enums.NullItems.RED_HOOD) then
        effects:RemoveNullEffect(EdithCompliance.Enums.NullItems.RED_HOOD)
    end
    if effects:HasNullEffect(EdithCompliance.Enums.NullItems.RED_HOOD) then
        if not effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_LEO) and effects:HasNullEffect(EdithCompliance.Enums.NullItems.RED_HOOD) then
            effects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_LEO, false)
        end
        CheckClaws(player)
    end
end
EdithCompliance:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, RedHoodLocal.StompyEffect, 0)

function RedHoodLocal:RedMoon()
    if not PlayerManager.AnyoneHasCollectible(EdithCompliance.Enums.CollectibleType.COLLECTIBLE_RED_HOOD) then 
        return
    end
    if Helpers.GetCurrentMoonPhase() == 5 then
        if not GetRedMoonPhase() then
            SetRedMoonPhase(true)
        end
    else
        if Helpers.GetCurrentMoonPhase() < 5 and GetRedMoonPhase() then
            SetRedMoonPhase(false)
        end
    end
end
EdithCompliance:AddCallback(ModCallbacks.MC_POST_UPDATE, RedHoodLocal.RedMoon)

function RedHoodLocal:DamageReduction(entity, amount, flags, source, cd)
    if entity then
        local player = entity:ToPlayer()
        local effects = player:GetEffects()
        if effects:HasNullEffect(EdithCompliance.Enums.NullItems.RED_HOOD) then
            return {Damage = 1.0, DamageFlags = flags, DamageCountdown = cd}
        end
    end
end
EdithCompliance:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, RedHoodLocal.DamageReduction, EntityType.ENTITY_PLAYER)

function RedHoodLocal:SwipesInit(effect)
    local sprite = effect:GetSprite()
    sprite:Play("Swing2", true)
    sprite:SetLastFrame()
end
EdithCompliance:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, RedHoodLocal.SwipesInit, EdithCompliance.Enums.Entities.WEREWOLF_SWIPE.Variant)

function RedHoodLocal:Swipes(effect)
    local player = effect.Parent
    if not player or not player:ToPlayer() or Helpers.GetCurrentMoonPhase() ~= 5 then
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

function RedHoodLocal:MoonCounter()
    if not PlayerManager.AnyoneHasCollectible(EdithCompliance.Enums.CollectibleType.COLLECTIBLE_RED_HOOD) then return end
    local pressed = false
    
    if TSIL.SaveManager.GetPersistentVariable(EdithCompliance, "AlwaysShowMoonPhase") == 1 then
        pressedMapButton = 15
    else
        for _,p in ipairs(Helpers.GetPlayers(false)) do
            if Input.IsActionPressed(ButtonAction.ACTION_MAP, p.ControllerIndex) then
                pressed = true
                break
            end
        end
        
        if not Game():IsPauseMenuOpen() then
            if pressed then
                pressedMapButton = math.min(15, pressedMapButton + 1)
            elseif not Game():IsPaused() then
                pressedMapButton = math.max(0, pressedMapButton - 1)
            end
        end
    end

    if (not Helpers.IsMenuing() or animatePhase == 1) then
        local pos = Vector(Isaac.GetScreenWidth() / 2 - 60, 20)
        moonPhaseSprite.Color = Color(1, 1, 1, math.max(pressedMapButton / 15, animatePhase))
        PlayMoonPhase(animatePhase == 1)
        moonPhaseSprite:Render(pos)
    end
end

EdithCompliance:AddCallback(ModCallbacks.MC_HUD_RENDER, RedHoodLocal.MoonCounter)

function RedHoodLocal:UseCard(card, player, flag)
    if PlayerManager.AnyoneHasCollectible(EdithCompliance.Enums.CollectibleType.COLLECTIBLE_RED_HOOD) then
        if card == Card.CARD_MOON then
            Helpers.AdvanceMoonPhase(1)
        elseif card == Card.CARD_REVERSE_MOON then
            Helpers.AdvanceMoonPhase(-1)
        end
    end
end
EdithCompliance:AddCallback(ModCallbacks.MC_USE_CARD, RedHoodLocal.UseCard)

---@param rng RNG
function RedHoodLocal:AdvanceMoonPhase(rng)
    if not PlayerManager.AnyoneHasCollectible(EdithCompliance.Enums.CollectibleType.COLLECTIBLE_RED_HOOD) then return end
    local keepLunaEffect = false
    if PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_LUNA) then
        keepLunaEffect = rng:RandomFloat() < 0.5
    end
    animatePhase = 1
    local check = Helpers.GetCurrentMoonPhase()
    Helpers.AdvanceMoonPhase(1)
    if Helpers.GetCurrentMoonPhase() > 5 then
        if check < 5 then
            Helpers.SetMoonPhase(5)
        elseif not keepLunaEffect and GetRedMoonPhase() then
            SetRedMoonPhase(false)
        end
    end
end
EdithCompliance:AddPriorityCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, CallbackPriority.EARLY, RedHoodLocal.AdvanceMoonPhase)

-- kittenchilly's Mama Mega Greed Mode Buff code
function EdithCompliance:WaveReset()
	if Game():IsGreedMode() then
		lastGreedWave = 0
	end
end
EdithCompliance:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, EdithCompliance.WaveReset)

function EdithCompliance:OnNewGreedWave()
	local level = Game():GetLevel()
	
	if Game():IsGreedMode() then

		local greedModeWave = level.GreedModeWave
		
		if not lastGreedWave then
			lastGreedWave = greedModeWave
		end
		
		if greedModeWave > lastGreedWave then
			lastGreedWave = greedModeWave
            local room = Game():GetRoom()
            local plate = nil
            if room:GetRoomShape() == RoomShape.ROOMSHAPE_1x2 and level:GetAbsoluteStage() < LevelStage.STAGE7_GREED then
                plate = room:GetGridEntity(112):ToPressurePlate()
            end
			local rng = plate and plate.GreedModeRNG or RNG()
			RedHoodLocal:AdvanceMoonPhase(rng)
		end
	end
end
EdithCompliance:AddCallback(ModCallbacks.MC_POST_UPDATE, EdithCompliance.OnNewGreedWave)

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