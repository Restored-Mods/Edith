local pgd = Isaac.GetPersistentGameData()

local orderedItems = {}

local itemConfig = Isaac.GetItemConfig()
---@type ItemConfigItem[]

local function RemoveZeroWidthSpace(str)
	if str:sub(1, 3) == "​" then
		str = str:sub(4, str:len())
	end
	return str
end

for idx, collectible in pairs(EdithRestored.Enums.CollectibleType) do
	local collectibleConf = itemConfig:GetCollectible(collectible)
	orderedItems[#orderedItems + 1] = collectibleConf
end
table.sort(orderedItems, function(a, b)
	return a.Name < b.Name
end)

local function ShowBlackListButton()
	for idx, collectible in pairs(EdithRestored.Enums.CollectibleType) do
		local collectibleConf = Isaac.GetItemConfig():GetCollectible(collectible)
		if collectibleConf then
			if collectibleConf.AchievementID == -1 or pgd:Unlocked(collectibleConf.AchievementID) then
				return true
			end
		end
	end
	return false
end

local function RemoveBlacklistItems()
	for _, collectible in pairs(orderedItems) do
		local elemName = string.gsub(collectible.Name, " ", "") .. "BlackList"
		if ImGui.ElementExists(elemName) then
			ImGui.RemoveCallback(elemName, ImGuiCallback.Render)
			ImGui.RemoveElement(elemName)
		end
	end
end

local function ReOrederItems()
	local function GetItemsEnum(id)
		for enum, collectible in pairs(EdithRestored.Enums.CollectibleType) do
			if id == collectible then
				return enum
			end
		end
		return ""
	end
	local i = 0
	RemoveBlacklistItems()
	for _, collectible in pairs(orderedItems) do
		local elemName = string.gsub(collectible.Name, " ", "") .. "BlackList"
		if pgd:Unlocked(collectible.AchievementID) then
			i = i + 1
			ImGui.AddCheckbox("edithWindowBlacklistItems", elemName, RemoveZeroWidthSpace(collectible.Name), function(val)
				local disabledItems = EdithRestored:GetDefaultFileSave("DisabledItems")
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
				EdithRestored.SaveManager.Save()
			end, true)

			ImGui.AddCallback(elemName, ImGuiCallback.Render, function()
				local val = true
				for indexItem, disabledItem in
					ipairs(EdithRestored:GetDefaultFileSave("DisabledItems"))
				do
					if disabledItem == GetItemsEnum(collectible.ID) then
						val = false
						break
					end
				end
				ImGui.UpdateData(elemName, ImGuiData.Value, val)
			end)
		end
	end
	ImGui.SetWindowSize("edithWindowBlacklistItems", 600, 10 + i * 90 + (1 - i) * 44)
end

local function UpdateBlackListMenu(show)
	if not ShowBlackListButton() then 
		if ImGui.ElementExists("edithWindowBlacklistItems") then
			ImGui.RemoveWindow("edithWindowBlacklistItems")
		end
		if ImGui.ElementExists("edithMenuBlacklistItems") then
			ImGui.RemoveElement("edithMenuBlacklistItems")
		end
		return 
	end
	if not ImGui.ElementExists("edithMenuBlacklistItems") then
		ImGui.AddElement("EdithRestored", "edithMenuBlacklistItems", ImGuiElement.MenuItem, "\u{f05e} Items Blacklist")
	end

	if not ImGui.ElementExists("edithWindowBlacklistItems") then
		ImGui.CreateWindow("edithWindowBlacklistItems", "Items Blacklist")
		ImGui.LinkWindowToElement("edithWindowBlacklistItems", "edithMenuBlacklistItems")
	end
	if show then
		if ImGui.ElementExists("edithMenuBlacklistItemsNoWay") then
			ImGui.RemoveElement("edithMenuBlacklistItemsNoWay")
		end
		ReOrederItems()
	else
		RemoveBlacklistItems()
		if not ImGui.ElementExists("edithMenuBlacklistItemsNoWay") then
			ImGui.AddText("edithWindowBlacklistItems", "Options will be available after loading the game.", true, "edithMenuBlacklistItemsNoWay")
		end
	end
end

local function UpdateSettingsMenu(show)
	if not ImGui.ElementExists("edithMenuSettings") then
		ImGui.AddElement("EdithRestored", "edithMenuSettings", ImGuiElement.MenuItem, "\u{f013} Settings")
	end

	if not ImGui.ElementExists("edithWindowSettings") then
		ImGui.CreateWindow("edithWindowSettings", "Settings")
		ImGui.LinkWindowToElement("edithWindowSettings", "edithMenuSettings")
		ImGui.SetWindowSize("edithWindowSettings", 800, 350)
	end
	if show then
		if ImGui.ElementExists("edithMenuSettingsNoWay") then
			ImGui.RemoveElement("edithMenuSettingsNoWay")
		end

		if not ImGui.ElementExists("edithPushToSlide") then
			ImGui.AddCheckbox("edithWindowSettings", "edithPushToSlide", "Slide when holding button", function(val)
				EdithRestored:AddDefaultFileSave("AllowHolding", val)
				EdithRestored.SaveManager.Save()
			end, true)
		end

		if not ImGui.ElementExists("edithAllowBombs") then
			ImGui.AddCheckbox("edithWindowSettings", "edithAllowBombs", "Edith can use bombs", function(val)
				EdithRestored:AddDefaultFileSave("OnlyStomps", val)
				EdithRestored.SaveManager.Save()
			end, true)
		end

		--Disabled since RemoveElement doesn't work in 1.0.12e and lower
		--[[if not ImGui.ElementExists("edithTargetColorRGB") then
			
			ImGui.AddInputColor("edithWindowSettings", "edithTargetColorRGB", "\u{f1fc} Edith's Target Color", function(r, g, b)
				local targetColor = EdithRestored:GetDefaultFileSave("TargetColor")
				targetColor.R = math.floor(r * 255)
				targetColor.G = math.floor(g * 255)
				targetColor.B = math.floor(b * 255)
				EdithRestored.SaveManager.Save()
			end, 155 / 255, 0, 0)
		end]]

		if not ImGui.ElementExists("edithAlwaysShowMoonPhase") then
			ImGui.AddCheckbox("edithWindowSettings", "edithAlwaysShowMoonPhase", "Always show moon phase", function(val)
				EdithRestored:AddDefaultFileSave("AlwaysShowMoonPhase", val)
				EdithRestored.SaveManager.Save()
			end, true)
		end

		ImGui.AddCallback("edithWindowSettings", ImGuiCallback.Render, function()
			ImGui.UpdateData(
				"edithPushToSlide",
				ImGuiData.Value,
				EdithRestored:GetDefaultFileSave("AllowHolding")
			)
			ImGui.UpdateData(
				"edithAllowBombs",
				ImGuiData.Value,
				EdithRestored:GetDefaultFileSave("OnlyStomps")
			)
			local rgb = EdithRestored:GetDefaultFileSave("TargetColor")
			ImGui.UpdateData("edithTargetColorRGB", ImGuiData.ColorValues, { rgb.R / 255, rgb.G / 255, rgb.B / 255 })
			ImGui.UpdateData(
				"edithAlwaysShowMoonPhase",
				ImGuiData.Value,
				EdithRestored:GetDefaultFileSave("AlwaysShowMoonPhase")
			)
		end)
	else
		ImGui.RemoveCallback("edithWindowSettings", ImGuiCallback.Render)

		if ImGui.ElementExists("edithMenuSettingsNoWay") then
			ImGui.RemoveElement("edithMenuSettingsNoWay")
		end

		if ImGui.ElementExists("edithPushToSlide") then
			ImGui.RemoveElement("edithPushToSlide")
		end

		if ImGui.ElementExists("edithAllowBombs") then
			ImGui.RemoveElement("edithAllowBombs")
		end

		if ImGui.ElementExists("edithTargetColorRGB") then
			ImGui.RemoveElement("edithTargetColorRGB")
		end

		if ImGui.ElementExists("edithAlwaysShowMoonPhase") then
			ImGui.RemoveElement("edithAlwaysShowMoonPhase")
		end

		if not ImGui.ElementExists("edithMenuSettingsNoWay") then
			ImGui.AddText("edithWindowSettings", "Options will be available after loading the game.", true, "edithMenuSettingsNoWay")
		end
	end
end

local function UpdateImGuiMenu(IsDataInitialized)
	UpdateSettingsMenu(IsDataInitialized)
	UpdateBlackListMenu(IsDataInitialized)
end

local function InitImGuiMenu()
	if not ImGui.ElementExists("RestoredMods") then
		ImGui.CreateMenu("RestoredMods", "Restored Mods")
	end

	if not ImGui.ElementExists("EdithRestored") then
		ImGui.AddElement("RestoredMods", "EdithRestored", ImGuiElement.Menu, "Edith")
	end

	UpdateImGuiMenu()
	UpdateBlackListMenu()

	if not ImGui.ElementExists("edithMenuUnlocks") then
		ImGui.AddElement("EdithRestored", "edithMenuUnlocks", ImGuiElement.MenuItem, "\u{f09c} Unlocks")
	end
		
	if not ImGui.ElementExists("edithWindowUnlocks") then
		ImGui.CreateWindow("edithWindowUnlocks", "Edith Unlocks")
		ImGui.LinkWindowToElement("edithWindowUnlocks", "edithMenuUnlocks")
	end
	
	local marksA = EdithRestored.Enums.Achievements.Marks.ASide
	
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
	
	if ImGui.ElementExists("edithMarks") then
		ImGui.RemoveElement("edithMarks")
	end

	ImGui.AddTabBar("edithWindowUnlocks", "edithMarks")
	ImGui.AddTab("edithMarks", "edithUnlocksA", "Edith")
	
	for key, val in pairs(unlocksMarksA) do
		if ImGui.ElementExists("edithMark" .. key) then
			ImGui.RemoveElement("edithMark" .. key)
		end
	
		ImGui.AddCombobox("edithUnlocksA", "edithMark" .. key, val, function(index, val)
			if index == 0 then
				Isaac.ExecuteCommand("lockachievement " .. marksA[key])
				Isaac.ExecuteCommand("lockachievement " .. marksA[key])
			end
			Isaac.SetCompletionMark(EdithRestored.Enums.PlayerType.EDITH, key, index)
			if index > 0 then
				if not pgd:Unlocked(EdithRestored.Enums.Achievements.Marks.ASide[key]) then
					Isaac.ExecuteCommand("achievement " .. marksA[key])
				end
				if
					Isaac.AllMarksFilled(EdithRestored.Enums.PlayerType.EDITH) > 0
					and not pgd:Unlocked(EdithRestored.Enums.Achievements.CompletionMarks.SOUL_EDITH)
				then
					Isaac.ExecuteCommand("achievement " .. EdithRestored.Enums.Achievements.CompletionMarks.SOUL_EDITH)
				end
			end
			UpdateBlackListMenu()
		end, { "None", "Normal", "Hard" }, 0, true)
		ImGui.AddCallback("edithMark" .. key, ImGuiCallback.Render, function()
			ImGui.UpdateData(
				"edithMark" .. key,
				ImGuiData.Value,
				Isaac.GetCompletionMark(EdithRestored.Enums.PlayerType.EDITH, key)
			)
		end)
	end
	
	ImGui.AddCombobox("edithUnlocksA", "edithMarkAll", "All Marks", function(index, val)
		if index < 1 then
			Isaac.ExecuteCommand("lockachievement " .. EdithRestored.Enums.Achievements.CompletionMarks.SOUL_EDITH)
		elseif not pgd:Unlocked(EdithRestored.Enums.Achievements.CompletionMarks.SOUL_EDITH) then
			Isaac.ExecuteCommand("achievement " .. EdithRestored.Enums.Achievements.CompletionMarks.SOUL_EDITH)
			for key, val in pairs(unlocksMarksA) do
				if not pgd:Unlocked(EdithRestored.Enums.Achievements.Marks.ASide[key]) then
					Isaac.ExecuteCommand("achievement " .. marksA[key])
					Isaac.SetCompletionMark(EdithRestored.Enums.PlayerType.EDITH, key, 1)
				end
			end
		end
		UpdateBlackListMenu()
	end, { "None", "Unlocked" }, 0, true)
	
	ImGui.AddCallback("edithMarkAll", ImGuiCallback.Render, function()
		local unlocked = pgd:Unlocked(EdithRestored.Enums.Achievements.CompletionMarks.SOUL_EDITH)
		ImGui.UpdateData("edithMarkAll", ImGuiData.Value, unlocked and 1 or 0)
	end)
	
	ImGui.SetWindowSize("edithWindowUnlocks", 800, 650)
end

EdithRestored:AddCallback(ModCallbacks.MC_POST_COMPLETION_MARK_GET, function()
	UpdateBlackListMenu(Isaac.IsInGame())
end, EdithRestored.Enums.PlayerType.EDITH)

---@param cmd string
EdithRestored:AddCallback(ModCallbacks.MC_EXECUTE_CMD, function(_, cmd, args)
	if string.lower(cmd):match("achievement") == "achievement" then
		UpdateBlackListMenu(Isaac.IsInGame())
	end
end, EdithRestored.Enums.PlayerType.EDITH)

InitImGuiMenu()
UpdateImGuiMenu()

local InGame = false

local function UpdateImGuiOnRender()
	if not Isaac.IsInGame() and InGame then
		UpdateImGuiMenu(false)
		InGame = false
	elseif Isaac.IsInGame() and not InGame then
		UpdateImGuiMenu(true)
		InGame = true
	end
end
EdithRestored:AddPriorityCallback(ModCallbacks.MC_POST_RENDER, CallbackPriority.LATE, UpdateImGuiOnRender)
EdithRestored:AddPriorityCallback(ModCallbacks.MC_MAIN_MENU_RENDER, CallbackPriority.LATE, UpdateImGuiOnRender)

---@param completion CompletionType
EdithRestored:AddCallback(ModCallbacks.MC_POST_COMPLETION_EVENT, function(_, completion)
	UpdateBlackListMenu(Isaac.IsInGame())
end)