local Sodom = {}
local game = Game()
local Helpers = include("lua.helpers.Helpers")

---@param npc EntityNPC
function Sodom:npcInit(npc)
    local data = EdithRestored:GetData(npc)

    data.SaltedStatusCooldown = 0
    data.SaltedStatusRecharge = 0
    data.SaltedOriginalCollisionDamage = npc.CollisionDamage
    data.SaltedStatusPos =  Vector.Zero
    data.SaltedPlaybackSpeed = npc:GetSprite().PlaybackSpeed

end

--EdithRestored:AddCallback(ModCallbacks.MC_POST_NPC_INIT, Sodom.npcInit)

---@param npc EntityNPC
function Sodom:npcSaltUpdate(npc)
    local data = EdithRestored:GetData(npc)
    if npc.FrameCount < 1 then return end
    if data.SaltedStatusCooldown == nil then
        Sodom:npcInit(npc)
    end
    if not npc:IsDead() and data.SaltedStatusCooldown > 0 then
        npc:SetColor(Color(0.5, 0.5, 0.5, 1, 0.5, 0.5, 0.5), 3, 25, false, true)
        npc.Friction = npc.Friction * 0.01
        npc.CollisionDamage = 0

        npc.Position = data.SaltedStatusPos
        npc:GetSprite().PlaybackSpeed = 0.01

        

        data.SaltedStatusCooldown = math.max(data.SaltedStatusCooldown - 1, 0)

        return true
    end


    if npc:IsDead() and data.SaltedStatusCooldown > 0 then
        data.SaltedStatusCooldown = 0
        if npc:GetSprite().PlaybackSpeed ~= data.SaltedPlaybackSpeed then
            npc:GetSprite().PlaybackSpeed = data.SaltedPlaybackSpeed
        end
    end
    if data.SaltedStatusCooldown <= 0 then
        if npc.CollisionDamage ~= data.SaltedOriginalCollisionDamage then
            npc.CollisionDamage = data.SaltedOriginalCollisionDamage
        end

       if npc:GetSprite().PlaybackSpeed ~= data.SaltedPlaybackSpeed then
            npc:GetSprite().PlaybackSpeed = data.SaltedPlaybackSpeed
        end
    end

    if data.SaltedStatusRecharge > 0 then
        data.SaltedStatusRecharge = math.max(data.SaltedStatusRecharge - 1, 0)
    end
    
end

EdithRestored:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, Sodom.npcSaltUpdate)


---@param player EntityPlayer
function Sodom:SodomItemUpdate(player)
    local room = EdithRestored.Room()

    if player:HasCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_SODOM) then
        local ents = Isaac.FindInRadius(player.Position, 165, EntityPartition.ENEMY)
        for i, _ in ipairs(ents) do
            local data = EdithRestored:GetData(ents[i])
            if ents[i]:IsVulnerableEnemy() and (not ents[i]:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) and room:CheckLine(ents[i].Position, player.Position, 3, 999) and data.SaltedStatusRecharge == 0 then
                data.SaltedStatusCooldown = 120
                data.SaltedStatusRecharge = 210
                data.SaltedStatusPos = ents[i].Position
                data.SaltedPlaybackSpeed = ents[i]:GetSprite().PlaybackSpeed

                local salt = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_BLACKPOWDER, 0, ents[i].Position, Vector.Zero, ents[i]):ToEffect()
                salt.Color = Color(1, 1, 1, 1, 1, 1, 1)
            end
        end
    end
end

EdithRestored:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Sodom.SodomItemUpdate)


--[[function Sodom:preNpcUpdate(npc)
    local data = npc:GetData()

    if data.SaltedStatusCooldown > 1 then
        npc.Position = data.SaltedStatusPos
        npc:GetSprite().PlaybackSpeed = 0.01

        return true
    end
end]]

--EdithRestored:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, Sodom.preNpcUpdate)


return Sodom