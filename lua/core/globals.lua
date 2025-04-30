EdithRestored.HiddenItemManager = include("lua.extraLibs.hidden_item_manager")
EdithRestored.HiddenItemManager:Init(EdithRestored)

EdithRestored.Game = Game()
EdithRestored.Room = function() return EdithRestored.Game:GetRoom() end
EdithRestored.Level = function() return EdithRestored.Game:GetLevel() end

local runData = {
    ["UsedDataMiner"] = false,
    ["MoonPhase"] = 1,
    ["MoonPhaseWolf"] = false
}

EdithRestored.SaveManager.Utility.AddDefaultRunData(EdithRestored.SaveManager.DefaultSaveKeys.GLOBAL, runData)

EdithRestored:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    for _, bomb in ipairs(Isaac.FindByType(EntityType.ENTITY_BOMB)) do
        EdithRestored:GetData(bomb).BombInit = true
    end
end)

---@type table[]
local getData = {}

---Slightly faster than calling GetData, a micromanagement at best
---
---However GetData() is wiped on POST_ENTITY_REMOVE, so this also helps retain the data until after entity removal
---@param ent Entity
---@return table
function EdithRestored:GetData(ent)
	if not ent then return {} end
	local ptrHash = GetPtrHash(ent)
	local data = getData[ptrHash]
	if not data then
		local newData = {}
		getData[ptrHash] = newData
		data = newData
	end
	return data
end

---@param ent Entity
---@return table?
function EdithRestored:TryGetData(ent)
	local ptrHash = GetPtrHash(ent)
	local data = getData[ptrHash]
	return data
end

EdithRestored:AddPriorityCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, CallbackPriority.LATE, function(_, ent)
	getData[GetPtrHash(ent)] = nil
end)