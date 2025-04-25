local mod = EdithRestored
local RedHoodLocal = {}
local Helpers = include("lua.helpers.Helpers")
local lastGreedWave = nil
local moonPhaseSprite = Sprite("gfx_redith/moon_phase.anm2", true)
local moonPhaseSpriteStatic = Sprite("gfx_redith/moon_phase.anm2", true)
moonPhaseSpriteStatic:SetFrame(15)
local moonPhaseAlpha = moonPhaseSpriteStatic.Color
moonPhaseAlpha.A = 0

local RedhoodItem = EdithRestored.Enums.CollectibleType.COLLECTIBLE_RED_HOOD
local RedhoodNull = EdithRestored.Enums.NullItems.RED_HOOD

local game = Game()
local level = game:GetLevel()

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

local function LunaRng(rng)
    local keepLunaEffect = false
	if PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_LUNA) then
		keepLunaEffect = rng:RandomFloat() < 0.35
	end
    return keepLunaEffect
end

---@return integer
local function GetCurrentMoonPhase()
	return EdithRestored:RunSave()["MoonPhase"]
end

local function IsRedMoonPhase()
	return EdithRestored:RunSave()["MoonPhaseWolf"] == true or level:GetCurses() & LevelCurse.CURSE_OF_DARKNESS > 0
end

---@param bool boolean
local function SetRedMoonPhase(bool)
	if not IsRedMoonPhase() and bool then
		SFXManager():Play(SoundEffect.SOUND_ISAAC_ROAR, 1, 0, false, 0.7)
	end
	EdithRestored:RunSave()["MoonPhaseWolf"] = bool
end

local function GetMoonSpritesheetPath()
	local MoonColor = IsRedMoonPhase() and "_red" or "_blue"
	return "gfx_redith/effects/moon_phase" .. MoonColor .. ".png"
end

local function SetRedMoonPhaseSprites()
	for i = 0, 1 do
		moonPhaseSprite:ReplaceSpritesheet(i, GetMoonSpritesheetPath(), true)
		moonPhaseSpriteStatic:ReplaceSpritesheet(i, GetMoonSpritesheetPath(), true)
	end
end

local moonPhaseCount = {
	[1] = 0,
	[2] = 1,
	[3] = 2,
	[4] = 3,
	[5] = 4,
	[6] = 3,
	[7] = 2,
	[8] = 1,
}

local function PlayNewMoonPhase(Animation)
	SetRedMoonPhaseSprites()
	moonPhaseSprite:Play(Animation, true)
	moonPhaseSpriteStatic:SetFrame(Animation, 15)
    print(Animation)
end

---@param player EntityPlayer
local function UpdatePlayerMoonPhase(player)
	local currentMoonPhase = GetCurrentMoonPhase()
	local effects = player:GetEffects()
	effects:RemoveNullEffect(RedhoodNull, -1)

	if not player:HasCollectible(RedhoodItem) then
		return
	end
	effects:AddNullEffect(RedhoodNull, false, moonPhaseCount[currentMoonPhase])
end

---@param phase integer
---@param keep boolean
---@param reverse boolean
local function SetMoonPhase(phase, keep, reverse)
    local currentMoonPhase = GetCurrentMoonPhase()
	phase = type(phase) == "number" and math.ceil(phase) or currentMoonPhase
	phase = math.max(1, math.min(phase, 8))
	EdithRestored:RunSave()["MoonPhase"] = phase
	for _, player in ipairs(PlayerManager.GetPlayers()) do
		UpdatePlayerMoonPhase(player)
		-- if not playerData.MoonPhaseView then SpawnMoonPhaseView(player) end
	end
	SetRedMoonPhase(phase == 5 or keep)
    local anim = moonPhaseAnim[phase]
    if reverse then
        anim = anim.."Reverse"
    end
	PlayNewMoonPhase(anim)
end

---@param step integer
---@param keep boolean
local function AdvanceMoonPhase(step, keep)
	local moonPhase = GetCurrentMoonPhase()
    local reverse = step < 0
	if step ~= 0 then
		moonPhase = ((moonPhase - 1) + step) % 8 + 1
		step = Helpers.Sign(step) * (math.abs(step) - 1)
	end
	SetMoonPhase(moonPhase, keep, reverse)
end

EdithRestored.AdvanceMoon = AdvanceMoonPhase

local actionPressed = false

function RedHoodLocal:OnMoonPhaseRender()
	local CurrentPhaseAnim = moonPhaseAnim[GetCurrentMoonPhase()]
	local IsCurrentAnimFinished = moonPhaseSprite:IsFinished(CurrentPhaseAnim) or moonPhaseSprite:IsFinished(CurrentPhaseAnim.."Reverse")

	for _, player in
		pairs(Helpers.Filter(PlayerManager.GetPlayers(), function(index, player)
			return not player.Parent and player:HasCollectible(RedhoodItem)
		end))
	do
		moonPhaseSprite:Render(Isaac.WorldToScreen(player.Position + Vector(0, -70 * player.SpriteScale.Y)))
		if IsCurrentAnimFinished then
			moonPhaseSpriteStatic:Render(Isaac.WorldToScreen(player.Position + Vector(0, -70 * player.SpriteScale.Y)))
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, RedHoodLocal.OnMoonPhaseRender)

function RedHoodLocal:UpdateMoonAnim()
	moonPhaseSprite:Update()
	if not PlayerManager.AnyoneHasCollectible(RedhoodItem) then
		return
	end
	local IsCurrentAnimFinished = moonPhaseSprite:IsFinished(moonPhaseAnim[GetCurrentMoonPhase()]) or moonPhaseSprite:IsFinished(moonPhaseAnim[GetCurrentMoonPhase()].."Reverse")
	actionPressed = false
	for _, player in pairs(PlayerManager.GetPlayers()) do
		if Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex) then
			actionPressed = true
			break
		end
	end
	local lerpTo = -0.1
	if actionPressed and IsCurrentAnimFinished then
		lerpTo = 0.1
	end
	moonPhaseAlpha.A = Helpers.Clamp(moonPhaseAlpha.A + lerpTo, 0, 1)
	moonPhaseSpriteStatic.Color = moonPhaseAlpha
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, RedHoodLocal.UpdateMoonAnim)

---@param rng RNG
function RedHoodLocal:AdvanceMoonPhase(rng)
	if not PlayerManager.AnyoneHasCollectible(RedhoodItem) then
		return
	end
	AdvanceMoonPhase(1, LunaRng(rng) and IsRedMoonPhase())
end
EdithRestored:AddPriorityCallback(
	ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
	CallbackPriority.EARLY,
	RedHoodLocal.AdvanceMoonPhase
)

---@param player EntityPlayer
local function CheckClaws(player)
	local exists = false
	for _, swipe in
		ipairs(
			Isaac.FindByType(
				EdithRestored.Enums.Entities.WEREWOLF_SWIPE.Type,
				EdithRestored.Enums.Entities.WEREWOLF_SWIPE.Variant,
				0
			)
		)
	do
		swipe = swipe:ToEffect()
		local parent = swipe.Parent
		if GetPtrHash(parent) == GetPtrHash(player) then
			exists = true
			break
		end
	end
	if not exists then
		for i = 1, 2 do
			local swipe = Isaac.Spawn(
				EdithRestored.Enums.Entities.WEREWOLF_SWIPE.Type,
				EdithRestored.Enums.Entities.WEREWOLF_SWIPE.Variant,
				0,
				player.Position,
				Vector.Zero,
				player
			):ToEffect()
			swipe:FollowParent(player)
			local sprite = swipe:GetSprite()
			sprite:Play("Swing2", true)
			sprite:SetLastFrame()
		end
	end
end

-- ---@param isContinue boolean
function RedHoodLocal:MoonPhaseInit(isContinue)
	if not isContinue then
		SetMoonPhase(1)
		SetRedMoonPhase(false)
	end
	SetRedMoonPhaseSprites()
end
EdithRestored:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.LATE, RedHoodLocal.MoonPhaseInit)

---@param player EntityPlayer
function RedHoodLocal:StompyEffect(player)
	local effects = player:GetEffects()
	local data = Helpers.GetData(player)
	if player:HasCollectible(RedhoodItem) then
		if not data.LunaNullItems then
			data.LunaNullItems = effects:GetNullEffectNum(NullItemID.ID_LUNA)
		end
		if data.LunaNullItems < effects:GetNullEffectNum(NullItemID.ID_LUNA) then
			SetMoonPhase(5)
		end
		data.LunaNullItems = effects:GetNullEffectNum(NullItemID.ID_LUNA)
	elseif effects:HasNullEffect(EdithRestored.Enums.NullItems.RED_HOOD) then
		effects:RemoveNullEffect(EdithRestored.Enums.NullItems.RED_HOOD, -1)
	end
	if effects:HasNullEffect(EdithRestored.Enums.NullItems.RED_HOOD) and IsRedMoonPhase() then
		if not player:CanCrushRocks() then
			effects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_LEO, false)
			data.RedHoodCrushRocks = true
		end
		CheckClaws(player)
	elseif player:CanCrushRocks() and data.RedHoodCrushRocks then
		effects:RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_LEO)
		data.RedHoodCrushRocks = nil
	end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, RedHoodLocal.StompyEffect, 0)

function RedHoodLocal:DamageReduction(entity, amount, flags, source, cd)
	local player = entity:ToPlayer()
	if not player then
		return
	end
	local effects = player:GetEffects()
	if not (effects:GetNullEffectNum(EdithRestored.Enums.NullItems.RED_HOOD) > 0 and IsRedMoonPhase()) then
		return
	end

	return { Damage = 1, DamageFlags = flags, DamageCountdown = cd }
end
EdithRestored:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, RedHoodLocal.DamageReduction, EntityType.ENTITY_PLAYER)

function RedHoodLocal:SwipesInit(effect)
	local sprite = effect:GetSprite()
	sprite:Play("Swing2", true)
	sprite:SetLastFrame()
end
EdithRestored:AddCallback(
	ModCallbacks.MC_POST_EFFECT_INIT,
	RedHoodLocal.SwipesInit,
	EdithRestored.Enums.Entities.WEREWOLF_SWIPE.Variant
)

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
		for _, enemy in
			pairs(Helpers.Filter(Helpers.GetEnemies(), function(_, enemy)
				return enemy.Position:Distance(player.Position) <= 60
			end))
		do
			if
				not closest
				or enemy.Position:Distance(player.Position) <= closest.Position:Distance(player.Position)
			then
				closest = enemy
			end
		end
		if closest then
			blackList.HitBlacklist = {}
			SFXManager():Play(SoundEffect.SOUND_WHIP_HIT, 1, 2, false)
			local anim = "Swing"
			anim = sprite:GetAnimation() == "Swing" and anim .. "2" or anim
			sprite:Play(anim, true)
			effect.SpriteRotation = (player.Position - closest.Position):GetAngleDegrees() + 90
			SFXManager():Play(SoundEffect.SOUND_WHIP_HIT, 1, 2, false, 1.2)
		end
	end
	local capsule = effect:GetNullCapsule("tip")
	-- Search for all enemies within the capsule.
	for _, enemy in ipairs(Isaac.FindInCapsule(capsule, EntityPartition.ENEMY)) do
		-- Make sure it can be hurt.
		if enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy() and not blackList.HitBlacklist[GetPtrHash(enemy)] then
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
EdithRestored:AddCallback(
	ModCallbacks.MC_POST_EFFECT_UPDATE,
	RedHoodLocal.Swipes,
	EdithRestored.Enums.Entities.WEREWOLF_SWIPE.Variant
)

local advancer = {
	[Card.CARD_MOON] = 1,
	[Card.CARD_REVERSE_MOON] = -1,
}

---@param card any
---@param player EntityPlayer
---@param flag any
function RedHoodLocal:UseCard(card, player, flag)
	if not PlayerManager.AnyoneHasCollectible(RedhoodItem) then
		return
	end
	local Advancer = advancer[card]
	if not Advancer then
		return
	end

	AdvanceMoonPhase(Advancer, IsRedMoonPhase())
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
			if
				room:GetRoomShape() == RoomShape.ROOMSHAPE_1x2
				and level:GetAbsoluteStage() < LevelStage.STAGE7_GREED
			then
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
