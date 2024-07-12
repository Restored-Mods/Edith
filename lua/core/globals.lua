local Helpers = include("lua.helpers.Helpers")
EdithCompliance.HiddenItemManager = include("lua.extraLibs.hidden_item_manager")
EdithCompliance.HiddenItemManager:Init(EdithCompliance)

TSIL.SaveManager.AddPersistentVariable(EdithCompliance, "PlayerData", {}, TSIL.Enums.VariablePersistenceMode.RESET_RUN)
TSIL.SaveManager.AddPersistentVariable(EdithCompliance, "FamiliarData", {}, TSIL.Enums.VariablePersistenceMode.RESET_RUN)
TSIL.SaveManager.AddPersistentVariable(EdithCompliance, "UsedDataMiner", false, TSIL.Enums.VariablePersistenceMode.RESET_RUN)
TSIL.SaveManager.AddPersistentVariable(EdithCompliance, "HiddenItemMangerSave", {}, TSIL.Enums.VariablePersistenceMode.RESET_RUN)
TSIL.SaveManager.AddPersistentVariable(EdithCompliance, "MoonPhase", 1, TSIL.Enums.VariablePersistenceMode.RESET_RUN)
TSIL.SaveManager.AddPersistentVariable(EdithCompliance, "MoonPhaseWolf", false, TSIL.Enums.VariablePersistenceMode.RESET_RUN)

TSIL.SaveManager.AddPersistentVariable(EdithCompliance, "DSS", {}, TSIL.Enums.VariablePersistenceMode.NONE, true)
TSIL.SaveManager.AddPersistentVariable(EdithCompliance, "OnlyStomps", 1, TSIL.Enums.VariablePersistenceMode.NONE, true)
TSIL.SaveManager.AddPersistentVariable(EdithCompliance, "TargetColor", {R = 155, G = 0, B = 0}, TSIL.Enums.VariablePersistenceMode.NONE, true)
TSIL.SaveManager.AddPersistentVariable(EdithCompliance, "AllowHolding", 2, TSIL.Enums.VariablePersistenceMode.NONE, true)
TSIL.SaveManager.AddPersistentVariable(EdithCompliance, "DisabledItems", {}, TSIL.Enums.VariablePersistenceMode.NONE, true)
TSIL.SaveManager.AddPersistentVariable(EdithCompliance, "AlwaysShowMoonPhase", 2, TSIL.Enums.VariablePersistenceMode.NONE, true)

EdithCompliance:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    for _, bomb in ipairs(Isaac.FindByType(EntityType.ENTITY_BOMB)) do
        Helpers.GetData(bomb).BombInit = true
    end
end)