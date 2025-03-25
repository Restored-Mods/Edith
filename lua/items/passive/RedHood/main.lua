local mod = EdithRestored
local RedHoodLocal = {}
local Helpers = include("lua.helpers.Helpers")
local lastGreedWave = nil
local moonPhaseSprite = Sprite("gfx_redith/ui/moon_phase.anm2", true)
moonPhaseSprite.PlaybackSpeed = 0.5

local RedhoodItem = EdithRestored.Enums.CollectibleType.COLLECTIBLE_RED_HOOD
local RedhoodNull = EdithRestored.Enums.NullItems.RED_HOOD
local MoonIndType = EdithRestored.Enums.Entities.MOON_INDICATOR.Type
local MoonIndVariant = EdithRestored.Enums.Entities.MOON_INDICATOR.Variant
local MoonIndSubType = EdithRestored.Enums.Entities.MOON_INDICATOR.SubType

local plyrMan = PlayerManager

local game = Game()
local level = game:GetLevel()

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

local function IsRedMoonPhase()
    return TSIL.SaveManager.GetPersistentVariable(EdithRestored, "MoonPhaseWolf") == true
    or level:GetCurses() & LevelCurse.CURSE_OF_DARKNESS > 0
end

---@param bool boolean
local function SetRedMoonPhase(bool)
    if not IsRedMoonPhase() and bool then
        SFXManager():Play(SoundEffect.SOUND_ISAAC_ROAR, 1, 0, false, 0.7)
    end
    TSIL.SaveManager.SetPersistentVariable(EdithRestored, "MoonPhaseWolf", bool)
end

local function GetMoonSpritesheetPath()
    local MoonColor = IsRedMoonPhase() and "_red" or "_blue"
    return "gfx_redith/ui/moon_phase"..MoonColor..".png"
end

local function SetRedMoonPhaseSprites(moon)
    local moonSprite = moon:GetSprite()

    for i = 0, 1 do
        moonSprite:ReplaceSpritesheet(i, GetMoonSpritesheetPath(), true)
    end
end

---@return integer
local function GetCurrentMoonPhase()
    return TSIL.SaveManager.GetPersistentVariable(EdithRestored, "MoonPhase")
end

local moonPhaseCount = {
    [1] = 0,
    [2] = 1,
    [3] = 2,
    [4] = 3,
    [5] = 4,
    [6] = 3,
    [7] = 2,
    [8] = 1
}

---@param player EntityPlayer
local function SpawnMoonPhaseView(player)
    local playerData = Helpers.GetData(player)

    playerData.MoonPhaseView = Isaac.Spawn(
       EntityType.ENTITY_EFFECT,
        MoonIndVariant,
        MoonIndSubType,
        player.Position + Vector(0, -75),
        Vector.Zero,
        player
    ):ToEffect()

    playerData.MoonPhaseView:FollowParent(player)
    playerData.MoonPhaseView:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
    playerData.MoonPhaseView.DepthOffset = 10
end

local function PlayNewMoonPhase(moon, Animation)
    local moonSprite = moon:GetSprite()
    
    SetRedMoonPhaseSprites(moon)
    print("sapodjopasjdpojasd")
    -- local color = moon.Color
    -- color.A = 1
    -- moon.Color = color
    moonSprite:Play(Animation, true)
end

---@param player EntityPlayer
local function UpdatePlayerMoonPhase(player)
    local currentMoonPhase = GetCurrentMoonPhase()
	local effects = player:GetEffects()
	effects:RemoveNullEffect(RedhoodNull, -1)
	
    if not player:HasCollectible(RedhoodItem) then return end
	effects:AddNullEffect(RedhoodNull, false, moonPhaseCount[currentMoonPhase])
end

---@param phase integer
local function SetMoonPhase(phase)
    phase = type(phase) == "number" and math.ceil(phase) or Helpers.GetCurrentMoonPhase()
	phase = math.max(1, math.min(phase, 8))
    TSIL.SaveManager.SetPersistentVariable(EdithRestored, "MoonPhase", phase)
    
	for _, player in ipairs(PlayerManager.GetPlayers()) do
		UpdatePlayerMoonPhase(player)
        local playerData = Helpers.GetData(player)
        local moon = playerData.MoonPhaseView

        print(moon.Type, moon.Variant, moon.SubType)

        -- if not playerData.MoonPhaseView then SpawnMoonPhaseView(player) end
        
        SetRedMoonPhase(GetCurrentMoonPhase() == 5)
        PlayNewMoonPhase(moon, moonPhaseAnim[GetCurrentMoonPhase()])
	end
end

---@param step integer
local function AdvanceMoonPhase(step)
	local moonPhase = GetCurrentMoonPhase()
	if step ~= 0 then
        moonPhase = ((moonPhase - 1) + step) % 8 + 1
		step = Helpers.Sign(step) * (math.abs(step) - 1)
	end
    SetMoonPhase(moonPhase)
end

---@param effect EntityEffect
---@param offset Vector
function RedHoodLocal:OnMoonPhaseRender(effect, offset)
    local moonSprite = effect:GetSprite()
    local CurrentPhaseAnim = moonPhaseAnim[GetCurrentMoonPhase()]
    local IsCurrentAnimFinished = moonSprite:IsFinished(CurrentPhaseAnim)
    
    local player = effect.SpawnerEntity:ToPlayer()
    
    if not player then return end
    if not IsCurrentAnimFinished then return end

    local color = effect.Color
    color.A = 0
    effect.Color = color

    moonSprite:SetFrame(CurrentPhaseAnim, 15)

    if not Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex) then return end
    color.A = 1
    effect.Color = color
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, RedHoodLocal.OnMoonPhaseRender, MoonIndVariant)

---comment
-- ---@param effect EntityEffect
-- function RedHoodLocal:OnMoonPhaseUPDATE(effect)
--     print(effect)
-- end
-- mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, RedHoodLocal.OnMoonPhaseUPDATE, MoonIndVariant)

function RedHoodLocal:OnGettingRedHood(_, _, _, _, _, player)
    SpawnMoonPhaseView(player)
end
mod:AddCallback(ModCallbacks.MC_PRE_ADD_COLLECTIBLE, RedHoodLocal.OnGettingRedHood, RedhoodItem) 

---@param rng RNG
function RedHoodLocal:AdvanceMoonPhase(rng)
    if not PlayerManager.AnyoneHasCollectible(RedhoodItem) then return end
    local keepLunaEffect = false
    if PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_LUNA) then
        keepLunaEffect = rng:RandomFloat() < 0.5
    end
    local check = GetCurrentMoonPhase()
    AdvanceMoonPhase(1)

    if GetCurrentMoonPhase() > 5 then
        if check < 5 then
            Helpers.SetMoonPhase(5)
        elseif not keepLunaEffect and IsRedMoonPhase() then
            SetRedMoonPhase(false)
        end
    end
end
EdithRestored:AddPriorityCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, CallbackPriority.EARLY, RedHoodLocal.AdvanceMoonPhase)

---@param player EntityPlayer
local function CheckClaws(player)
    local exists = false
    for _, swipe in ipairs(Isaac.FindByType(EdithRestored.Enums.Entities.WEREWOLF_SWIPE.Type, EdithRestored.Enums.Entities.WEREWOLF_SWIPE.Variant, 0)) do
        swipe = swipe:ToEffect()
        local parent = swipe.Parent
        if GetPtrHash(parent) == GetPtrHash(player) then
            exists = true
            break
        end
    end
    if not exists then
        for i = 1, 2 do
            local swipe = Isaac.Spawn(EdithRestored.Enums.Entities.WEREWOLF_SWIPE.Type, EdithRestored.Enums.Entities.WEREWOLF_SWIPE.Variant, 0, player.Position, Vector.Zero, player):ToEffect()
            swipe:FollowParent(player)
            local sprite = swipe:GetSprite()
            sprite:Play("Swing2", true)
            sprite:SetLastFrame()
        end
        
    end
end

-- ---@param isContinue boolean
-- function RedHoodLocal:MoonPhaseInit(isContinue)
--     if not isContinue then
--         Helpers.SetMoonPhase(1)
--         SetRedMoonPhase(false)
--     end
--     SetRedMoonPhaseSprites()
-- end
-- EdithRestored:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.LATE, RedHoodLocal.MoonPhaseInit)

---@param player EntityPlayer
function RedHoodLocal:StompyEffect(player)
    local effects = player:GetEffects()
    local data = Helpers.GetData(player)
    if player:HasCollectible(RedhoodItem) then
        if not data.LunaNullItems then
            data.LunaNullItems = effects:GetNullEffectNum(NullItemID.ID_LUNA)
        end
        if data.LunaNullItems < effects:GetNullEffectNum(NullItemID.ID_LUNA) then
            preRedMoonAnim = Helpers.GetCurrentMoonPhase() + 1
            animatePhase = 1
            Helpers.SetMoonPhase(5)
        end
        data.LunaNullItems = effects:GetNullEffectNum(NullItemID.ID_LUNA)
    elseif effects:HasNullEffect(EdithRestored.Enums.NullItems.RED_HOOD) then
        effects:RemoveNullEffect(EdithRestored.Enums.NullItems.RED_HOOD, -1)
    end
    if effects:HasNullEffect(EdithRestored.Enums.NullItems.RED_HOOD) and IsRedMoonPhase() then
        if not effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_LEO) and effects:HasNullEffect(EdithRestored.Enums.NullItems.RED_HOOD) then
            effects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_LEO, false)
        end
        CheckClaws(player)
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, RedHoodLocal.StompyEffect, 0)

function RedHoodLocal:DamageReduction(entity, amount, flags, source, cd)
    local player = entity:ToPlayer()
    if not player then return end
    local effects = player:GetEffects()
    if not (effects:GetNullEffectNum(EdithRestored.Enums.NullItems.RED_HOOD) > 0 and IsRedMoonPhase()) then return end

    return {Damage = 1, DamageFlags = flags, DamageCountdown = cd}
end
EdithRestored:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, RedHoodLocal.DamageReduction, EntityType.ENTITY_PLAYER)

function RedHoodLocal:SwipesInit(effect)
    local sprite = effect:GetSprite()
    sprite:Play("Swing2", true)
    sprite:SetLastFrame()
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, RedHoodLocal.SwipesInit, EdithRestored.Enums.Entities.WEREWOLF_SWIPE.Variant)

function RedHoodLocal:Swipes(effect)
    local player = effect.Parent
    if not player or not player:ToPlayer() or not IsRedMoonPhase() then
        effect:Remove()
        return
    end
    player = player:ToPlayer()
    if not player:GetEffects():HasNullEffect(EdithRestored.Enums.NullItems.RED_HOOD) then
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
EdithRestored:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, RedHoodLocal.Swipes, EdithRestored.Enums.Entities.WEREWOLF_SWIPE.Variant)

local advancer = {
    [Card.CARD_MOON] = 1,
    [Card.CARD_REVERSE_MOON] = -1
}

function RedHoodLocal:UseCard(card, player, flag)
    if not plyrMan.AnyoneHasCollectible(RedhoodItem) then return end
    local Advancer = advancer[card]
    if not Advancer then return end

    AdvanceMoonPhase(Advancer)
end
EdithRestored:AddCallback(ModCallbacks.MC_USE_CARD, RedHoodLocal.UseCard)

-- -- kittenchilly's Mama Mega Greed Mode Buff code
function EdithRestored:WaveReset()
	if Game():IsGreedMode() then
		lastGreedWave = 0
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, EdithRestored.WaveReset)

function EdithRestored:OnNewGreedWave()
	if game:IsGreedMode() then

		local greedModeWave = level.GreedModeWave
		
		if not lastGreedWave then
			lastGreedWave = greedModeWave
		end
		
		if greedModeWave > lastGreedWave then
			lastGreedWave = greedModeWave
            local room = game:GetRoom()
            local plate = nil
            if room:GetRoomShape() == RoomShape.ROOMSHAPE_1x2 and level:GetAbsoluteStage() < LevelStage.STAGE7_GREED then
                plate = room:GetGridEntity(112):ToPressurePlate()
            end
			local rng = plate and plate.GreedModeRNG or RNG()
			RedHoodLocal:AdvanceMoonPhase(rng)
		end
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_UPDATE, EdithRestored.OnNewGreedWave)

---@param player EntityPlayer
---@param cache CacheFlag | integer
function RedHoodLocal:Cache(player, cache)
    local effects = player:GetEffects()
    local del = IsRedMoonPhase() and 4 or 8
    local mul = effects:GetNullEffectNum(EdithRestored.Enums.NullItems.RED_HOOD) / del
    if cache == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage + 5 * mul
    elseif cache == CacheFlag.CACHE_FIREDELAY then
        player.MaxFireDelay = Helpers.tearsUp(player.MaxFireDelay, 2.5 * mul)
    elseif cache == CacheFlag.CACHE_RANGE then
        player.TearRange = Helpers.rangeUp(player.TearRange, 5 * mul)
    elseif cache == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = math.max(1, player.MoveSpeed + 0.8 * mul)
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, RedHoodLocal.Cache)