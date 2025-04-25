local Unlock = {}
local Helpers = include("lua.helpers.Helpers")

function Unlock:DataMinerUse(collectible, rng, player, flags, slot, vardata)
    local usedDataMiner = EdithRestored:GetDefaultFileSave("UsedDataMiner")
    if not usedDataMiner and not Game():AchievementUnlocksDisallowed()
    and not Isaac.GetPersistentGameData():Unlocked(EdithRestored.Enums.Achievements.Characters.EDITH) then
        local room = Game():GetRoom()
        local gridTable = {}
        for i = 0, (room:GetGridSize()) do
            local gent = room:GetGridEntity(i)
            if gent and gent:IsBreakableRock() and gent.State < 2 then
                table.insert(gridTable, gent)
            end
        end
        if #gridTable > 0 and rng:RandomFloat() >= 0.75 then
            local saltGent = gridTable[rng:RandomInt(#gridTable) + 1]
            saltGent:SetVariant(683)
            EdithRestored:AddDefaultFileSave("UsedDataMiner", true)
        end
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_USE_ITEM, Unlock.DataMinerUse, CollectibleType.COLLECTIBLE_DATAMINER)

---@param grid GridEntity
---@param gridType GridEntityType
---@param immediate boolean
function Unlock:OnKillSaltRock(grid, gridType, immediate)
	if grid:GetVariant() == 683 and not Isaac.GetPersistentGameData():Unlocked(EdithRestored.Enums.Achievements.Characters.EDITH) 
    and Game():GetItemPool():HasTrinket(EdithRestored.Enums.TrinketType.TRINKET_SALT_ROCK) then
        local rng = grid:GetRNG()
        local vel = EntityPickup.GetRandomPickupVelocity(grid.Position, rng, 0)
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, EdithRestored.Enums.TrinketType.TRINKET_SALT_ROCK, grid.Position, vel, nil):ToPickup()
        Game():GetItemPool():RemoveTrinket(EdithRestored.Enums.TrinketType.TRINKET_SALT_ROCK)
        SFXManager():Play(SoundEffect.SOUND_MAGGOT_ENTER_GROUND)
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_GRID_ROCK_DESTROY, Unlock.OnKillSaltRock, GridEntityType.GRID_ROCK)

---@param player EntityPlayer
---@return boolean
function Unlock:SaltyRevive(player)
    if player:HasTrinket(EdithRestored.Enums.TrinketType.TRINKET_SALT_ROCK) and
    not Isaac.GetPersistentGameData():Unlocked(EdithRestored.Enums.Achievements.Characters.EDITH) then
        Helpers.UnlockAchievement(EdithRestored.Enums.Achievements.Characters.EDITH)
        player:ChangePlayerType(EdithRestored.Enums.PlayerType.EDITH)
        player:TryRemoveTrinket(EdithRestored.Enums.TrinketType.TRINKET_SALT_ROCK)
        Game():StartRoomTransition(Game():GetLevel():GetPreviousRoomIndex(), Direction.NO_DIRECTION)
        return false
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_TRIGGER_PLAYER_DEATH_POST_CHECK_REVIVES, Unlock.SaltyRevive)

function Unlock:DoubleCheck(cont)
    if not cont and not Isaac.GetPersistentGameData():Unlocked(EdithRestored.Enums.Achievements.Characters.EDITH) then
        Game():GetItemPool():ResetTrinkets()
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Unlock.DoubleCheck)

function Unlock:MoreDaraMiner(collectible, itemPoolType, Decrease, seed)
    if not Game():AchievementUnlocksDisallowed()
    and not Isaac.GetPersistentGameData():Unlocked(EdithRestored.Enums.Achievements.Characters.EDITH)
    and not PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_DATAMINER)
    and not EdithRestored:GetDefaultFileSave("UsedDataMiner")
    and TSIL.Random.GetRandom(seed) >= 0.8 then
        return CollectibleType.COLLECTIBLE_DATAMINER
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, Unlock.MoreDaraMiner)