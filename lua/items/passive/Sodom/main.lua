local Sodom = {}
local game = Game()
local Helpers = include("lua.helpers.Helpers")

local function SetOnFire(enemy, player)
    if Helpers.IsEnemy(enemy) then
        enemy:AddBurn(EntityRef(player), 90, player.Damage * 0.8)
        if type(Helpers.GetData(enemy).ExplodeInFlames) ~= "boolean" then
            Helpers.GetData(enemy).ExplodeInFlames = true
        end
    end
end

local function GetRandomPlayerWithSodom(players)
    players = players or Helpers.Filter(PlayerManager.GetPlayers(), function(_, player) return player:HasCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_SODOM) end)
    if #players > 0 then
        return players[TSIL.Random.GetRandomInt(1, #players)]
    end
    return nil
end

function Sodom:NewRoom()
    local players = Helpers.Filter(PlayerManager.GetPlayers(), function(_, player) return player:HasCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_SODOM) end)
    if #players > 0 then
        for _, enemy in ipairs(Helpers.GetEnemies()) do
            local player = GetRandomPlayerWithSodom(players)
            SetOnFire(enemy, player)
        end
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Sodom.NewRoom)

---@param npc EntityNPC
function Sodom:NPCOnFireUpdate(npc)
    local data = Helpers.GetData(npc)
    if data.ExplodeInFlames and not npc:HasEntityFlags(EntityFlag.FLAG_BURN) then
        data.ExplodeInFlames = false
    end

end
EdithRestored:AddCallback(ModCallbacks.MC_NPC_UPDATE, Sodom.NPCOnFireUpdate)

---@param ent Entity
---@param damage integer
---@param flags DamageFlag | integer
---@param source EntityRef
---@param cd integer
function Sodom:AcumulateFire(ent, damage, flags, source, cd)
    local data = Helpers.GetData(ent)
    
    if source.Entity and source.Type == EntityType.ENTITY_FIREPLACE then
        local fireData = Helpers.GetData(source.Entity)
        if not data.AlreadyHit then
            data.AlreadyHit = {}
        end
        if fireData.SodomFire and not data.AlreadyHit[GetPtrHash(ent)] then
            data.AlreadyHit[GetPtrHash(ent)] = true
            SetOnFire(ent, source.Entity.SpawnerEntity and source.Entity.SpawnerEntity:ToPlayer() or GetRandomPlayerWithSodom())
        end
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, Sodom.AcumulateFire)

function Sodom:SpreadFire(ent)
    local data = Helpers.GetData(ent)
    if data.ExplodeInFlames then
        for _, angle in ipairs({0, 45, 90, 135, 180, 225, 270, 315}) do
            local fire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, 0, ent.Position, Vector.FromAngle(angle):Resized(10), GetRandomPlayerWithSodom()):ToEffect()
            Helpers.GetData(fire).SodomFire = true
            fire:SetTimeout(90)
        end
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, Sodom.SpreadFire)