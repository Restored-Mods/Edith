local Helpers = EdithRestored.Helpers
local mod = EdithRestored

local Tainted = {}

---@param player EntityPlayer
---@return boolean
local function IsTaintedEdith(player)
    return Helpers.IsPlayerEdith(player, false, true)
end

---@param player EntityPlayer
function Tainted:OnTaintedInit(player)
    if not IsTaintedEdith(player) then return end

    local mySprite = player:GetSprite()
	mySprite:Load(EdithRestored.Enums.PlayerSprites.EDITH_B, true)
	mySprite:Update()
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Tainted.OnTaintedInit)

---@param player EntityPlayer
function Tainted:OnTaintedUpdate(player)
    if not IsTaintedEdith(player) then return end
    local data = mod:GetData(player)
    local baseGridMovement = 5 
    local ctrlIdx = player.ControllerIndex 

    data.TriggerMove = data.TriggerMove or false
    data.SlideCharge = data.SlideCharge or 0
    data.Slidespeed = data.Slidespeed or 0
    data.StaticSlideCharge = data.StaticSlideCharge or 0
    data.MoveGrids = data.MoveGrids or 0

    if Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, ctrlIdx) then
        data.MovementInput = ButtonAction.ACTION_LEFT
    elseif Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, ctrlIdx) then
        data.MovementInput = ButtonAction.ACTION_RIGHT
    elseif Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, ctrlIdx) then
        data.MovementInput = ButtonAction.ACTION_UP
    elseif Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, ctrlIdx) then
        data.MovementInput = ButtonAction.ACTION_DOWN
    end
    
    mod:EdithGridMovement(player, data, 3, 1)

    if not mod:IsEdithSliding(data) then
        data.SlideCharge = Helpers.Clamp(data.SlideCharge + 0.5, 0, 100)
    end

    if data.SlideCharge > 0 then
        if data.MovementInput and Input.IsActionTriggered(ButtonAction.ACTION_BOMB, ctrlIdx) then
            data.TriggerMove = true
            data.MoveGrids = math.ceil(baseGridMovement * (data.SlideCharge / 100)) 
            data.Slidespeed = 10 + data.MoveGrids
            data.SlideCharge = 0
        end
    end

    if data.TriggerMove then
        mod:EdithGridMovement(player, data, data.Slidespeed, data.MoveGrids, data.MovementInput)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Tainted.OnTaintedUpdate)

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