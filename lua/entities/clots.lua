local EdithClots = {}
local Helpers = require("lua.helpers.Helpers")

---@param clot EntityFamiliar
function EdithClots:Movement(clot)
    local player = clot.Parent or clot.SpawnerEntity
    if not player or not player:ToPlayer() or Helpers.IsMenuing() then return end
    player = player:ToPlayer()
    if not Helpers.IsPlayerEdith(player, true, false) then return end
    local velocityVectorX = Input.GetActionValue(ButtonAction.ACTION_RIGHT, player.ControllerIndex) - Input.GetActionValue(ButtonAction.ACTION_LEFT, player.ControllerIndex)
    local velocityVectorY = Input.GetActionValue(ButtonAction.ACTION_DOWN, player.ControllerIndex) - Input.GetActionValue(ButtonAction.ACTION_UP, player.ControllerIndex)
    local velocityVector = Vector(velocityVectorX, velocityVectorY):Normalized() * player.MoveSpeed
    clot.Velocity = clot.Velocity + velocityVector
end
EdithCompliance:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, EdithClots.Movement, FamiliarVariant.BLOOD_BABY)