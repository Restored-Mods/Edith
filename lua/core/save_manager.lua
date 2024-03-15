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

    if isContinue and TC_SaltLady:HasData() then
        TC_SaltLady.HiddenItemManager:LoadData(TSIL.SaveManager.GetPersistentVariable(TC_SaltLady, "HiddenItemMangerSave"))
    end
    for _, funct in ipairs(TC_SaltLady.CallOnStart) do
        funct()
    end
end
TC_SaltLady:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, SaveManager.OnPlayerInit)

function SaveManager:SaveData(isSaving)
    if isSaving then
        TSIL.SaveManager.SetPersistentVariable(TC_SaltLady, "HiddenItemMangerSave", TC_SaltLady.HiddenItemManager:GetSaveData())
    end
end
TC_SaltLady:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, SaveManager.SaveData)

function SaveManager:LoadUpdate(isLoading)
    for _, player in ipairs(Helpers.GetPlayers()) do
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:AddCacheFlags(CacheFlag.CACHE_SPEED)
        player:EvaluateItems()
        Helpers.ChangeSprite(player,true)
    end
end
TC_SaltLady:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, SaveManager.LoadUpdate)

TC_SaltLady:AddCallback(ModCallbacks.MC_GET_CARD, function(_, rng, card, playing, runes, onlyrunes)
    if card == TC_SaltLady.Enums.Pickups.Cards.CARD_REVERSE_PRUDENCE and not Isaac.GetPersistentGameData():Unlocked(TC_SaltLady.Enums.Achievements.REV_PRUDENCE)
    or card == TC_SaltLady.Enums.Pickups.Cards.CARD_SOUL_EDITH and not Isaac.GetPersistentGameData():Unlocked(TC_SaltLady.Enums.Achievements.SOUL_EDITH) then
        return 0
    end
end)