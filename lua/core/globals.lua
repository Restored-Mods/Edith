local Helpers = include("lua.helpers.Helpers")
EdithRestored.HiddenItemManager = include("lua.extraLibs.hidden_item_manager")
EdithRestored.HiddenItemManager:Init(EdithRestored)

local runData = {
    ["UsedDataMiner"] = false,
    ["MoonPhase"] = 1,
    ["MoonPhaseWolf"] = false
}

EdithRestored.SaveManager.Utility.AddDefaultRunData(EdithRestored.SaveManager.DefaultSaveKeys.GLOBAL, runData)

EdithRestored:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    for _, bomb in ipairs(Isaac.FindByType(EntityType.ENTITY_BOMB)) do
        Helpers.GetData(bomb).BombInit = true
    end
end)