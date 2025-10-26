local Helpers = EdithRestored.Helpers
local sfx = SFXManager()
local mod = EdithRestored

local Tainted = {}

---@param player EntityPlayer
---@return boolean
local function IsTaintedEdith(player)
    return Helpers.IsPlayerEdith(player, false, true)
end

---@param player EntityPlayer
---@return boolean
local function IsMovementButtonPressed(player)
    local idx = player.ControllerIndex
    return (
        Input.IsActionPressed(ButtonAction.ACTION_LEFT, idx) or
        Input.IsActionPressed(ButtonAction.ACTION_UP, idx) or
        Input.IsActionPressed(ButtonAction.ACTION_DOWN, idx) or
        Input.IsActionPressed(ButtonAction.ACTION_RIGHT, idx)
    )
end

function Tainted:OnTaintedInit(player)
    if not IsTaintedEdith(player) then return end

    local mySprite = player:GetSprite()
    mySprite:Load(EdithRestored.Enums.PlayerSprites.EDITH, true)
    mySprite:LoadGraphics()
    Helpers.ChangeSprite(player, true)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Tainted.OnTaintedInit)

---@param player EntityPlayer
function Tainted:OnTaintedUpdate(player)
    if not IsTaintedEdith(player) then return end
    local data = mod:GetData(player)
    local baseGridMovement = 5 
    local ctrlIdx = player.ControllerIndex 

    local movedGRids 
    local MovementSpeed 

    local mySprite = player:GetSprite()
    mySprite:Load(EdithRestored.Enums.PlayerSprites.EDITH, true)
    mySprite:LoadGraphics()
    Helpers.ChangeSprite(player, true)

    data.TriggerMove = data.TriggerMove or false
    data.SlideCharge = data.SlideCharge or 0

    if Input.IsActionPressed(ButtonAction.ACTION_LEFT, ctrlIdx) then
        data.MovementInput = ButtonAction.ACTION_LEFT
    elseif Input.IsActionPressed(ButtonAction.ACTION_RIGHT, ctrlIdx) then
        data.MovementInput = ButtonAction.ACTION_RIGHT
    elseif Input.IsActionPressed(ButtonAction.ACTION_UP, ctrlIdx) then
        data.MovementInput = ButtonAction.ACTION_UP
    elseif Input.IsActionPressed(ButtonAction.ACTION_DOWN, ctrlIdx) then
        data.MovementInput = ButtonAction.ACTION_DOWN
    end
    
    if IsMovementButtonPressed(player) then
        data.SlideCharge = Helpers.Clamp(data.SlideCharge + 2, 0, 100)
    else
        if data.SlideCharge > 0 then
            -- data.StopMove = false
            data.StaticSlideCharge = data.SlideCharge
            data.SlideCharge = 0

            if data.StaticSlideCharge > 2 then
                data.TriggerMove = true
                movedGRids = Helpers.Round(baseGridMovement * (data.StaticSlideCharge / 100), 0)
            else
                movedGRids = 1
            end

            MovementSpeed = movedGRids > 1 and (3 + movedGRids) or 3
        end
    end

    movedGRids = Helpers.Round(baseGridMovement * (data.StaticSlideCharge / 100), 0)
    MovementSpeed = movedGRids > 1 and (3 + movedGRids) or 3

    print(movedGRids)
    
    
    if data.TriggerMove == true then
    --     print("apsdojapsjdopjpo"
        mod:EdithGridMovement(player, data, MovementSpeed, movedGRids, data.MovementInput)
        -- data.StopMove = true
        -- data.MovementInput = nil
    end
    -- data.TriggerMove = false
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