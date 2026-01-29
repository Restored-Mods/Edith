local Helpers = EdithRestored.Helpers
local game = Game()
local Tainted = {}

---@param player EntityPlayer
---@return boolean
local function IsTaintedEdith(player)
    return Helpers.IsTaintedEdith(player)
end

---@param player EntityPlayer
function Tainted:OnTaintedInit(player)
    if not IsTaintedEdith(player) then return end

    local mySprite = player:GetSprite()
	mySprite:Load(EdithRestored.Enums.PlayerSprites.EDITH_B, true)
	mySprite:Update()
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Tainted.OnTaintedInit)

---@param player EntityPlayer
function Tainted:OnTaintedUpdate(player)
    if not IsTaintedEdith(player) then return end
    local data = EdithRestored:GetData(player)
    local baseGridMovement = 5 
    local ctrlIdx = player.ControllerIndex 

    data.TriggerMove = data.TriggerMove or false
    data.SlideCharge = data.SlideCharge or 0
    data.Slidespeed = data.Slidespeed or 0
    data.StaticSlideCharge = data.StaticSlideCharge or 0
    data.MoveGrids = data.MoveGrids or 0

    local input = {
        left = Input.GetActionValue(ButtonAction.ACTION_SHOOTLEFT, ctrlIdx),
        right = Input.GetActionValue(ButtonAction.ACTION_SHOOTRIGHT, ctrlIdx),
        up = Input.GetActionValue(ButtonAction.ACTION_SHOOTUP, ctrlIdx),
        down = Input.GetActionValue(ButtonAction.ACTION_SHOOTDOWN, ctrlIdx)
    }

    local VecX = ((input.left > 0.3 and -input.left) or (input.right > 0.3 and input.right) or 0) * (game:GetRoom():IsMirrorWorld() and -1 or 1) 
    local VecY = ((input.up > 0.3 and -input.up) or (input.down > 0.3 and input.down) or 0)

    local MoveVex = Vector(VecX, VecY):Normalized()

    if Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, ctrlIdx) then
        data.MovementInput = ButtonAction.ACTION_LEFT
    elseif Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, ctrlIdx) then
        data.MovementInput = ButtonAction.ACTION_RIGHT
    elseif Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, ctrlIdx) then
        data.MovementInput = ButtonAction.ACTION_UP
    elseif Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, ctrlIdx) then
        data.MovementInput = ButtonAction.ACTION_DOWN
    end

    data.ShouldConsumeBomb = data.ShouldConsumeBomb or false

    if Input.IsActionTriggered(ButtonAction.ACTION_DROP, ctrlIdx) then
        data.ShouldConsumeBomb = not data.ShouldConsumeBomb
    end
    
    --- Spawn pepper creep in the tile Edith is moving from
    if data.SlideCounter == 1 then
        local pepperCreep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EdithRestored.Enums.Entities.PEPPER_CREEP.Variant, EdithRestored.Enums.Entities.PEPPER_CREEP.SubType, player.Position, Vector.Zero, player):ToEffect() ---@cast pepperCreep EntityEffect

        pepperCreep.Color = Color(0, 0, 0)
        pepperCreep:SetTimeout(150)
    elseif not EdithRestored:IsEdithSliding(data) and data.EdithTargetMovementDirection then
        data.IsInPepper = false
        data.RamState = false
    end

    data.RamState = data.RamState or false

    if not EdithRestored:IsEdithSliding(data) and not data.RamState then
        data.SlideCharge = Helpers.Clamp(data.SlideCharge + 0.5, 0, 100)
    end

    if data.SlideCharge >= 100 and Input.IsActionTriggered(ButtonAction.ACTION_BOMB, ctrlIdx) then
        data.RamState = true
        data.SlideCharge = 0
    end

    local speed = (data.IsInPepper and 6 or 3) + (data.RamState and 10 or 0)
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