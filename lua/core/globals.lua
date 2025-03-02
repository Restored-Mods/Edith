local Helpers = include("lua.helpers.Helpers")
EdithRestored.HiddenItemManager = include("lua.extraLibs.hidden_item_manager")
EdithRestored.HiddenItemManager:Init(EdithRestored)

TSIL.SaveManager.AddPersistentVariable(EdithRestored, "PlayerData", {}, TSIL.Enums.VariablePersistenceMode.RESET_RUN)
TSIL.SaveManager.AddPersistentVariable(EdithRestored, "FamiliarData", {}, TSIL.Enums.VariablePersistenceMode.RESET_RUN)
TSIL.SaveManager.AddPersistentVariable(EdithRestored, "UsedDataMiner", false, TSIL.Enums.VariablePersistenceMode.RESET_RUN)
TSIL.SaveManager.AddPersistentVariable(EdithRestored, "HiddenItemMangerSave", {}, TSIL.Enums.VariablePersistenceMode.RESET_RUN)
TSIL.SaveManager.AddPersistentVariable(EdithRestored, "MoonPhase", 1, TSIL.Enums.VariablePersistenceMode.RESET_RUN)
TSIL.SaveManager.AddPersistentVariable(EdithRestored, "MoonPhaseWolf", false, TSIL.Enums.VariablePersistenceMode.RESET_RUN)

TSIL.SaveManager.AddPersistentVariable(EdithRestored, "DSS", {}, TSIL.Enums.VariablePersistenceMode.NONE, true)
TSIL.SaveManager.AddPersistentVariable(EdithRestored, "OnlyStomps", 1, TSIL.Enums.VariablePersistenceMode.NONE, true)
TSIL.SaveManager.AddPersistentVariable(EdithRestored, "TargetColor", {R = 155, G = 0, B = 0}, TSIL.Enums.VariablePersistenceMode.NONE, true)
TSIL.SaveManager.AddPersistentVariable(EdithRestored, "AllowHolding", 2, TSIL.Enums.VariablePersistenceMode.NONE, true)
TSIL.SaveManager.AddPersistentVariable(EdithRestored, "DisabledItems", {}, TSIL.Enums.VariablePersistenceMode.NONE, true)
TSIL.SaveManager.AddPersistentVariable(EdithRestored, "AlwaysShowMoonPhase", 2, TSIL.Enums.VariablePersistenceMode.NONE, true)

EdithRestored:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    for _, bomb in ipairs(Isaac.FindByType(EntityType.ENTITY_BOMB)) do
        Helpers.GetData(bomb).BombInit = true
    end
end)