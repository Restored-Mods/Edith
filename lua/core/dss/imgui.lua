if not ImGui.ElementExists("tcMods") then
    ImGui.CreateMenu("tcMods", "TC Mods")
end

if not ImGui.ElementExists("edithCompliance") then
    ImGui.AddElement("tcMods", "edithCompliance", ImGuiElement.Menu, "Edith")
end

if ImGui.ElementExists("edithMenuBlacklistItems") then
    ImGui.RemoveElement("edithMenuBlacklistItems")
end

ImGui.AddElement("edithCompliance", "edithMenuBlacklistItems", ImGuiElement.MenuItem, "\u{f05e} Items Blacklist")

if not ImGui.ElementExists("edithWindowBlacklistItems") then
    ImGui.CreateWindow("edithWindowBlacklistItems", "Items Blacklist")
end


ImGui.LinkWindowToElement("edithWindowBlacklistItems", "edithMenuBlacklistItems")

ImGui.SetWindowSize("edithWindowBlacklistItems", 600, #EdithCompliance.Enums.CollectibleType * 100)

local orderedItems = {}
local itemConfig = Isaac.GetItemConfig()
---@type ItemConfigItem[]
for _, collectible in pairs(EdithCompliance.Enums.CollectibleType) do
    local collectibleConf = itemConfig:GetCollectible(collectible)
    orderedItems[#orderedItems+1] = collectibleConf
end
table.sort(orderedItems, function (a, b)
    return a.Name < b.Name
end)

local function GetItemsEnum(id)
    for enum, collectible in pairs(EdithCompliance.Enums.CollectibleType) do
        if id == collectible then
            return enum
        end
    end
    return ""
end

for _, collectible in pairs(orderedItems) do

    local elemName = string.gsub(collectible.Name, " ", "").."BlackList"
    if ImGui.ElementExists(elemName) then
        ImGui.RemoveElement(elemName)
    end
    
    ImGui.AddCheckbox("edithWindowBlacklistItems", elemName, collectible.Name, function (val)
            --print("that label changed", index, val)
            if not TSIL.SaveManager.GetPersistentVariable(EdithCompliance, "DisabledItems") then
                TSIL.SaveManager.SetPersistentVariable(EdithCompliance, "DisabledItems", {})
            end
            local disabledItems = TSIL.SaveManager.GetPersistentVariable(EdithCompliance, "DisabledItems")
            for indexItem, disabledItem in ipairs(disabledItems) do
                if disabledItem == GetItemsEnum(collectible.ID) then
                    if val then
                        table.remove(disabledItems, indexItem)
                    end
                    break
                end
            end
            
            if not val then
                table.insert(disabledItems, GetItemsEnum(collectible.ID))
            end
            TSIL.SaveManager.SetPersistentVariable(EdithCompliance, "DisabledItems", disabledItems)
            TSIL.SaveManager.SaveToDisk()
            end,
            true
        )
    
    ImGui.AddCallback(elemName, ImGuiCallback.Render, function()
            local val = true
            for indexItem, disabledItem in ipairs(TSIL.SaveManager.GetPersistentVariable(EdithCompliance, "DisabledItems")) do
                if disabledItem == GetItemsEnum(collectible.ID) then
                    val = false
                    break
                end
            end
            ImGui.UpdateData(elemName, ImGuiData.Value, val)
        end)
end

if ImGui.ElementExists("edithMenuSettings") then
    ImGui.RemoveElement("edithMenuSettings")
end

ImGui.AddElement("edithCompliance", "edithMenuSettings", ImGuiElement.MenuItem, "\u{f013} Settings")

if not ImGui.ElementExists("edithWindowSettings") then
    ImGui.CreateWindow("edithWindowSettings", "Settings")
end

ImGui.LinkWindowToElement("edithWindowSettings", "edithMenuSettings")

ImGui.SetWindowSize("edithWindowSettings", 800, 350)

if ImGui.ElementExists("edithPushToSlide") then
    ImGui.RemoveElement("edithPushToSlide")
end

ImGui.AddCheckbox("edithWindowSettings", "edithPushToSlide", "Slide when holding button", function(val)
        TSIL.SaveManager.SetPersistentVariable(EdithCompliance, "AllowHolding", val and 1 or 2)
        TSIL.SaveManager.SaveToDisk()
    end, true)

if ImGui.ElementExists("edithAllowBombs") then
    ImGui.RemoveElement("edithAllowBombs")
end

ImGui.AddCheckbox("edithWindowSettings", "edithAllowBombs", "Edith can use bombs", function(val)
        TSIL.SaveManager.SetPersistentVariable(EdithCompliance, "OnlyStomps", index + 1)
        TSIL.SaveManager.SaveToDisk()
    end,  true)

if not ImGui.ElementExists("edithTargetColorRGB") then
    ImGui.AddInputColor("edithWindowSettings", "edithTargetColorRGB", "\u{f1fc} Edith's Target Color",
        function(r, g, b)
            local targetColor = TSIL.SaveManager.GetPersistentVariable(EdithCompliance, "TargetColor")
            targetColor.R = math.floor(r * 255)
            targetColor.G = math.floor(g * 255)
            targetColor.B = math.floor(b * 255)
            TSIL.SaveManager.SetPersistentVariable(EdithCompliance, "TargetColor", targetColor)
            TSIL.SaveManager.SaveToDisk()
        end,
        155 / 255,
        0,
        0
    )
end

if ImGui.ElementExists("edithAlwaysShowMoonPhase") then
    ImGui.RemoveElement("edithAlwaysShowMoonPhase")
end

ImGui.AddCheckbox("edithWindowSettings", "edithAlwaysShowMoonPhase", "Always show moon phase", function(val)
    local newOption = val and 1 or 2
    TSIL.SaveManager.SetPersistentVariable(EdithCompliance, "AlwaysShowMoonPhase", newOption)
    TSIL.SaveManager.SaveToDisk()
end, true)

ImGui.AddCallback("edithWindowSettings", ImGuiCallback.Render, function()
    ImGui.UpdateData("edithPushToSlide", ImGuiData.Value, TSIL.SaveManager.GetPersistentVariable(EdithCompliance, "AllowHolding") == 1)
    ImGui.UpdateData("edithAllowBombs", ImGuiData.Value, TSIL.SaveManager.GetPersistentVariable(EdithCompliance, "OnlyStomps") == 1)
    local rgb = TSIL.SaveManager.GetPersistentVariable(EdithCompliance, "TargetColor")
    ImGui.UpdateData("edithTargetColorRGB", ImGuiData.ColorValues, {rgb.R / 255, rgb.G / 255, rgb.B / 255})
    ImGui.UpdateData("edithAlwaysShowMoonPhase", ImGuiData.Value, TSIL.SaveManager.GetPersitentVariable(EdithCompliance, "AlwaysShowMoonPhase") == 1)
end)

if ImGui.ElementExists("edithMenuUnlocks") then
    ImGui.RemoveElement("edithMenuUnlocks")
end

ImGui.AddElement("edithCompliance", "edithMenuUnlocks", ImGuiElement.MenuItem, "\u{f013} Unlocks")

if ImGui.ElementExists("edithWindowUnlocks") then
    ImGui.RemoveWindow("edithWindowUnlocks")
end

ImGui.CreateWindow("edithWindowUnlocks", "Edith Unlocks")

ImGui.LinkWindowToElement("edithWindowUnlocks", "edithMenuUnlocks")

local marksA = EdithCompliance.Enums.Achievements.Marks.ASide

local unlocksMarksA = {
	[CompletionType.MOMS_HEART] = "Mom's Heart",
	[CompletionType.ISAAC] = "Isaac",
	[CompletionType.SATAN] = "Satan",
	[CompletionType.BOSS_RUSH] = "Boss Rush",
	[CompletionType.BLUE_BABY] = "???",
	[CompletionType.LAMB] = "Lamb",
	[CompletionType.MEGA_SATAN] = "Mega Satan",
	[CompletionType.HUSH] = "Hush",
	[CompletionType.ULTRA_GREED] = "Ultra Greed",
	[CompletionType.ULTRA_GREEDIER] = "Ultra Greedier",
	[CompletionType.DELIRIUM] = "Delirium",
	[CompletionType.MOTHER] = "Mother",
	[CompletionType.BEAST] = "Beast",
}

ImGui.AddTabBar('edithWindowUnlocks', 'edithMarks')
ImGui.AddTab('edithMarks', 'edithUnlocksA', 'Edith')

for key, val in pairs(unlocksMarksA) do
	if ImGui.ElementExists("edithMark"..key) then
		ImGui.RemoveElement("edithMark"..key)
	end

	ImGui.AddCombobox("edithUnlocksA", "edithMark"..key, val, function(index, val)
		if index == 0 then
			Isaac.ExecuteCommand("lockachievement "..marksA[key])
            Isaac.ExecuteCommand("lockachievement "..marksA[key])
		end
		Isaac.SetCompletionMark(EdithCompliance.Enums.PlayerType.EDITH, key, index)
		if index > 0 then
			if not Isaac.GetPersistentGameData():Unlocked(EdithCompliance.Enums.Achievements.Marks.ASide[key]) then
				Isaac.ExecuteCommand("achievement "..marksA[key])
			end
            if Isaac.AllMarksFilled(EdithCompliance.Enums.PlayerType.EDITH) and not Isaac.GetPersistentGameData():Unlocked(EdithCompliance.Enums.Achievements.CompletionMarks.LOT_BABY) then
                Isaac.ExecuteCommand("achievement "..EdithCompliance.Enums.Achievements.CompletionMarks.LOT_BABY)
            end
		end
	end, { 'None', 'Normal', 'Hard' }, 0, true)
	ImGui.AddCallback("edithMark"..key, ImGuiCallback.Render, function()
        ImGui.UpdateData("edithMark"..key, ImGuiData.Value, Isaac.GetCompletionMark(EdithCompliance.Enums.PlayerType.EDITH, key))
	end)
end

ImGui.AddCombobox("edithUnlocksA", "edithMarkAll", "All Marks", function(index, val)
	if index < 1 then
		Isaac.ExecuteCommand("lockachievement "..EdithCompliance.Enums.Achievements.CompletionMarks.LOT_BABY)
	elseif not Isaac.GetPersistentGameData():Unlocked(EdithCompliance.Enums.Achievements.CompletionMarks.LOT_BABY) then
		Isaac.ExecuteCommand("achievement "..EdithCompliance.Enums.Achievements.CompletionMarks.LOT_BABY)
	end
end, { 'None', 'Unlocked' }, 0, true)

ImGui.AddCallback("edithMarkAll", ImGuiCallback.Render, function()
    local unlocked = Isaac.GetPersistentGameData():Unlocked(EdithCompliance.Enums.Achievements.CompletionMarks.LOT_BABY)
    ImGui.UpdateData("edithMarkAll", ImGuiData.Value, unlocked and 1 or 0)
end)

ImGui.SetWindowSize("edithWindowUnlocks", 800, 650)