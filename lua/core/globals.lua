EdithRestored.HiddenItemManager = include("lua.extraLibs.hidden_item_manager")
EdithRestored.HiddenItemManager:Init(EdithRestored)

EdithRestored.Game = Game()
EdithRestored.Room = function()
	return EdithRestored.Game:GetRoom()
end
EdithRestored.Level = function()
	return EdithRestored.Game:GetLevel()
end

local runData = {
	["UsedDataMiner"] = false,
	["MoonPhase"] = 1,
	["MoonPhaseWolf"] = false
}

EdithRestored.DebugMode = EdithRestored.DebugMode or false
local DebugModeValues = {
	StompRadius = 65,
	InstantJumpCharge = true,
	JumpHeight = 4,
	Gravity = 0.7,
	ShowBoSEffect = false,
	IFrames = 30,
	UseIFrames = false,
}

local DebugModeValuesDefault = {
	StompRadius = 65,
	InstantJumpCharge = true,
	JumpHeight = 4,
	Gravity = 0.7,
	ShowBoSEffect = false,
	IFrames = 30,
	UseIFrames = false,
}

EdithRestored.SaveManager.Utility.AddDefaultRunData(EdithRestored.SaveManager.DefaultSaveKeys.GLOBAL, runData)

EdithRestored:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	for _, bomb in ipairs(Isaac.FindByType(EntityType.ENTITY_BOMB)) do
		EdithRestored:GetData(bomb).BombInit = true
	end
end)

---@param message string
---@param logFile boolean?
function EdithRestored:Log(message, logFile)
	print(message)
	if type(logFile) == "boolean" and logFile == true then
		Isaac.DebugString(message)
	end
end

---@type table[]
local getData = {}

---Slightly faster than calling GetData, a micromanagement at best
---
---However GetData() is wiped on POST_ENTITY_REMOVE, so this also helps retain the data until after entity removal
---@param ent Entity
---@return table
function EdithRestored:GetData(ent)
	if not ent then
		return {}
	end
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

---@param key string
---@return integer | boolean?
function EdithRestored:GetDebugValue(key)
	if EdithRestored.DebugMode then
		if DebugModeValues[key] ~= nil then
			return DebugModeValues[key]
		else
			EdithRestored:Log("Value "..key.." doesn't exist.")
		end
	end
end

---@param key string
---@param value number | boolean
function EdithRestored:SetDebugValue(key, value)
	if EdithRestored.DebugMode then
		if DebugModeValues[key] ~= nil then
			DebugModeValues[key] = value
		else
			EdithRestored:Log("Value "..key.." doesn't exist.")
		end
	end
end

---@param key string
function EdithRestored:SetDefaultDebugValue(key)
	if EdithRestored.DebugMode then
		if DebugModeValues[key] ~= nil then
			DebugModeValues[key] = DebugModeValuesDefault[key]
		else
			EdithRestored:Log("Value "..key.." doesn't exist.")
		end
	end
end