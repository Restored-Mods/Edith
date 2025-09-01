local LotBaby = {}
local Helpers = EdithRestored.Helpers

local lotBabyDesc = Isaac.GetItemConfig():GetCollectible(EdithRestored.Enums.CollectibleType.COLLECTIBLE_LOT_BABY)
local floatDir = {[Direction.NO_DIRECTION] = "Down", [Direction.UP] = "Up", [Direction.DOWN] = "Down", [Direction.LEFT] = "Side", [Direction.RIGHT] = "Side"}
local vecDir = {[Direction.NO_DIRECTION] = Vector(0, 0), [Direction.UP] = Vector(0, -1), [Direction.DOWN] = Vector(0, 1), [Direction.LEFT] = Vector(-1, 0),[Direction.RIGHT] = Vector(1, 0)}

---@param player EntityPlayer
---@param cache CacheFlag | integer
function LotBaby:Cache(player, cache)
    local numFamiliars = player:GetCollectibleNum(EdithRestored.Enums.CollectibleType.COLLECTIBLE_LOT_BABY) + player:GetEffects():GetCollectibleEffectNum(EdithRestored.Enums.CollectibleType.COLLECTIBLE_LOT_BABY)
	player:CheckFamiliar(EdithRestored.Enums.Familiars.LOT_BABY.Variant, numFamiliars, player:GetCollectibleRNG(EdithRestored.Enums.CollectibleType.COLLECTIBLE_LOT_BABY), lotBabyDesc, EdithRestored.Enums.Familiars.LOT_BABY.SubType)
end
EdithRestored:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, LotBaby.Cache, CacheFlag.CACHE_FAMILIARS)

---@param familiar EntityFamiliar
function LotBaby:Init(familiar)
    familiar.State = 0
    familiar.IsFollower = true
    familiar:RemoveFromFollowers()
    familiar:AddToDelayed()
end
EdithRestored:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, LotBaby.Init, EdithRestored.Enums.Familiars.LOT_BABY.Variant)

function LotBaby:NewRoom()
    for _, lot in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, EdithRestored.Enums.Familiars.LOT_BABY.Variant)) do
        lot = lot:ToFamiliar()
        lot:SetMoveDelayNum(-1)
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, LotBaby.NewRoom)

---@param familiar EntityFamiliar
function LotBaby:Update(familiar)
    local player = familiar.Player
    local fireDir = player:GetFireDirection()
    local tearcd = math.ceil(10 / (player:GetTrinketMultiplier(TrinketType.TRINKET_FORGOTTEN_LULLABY) + 1))
    local bffBonus = player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and 1 or 0
    local edithBonus = Helpers.IsPlayerEdith(player, true, false) and 1 or 0
    familiar.FireCooldown = math.max(0, math.min(familiar.FireCooldown - 1, tearcd))
    local sprite = familiar:GetSprite()
    local data = EdithRestored:GetData(familiar)
    if fireDir ~= Direction.NO_DIRECTION then
        local tearTrajectory = vecDir[fireDir]
        if player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED) or player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK) then
            tearTrajectory = player:GetAimDirection()
        end
        data.animDir = fireDir
        local tearTarget = Helpers.GetNearestEnemy(familiar.Position)
        if tearTarget then
            tearTrajectory = (tearTarget.Position - familiar.Position):Normalized()
            data.animDir = Helpers.VecToDir(tearTrajectory)
        end
        sprite.FlipX = data.animDir == Direction.LEFT
        if familiar.FireCooldown <= 0 then
            local newTrajectory = tearTrajectory * 10
            if newTrajectory:Length() < 10 then
                newTrajectory:Resize(10)
            end
            local tear = familiar:FireProjectile(Vector.Zero)
            tear.Velocity = newTrajectory
            tear.Scale = 0.6 + 0.2 * bffBonus + 0.1 * edithBonus
            tear.CollisionDamage = (3.5 + edithBonus) * (1 + bffBonus)
            if player:HasTrinket(TrinketType.TRINKET_BABY_BENDER) then
                tear:AddTearFlags(TearFlags.TEAR_HOMING)
                tear.Color = Color(0.4, 0.15, 0.38, 1, 0.27843, 0, 0.4549)         
            end
            sprite:Play("FloatShoot"..floatDir[data.animDir], false)
            familiar.FireCooldown = tearcd
        elseif (familiar.FireCooldown > 0) and (familiar.FireCooldown <= tearcd - tearcd/2) and (data.animDir ~= nil) and (not sprite:IsPlaying("Float"..floatDir[data.animDir])) then
            sprite:Play("Float"..floatDir[data.animDir], false)
        end
    else
        if (familiar.FireCooldown <= 0) then
            sprite:Play("Float"..floatDir[fireDir], false)
        end
    end
    local rng = familiar:GetDropRNG()
    if edithBonus > 0 then
        local enemies = Helpers.Filter(Helpers.GetEnemies(), 
                                function(_, enemy)
                                    local ndata = EdithRestored:GetData(enemy)
                                    if familiar.Position:Distance(enemy.Position) < 40 and not enemy:HasEntityFlags(EntityFlag.FLAG_FEAR)
                                    and not ndata.LotFearCooldown then
                                        return true
                                    end
                                end)
        for _,enemy in ipairs(enemies) do
            local ndata = EdithRestored:GetData(enemy)
            if rng:RandomInt(5) == 0 then
               enemy:AddFear(EntityRef(familiar), 60)
            end
            ndata.LotFearCooldown = 60
        end
    end
    familiar:MoveDelayed(20)
end
EdithRestored:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, LotBaby.Update, EdithRestored.Enums.Familiars.LOT_BABY.Variant)

function LotBaby:NPCFearApplyCooldown(npc)
    local data = EdithRestored:GetData(npc)
    if data.LotFearCooldown then
        data.LotFearCooldown = data.LotFearCooldown - 1
        if data.LotFearCooldown <= 0 then
            data.LotFearCooldown = nil
        end
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_NPC_UPDATE, LotBaby.NPCFearApplyCooldown)