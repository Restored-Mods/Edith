local EdithClots = {}
local Helpers = EdithRestored.Helpers

---@param clot EntityFamiliar
function EdithClots:Movement(clot)
    local player = clot.Parent or clot.SpawnerEntity
    if not player or not player:ToPlayer() or Helpers.IsMenuing() then return end
    player = player:ToPlayer()
    if not Helpers.IsPlayerEdith(player, true, false) then return end
    local velocityVectorX = Input.GetActionValue(ButtonAction.ACTION_RIGHT, player.ControllerIndex) - Input.GetActionValue(ButtonAction.ACTION_LEFT, player.ControllerIndex)
    local velocityVectorY = Input.GetActionValue(ButtonAction.ACTION_DOWN, player.ControllerIndex) - Input.GetActionValue(ButtonAction.ACTION_UP, player.ControllerIndex)
    local mirrorMul = Helpers.InMirrorWorld() and -1 or 1
    local velocityVector = Vector(velocityVectorX * mirrorMul, velocityVectorY):Normalized() * player.MoveSpeed
    clot.Velocity = clot.Velocity + velocityVector
end
EdithRestored:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, EdithClots.Movement, FamiliarVariant.BLOOD_BABY)