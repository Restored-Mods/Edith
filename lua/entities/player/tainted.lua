local Helpers = EdithRestored.Helpers
local game = Game()
local Tainted = {}
local sfx = SFXManager()

---@param player EntityPlayer
---@return boolean
local function IsTaintedEdith(player)
    return Helpers.IsTaintedEdith(player)
end

---@param player EntityPlayer
local function PlayerCanUseBombs(player)
    return player:GetNumBombs() > 0 or player:HasGoldenBomb()
end

local function IsBombDash(player, data)
    return data.ShouldConsumeBomb and PlayerCanUseBombs(player)
end

local function IsDashing(data)
    return EdithRestored:IsEdithSliding(data) and data.RamState
end 

---@param entity Entity
---@param duration integer
---@param pos? Vector
local function SpawnPepperCreep(entity, duration, pos)
    local pepperCreep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EdithRestored.Enums.Entities.PEPPER_CREEP.Variant, EdithRestored.Enums.Entities.PEPPER_CREEP.SubType, pos or entity.Position, Vector.Zero, entity):ToEffect() ---@cast pepperCreep EntityEffect

    pepperCreep.Color = Color(0, 0, 0)
    pepperCreep:SetTimeout(duration)
end

local function SetDashColor(player, data)
    local red = data.ShouldConsumeBomb and 0.3 or 0
    sfx:Play(SoundEffect.SOUND_STONE_IMPACT, 0.25, 0, false, 2)
    player:SetColor(Color(2, 2, 2, 1, red), 5, 100, true, false)
    data.RamGlowCounter = 0
end 


---@param entity Entity
---@param radius number 
local function SpawnPepperOnGridInRadius(entity, radius)
    local room = game:GetRoom()
    radius = radius or 10
    for i = 0, (room:GetGridSize()) do
		local gridPos = room:GetGridPosition(i)
        if entity.Position:Distance(gridPos) > radius then goto continue end        
        SpawnPepperCreep(entity, 150, gridPos)
		::continue::
    end
end

---@param player EntityPlayer
---@param collider Entity
local function TriggerDashCollision(player, collider)
    if collider.Type == EntityType.ENTITY_STONEY then return end

    local data = EdithRestored:GetData(player)
    local isDashing = IsDashing(data)

    if not isDashing then return end

    local StompDamageMult = data.IsInPepper and 1.5 or 1

    Helpers.Stomp(player, StompDamageMult, true, IsBombDash(player, data), true)

    sfx:Play(SoundEffect.SOUND_MEATY_DEATHS)

    if data.ShouldConsumeBomb and not player:HasGoldenBomb() then        
        player:AddBombs(-1)
    end

    player:SetMinDamageCooldown(30)

    if collider.HitPoints <= data.StompDamage then 
        SpawnPepperOnGridInRadius(collider, (collider.Size + 15) * 1.5)
    else
        data.ExtraIFrames = data.ExtraIFrames or 0
        data.ExtraIFrames = data.ExtraIFrames + 5
        data.RamState = false
        EdithRestored:StopSlide(data)
    end    
end
---@param player EntityPlayer
function Tainted:OnTaintedInit(player)
    if not IsTaintedEdith(player) then return end

    local mySprite = player:GetSprite()
	mySprite:Load(EdithRestored.Enums.PlayerSprites.EDITH_B, true)
	mySprite:Update()

    player:AddSoulHearts(-6)
    player:AddBlackHearts(4)
    player:AddSoulHearts(2)
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Tainted.OnTaintedInit)

---@param player EntityPlayer
function Tainted:OnTaintedUpdate(player)
    if not IsTaintedEdith(player) then return end
    local data = EdithRestored:GetData(player)
    local ctrlIdx = player.ControllerIndex 

    data.TriggerMove = data.TriggerMove or false
    data.SlideCharge = data.SlideCharge or 0
    data.Slidespeed = data.Slidespeed or 0
    data.StaticSlideCharge = data.StaticSlideCharge or 0
    data.MoveGrids = data.MoveGrids or 0
    data.ShouldConsumeBomb = data.ShouldConsumeBomb or false
    data.ExtraIFrames = data.ExtraIFrames or 0

    if Input.IsActionTriggered(ButtonAction.ACTION_DROP, ctrlIdx) then
        data.ShouldConsumeBomb = not data.ShouldConsumeBomb
    end
    
    --- Spawn pepper creep in the tile Edith is moving from
    if data.SlideCounter == 1 then
        SpawnPepperCreep(player, 150)
    elseif not EdithRestored:IsEdithSliding(data) and data.EdithTargetMovementDirection then
        if data.RamState and data.ExtraIFrames > 0 then
            player:SetMinDamageCooldown(30 + data.ExtraIFrames)
        end
        data.ExtraIFrames = 0
        data.IsInPepper = false
        data.RamState = false
        data.RamGlowCounter = 0
    end

    data.RamState = data.RamState or false

    if not data.RamState then
        local ChargeAdd = EdithRestored:IsEdithSliding(data) and 1 or 2       
        data.SlideCharge = Helpers.Clamp(data.SlideCharge + ChargeAdd, 0, 100)
    end

    if IsDashing(data) then
        local capsule = Capsule(player.Position, Vector.One, 0, 20)

        for _, ent in ipairs(Isaac.FindInCapsule(capsule, EntityPartition.ENEMY)) do
            TriggerDashCollision(player, ent)
        end 
        SpawnPepperCreep(player, 150)
    end

    if data.SlideCharge >= 100 and Input.IsActionTriggered(ButtonAction.ACTION_BOMB, ctrlIdx) then
        data.RamState = true
        data.SlideCharge = 0
        SetDashColor(player, data)
    end

    local speed = (data.IsInPepper and 10 or 5) + (data.RamState and 10 or 0)
    local grids = data.RamState and 5 or 1

    EdithRestored:EdithGridMovement(player, data, speed, grids)
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Tainted.OnTaintedUpdate)

function Tainted:ChargeBarRender(player)
	local data = EdithRestored:GetData(player)
	if not IsTaintedEdith(player) then return end

    data.SlideCharge = data.SlideCharge or 0

	data.EdithJumpCharge = data.EdithJumpCharge or 0
	data.ChargeBar = data.ChargeBar or Sprite("gfx/chargebar.anm2", true)
	data.ChargeBar.Offset = Vector(-12 * player.SpriteScale.X, -35 * player.SpriteScale.Y)
	HudHelper.RenderChargeBar(
		data.ChargeBar,
		data.SlideCharge,
		100,
		EdithRestored.Room():WorldToScreenPosition(player.Position)
	)
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, Tainted.ChargeBarRender, 0)

---@param player EntityPlayer
function Tainted:OnPEffectUpdate(player)
    local data = EdithRestored:GetData(player)

    if not IsTaintedEdith(player) then return end
    if not data.RamState then return end
    if EdithRestored:IsEdithSliding(data) then return end

    data.RamGlowCounter = data.RamGlowCounter or 0
    data.RamGlowCounter = math.min(data.RamGlowCounter + 1, 15)

    if data.RamGlowCounter == 15 then
        local red = data.ShouldConsumeBomb and 0.3 or 0
        sfx:Play(SoundEffect.SOUND_STONE_IMPACT, 0.25, 0, false, 2)
        player:SetColor(Color(2, 2, 2, 1, red), 5, 100, true, false)
        data.RamGlowCounter = 0
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Tainted.OnPEffectUpdate)

function Tainted:NegateDashDamage(player)
    local data = EdithRestored:GetData(player)

    if not EdithRestored:IsEdithSliding(data) then return end
    if not data.RamState then return end
    return false
end
EdithRestored:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, Tainted.NegateDashDamage)

---@param effect EntityEffect
EdithRestored:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
    if effect.SubType ~= EdithRestored.Enums.Entities.PEPPER_CREEP.SubType then return end

    for _, ent in ipairs(Isaac.FindInRadius(effect.Position, 20 * effect.SpriteScale.X, EntityPartition.PLAYER)) do
        
        local player = ent:ToPlayer() ---@cast player EntityPlayer
        local data = EdithRestored:GetData(player)
        
        if EdithRestored:IsEdithSliding(data) then goto continue end
        data.IsInPepper = true
        ::continue::
    end
end, EdithRestored.Enums.Entities.PEPPER_CREEP.Variant)

---@param npc EntityNPC
---@param source EntityRef
function Tainted:OnEnemyDeath(npc, source)
    if source.Type == 0 then return end

    local player = TSIL.Players.GetPlayerFromEntity(source.Entity) ---@cast player EntityPlayer?

    if not player then return end
    if not IsTaintedEdith(player) then return end
    local data = EdithRestored:GetData(player)

    if IsDashing(data) then return end
    SpawnPepperOnGridInRadius(npc, npc.Size + 15)
end 
EdithRestored:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, Tainted.OnEnemyDeath)