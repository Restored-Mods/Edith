local Sodom = {}
local Helpers = EdithRestored.Helpers

local function SetOnFire(enemy, player, damage)
    if Helpers.IsEnemy(enemy) then
        damage = damage or 3.5
        enemy:AddBurn(EntityRef(player), 90, damage * 0.8)
        if type(EdithRestored:GetData(enemy).ExplodeInFlames) ~= "boolean" then
            EdithRestored:GetData(enemy).ExplodeInFlames = true
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

local function SpawnSodomFlame(pos, vel, spawner, timeout)
    local fire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, 0, pos, vel, spawner):ToEffect()
    EdithRestored:GetData(fire).SodomFire = true
    fire.CollisionDamage = (spawner and spawner:ToPlayer()) and spawner:ToPlayer().Damage or 3.5
    fire:SetTimeout(timeout or 90)
end

---@param player EntityPlayer
function Sodom:DontLookBack(player)
    if player:HasCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_SODOM) then
        local data = EdithRestored:GetData(player)
        data.SodomFireCountdown = data.SodomFireCountdown or 20
        data.SodomEdithResetPause = data.SodomEdithResetPause or 0
        if not Helpers.VectorEquals(player:GetMovementVector(), Vector.Zero)
        or Helpers.IsPureEdith(player) and data.EdithTargetMovementPosition
        and not Helpers.VectorEquals(player.Velocity, Vector.Zero) then
            data.SodomFireCountdown = data.SodomFireCountdown - 1
            data.SodomEdithResetPause = Helpers.IsPureEdith(player) and 10 or 0
            if data.SodomFireCountdown <= 0 then
                local vel = Helpers.IsPureEdith(player) and player.Velocity:Normalized() or player:GetMovementVector()
                SpawnSodomFlame(player.Position, vel * -1, player, 50)
                data.SodomFireCountdown = 20
            end
        elseif data.SodomEdithResetPause == 0 then
            data.SodomFireCountdown = 20
        else
            data.SodomEdithResetPause = math.max(data.SodomEdithResetPause - 1, 0)
        end
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Sodom.DontLookBack)

---@param npc EntityNPC
function Sodom:NPCOnFireUpdate(npc)
    local data = EdithRestored:GetData(npc)
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
    local data = EdithRestored:GetData(ent)
    if source.Entity and source.Type == EntityType.ENTITY_EFFECT and source.Variant == EffectVariant.RED_CANDLE_FLAME then
        local fireData = EdithRestored:GetData(source.Entity)
        if fireData.SodomFire then
            if not data.AlreadySodomFlameHit then
                data.AlreadySodomFlameHit = true
                SetOnFire(ent, source.Entity.SpawnerEntity and source.Entity.SpawnerEntity:ToPlayer() or GetRandomPlayerWithSodom(), source.Entity.CollisionDamage)
            end
            return {Damage = 0.001, DamageFlags = flags, DamageCountdown = cd}
        end
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Sodom.AcumulateFire)

---@param ent Entity
function Sodom:SpreadFire(ent)
    local data = EdithRestored:GetData(ent)
    if data.ExplodeInFlames then
        for _, angle in ipairs({TSIL.Random.GetRandomInt(1, 120), TSIL.Random.GetRandomInt(121, 240), TSIL.Random.GetRandomInt(241, 360)}) do
            SpawnSodomFlame(ent.Position, Vector.FromAngle(angle):Resized(10), GetRandomPlayerWithSodom(), 90)
        end
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, Sodom.SpreadFire)