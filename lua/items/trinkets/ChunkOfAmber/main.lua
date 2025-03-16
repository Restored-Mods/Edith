---@type fun(pos: Vector, player: EntityPlayer)[]
local OUTCOMES = {
    function (pos)
        TSIL.EntitySpecific.SpawnPickup(
            PickupVariant.PICKUP_NULL,
            0,
            pos
        )
    end,
    function (pos, player)
        player:AddBlueFlies(1, pos, player)
    end,
    function (pos, player)
        player:ThrowBlueSpider(pos, player.Position)
    end
}

---@param entity Entity
EdithRestored:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function (_, entity)
    if not PlayerManager.AnyoneHasTrinket(EdithRestored.Enums.TrinketType.TRINKET_CHUNK_OF_AMBER)
    or not entity:HasEntityFlags(EntityFlag.FLAG_FREEZE) then
        return
    end

    for _, player in ipairs(PlayerManager.GetPlayers()) do
        local rng = player:GetTrinketRNG(EdithRestored.Enums.TrinketType.TRINKET_CHUNK_OF_AMBER)

        for i = 1, player:GetTrinketMultiplier(EdithRestored.Enums.TrinketType.TRINKET_CHUNK_OF_AMBER) do
            OUTCOMES[rng:RandomInt(1, #OUTCOMES)](entity.Position, player)
        end
    end
end)