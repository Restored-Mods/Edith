local SaveManager = {}
local Helpers = include("lua.helpers.Helpers")

--Amazing save manager
local continue = false
local function IsContinue()
    local totPlayers = #Isaac.FindByType(EntityType.ENTITY_PLAYER)

    if totPlayers == 0 then
        if Game():GetFrameCount() == 0 then
            continue = false
        else
            local room = Game():GetRoom()
            local desc = Game():GetLevel():GetCurrentRoomDesc()

            if desc.SafeGridIndex == GridRooms.ROOM_GENESIS_IDX then
                if not room:IsFirstVisit() then
                    continue = true
                else
                    continue = false
                end
            else
                continue = true
            end
        end
    end

    return continue
end

function SaveManager:OnPlayerInit()
    if #Isaac.FindByType(EntityType.ENTITY_PLAYER) ~= 0 then return end

    local isContinue = IsContinue()

    if isContinue and EdithRestored:HasData() then
        TSIL.SaveManager.LoadFromDisk()
        EdithRestored.HiddenItemManager:LoadData(TSIL.SaveManager.GetPersistentVariable(EdithRestored, "HiddenItemMangerSave"))
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, SaveManager.OnPlayerInit)

function SaveManager:LoadDSSImGui()
    TSIL.SaveManager.LoadFromDisk()
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_SAVESLOT_LOAD, SaveManager.LoadDSSImGui)

local function SaveAll()
    if not TSIL.Stage.OnFirstFloor() then
        SaveManager:SaveData(true)
    end
end

function SaveManager:SaveData(isSaving)
    if isSaving then
        TSIL.SaveManager.LoadFromDisk()
        TSIL.SaveManager.SetPersistentVariable(EdithRestored, "HiddenItemMangerSave", EdithRestored.HiddenItemManager:GetSaveData())
    end
    TSIL.SaveManager.SaveToDisk()
end
EdithRestored:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, SaveManager.SaveData)
EdithRestored:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, SaveAll)

function SaveManager:LoadUpdate(isLoading)
    for _, player in ipairs(Helpers.GetPlayers()) do
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:AddCacheFlags(CacheFlag.CACHE_SPEED)
        player:EvaluateItems()
        Helpers.ChangeSprite(player,true)
    end
end
EdithRestored:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, SaveManager.LoadUpdate)

EdithRestored:AddCallback(ModCallbacks.MC_GET_CARD, function(_, rng, card, playing, runes, onlyrunes)
    if card == EdithRestored.Enums.Pickups.Cards.CARD_REVERSE_PRUDENCE and not Isaac.GetPersistentGameData():Unlocked(EdithRestored.Enums.Achievements.CompletionMarks.REV_PRUDENCE)
    or card == EdithRestored.Enums.Pickups.Cards.CARD_SOUL_EDITH and not Isaac.GetPersistentGameData():Unlocked(EdithRestored.Enums.Achievements.CompletionMarks.SOUL_EDITH) then
        return 0
    end
end)