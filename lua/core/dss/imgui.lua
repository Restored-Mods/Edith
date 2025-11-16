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
			ImGui.AddCheckbox(
				"edithWindowBlacklistItems",
				elemName,
				RemoveZeroWidthSpace(collectible.Name),
				function(val)
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
				end,
				true
			)

			ImGui.AddCallback(elemName, ImGuiCallback.Render, function()
				local val = true
				for indexItem, disabledItem in ipairs(EdithRestored:GetDefaultFileSave("DisabledItems")) do
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
			ImGui.AddText(
				"edithWindowBlacklistItems",
				"Options will be available after loading the game.",
				true,
				"edithMenuBlacklistItemsNoWay"
			)
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

		ImGui.AddCallback("edithWindowSettings", ImGuiCallback.Render, function()
			ImGui.UpdateData("edithPushToSlide", ImGuiData.Value, EdithRestored:GetDefaultFileSave("AllowHolding"))
			ImGui.UpdateData("edithAllowBombs", ImGuiData.Value, EdithRestored:GetDefaultFileSave("OnlyStomps"))
			--local rgb = EdithRestored:GetDefaultFileSave("TargetColor")
			--ImGui.UpdateData("edithTargetColorRGB", ImGuiData.ColorValues, { rgb.R / 255, rgb.G / 255, rgb.B / 255 })
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

		if not ImGui.ElementExists("edithMenuSettingsNoWay") then
			ImGui.AddText(
				"edithWindowSettings",
				"Options will be available after loading the game.",
				true,
				"edithMenuSettingsNoWay"
			)
		end
	end
end

local function RedMoonSilder(bool)
	if bool and ImGui.ElementExists("edithDebugModeTabRedHood") then
		if ImGui.ElementExists("edithDebugModeTabRedHoodText") then
			ImGui.RemoveElement("edithDebugModeTabRedHoodText")
		end
		if not ImGui.ElementExists("edithDebugModeTabRedHoodPhase") then
			ImGui.AddSliderInteger(
				"edithDebugModeTabRedHood",
				"edithDebugModeTabRedHoodPhase",
				"Red Moon phase",
				function(newVal)
					EdithRestored.SetRedMoon(newVal == 5 or EdithRestored:GetDebugValue("AlwaysRedMoon"))
					EdithRestored.SetMoon(
						newVal,
						newVal == 5 or EdithRestored:GetDebugValue("AlwaysRedMoon"),
						EdithRestored:RunSave()["MoonPhase"] > newVal
					)
					EdithRestored:RunSave()["MoonPhase"] = newVal
				end,
				EdithRestored:RunSave()["MoonPhase"],
				1,
				8
			)

			ImGui.AddCallback("edithDebugModeTabRedHoodPhase", ImGuiCallback.Render, function()
				ImGui.UpdateData("edithDebugModeTabRedHoodPhase", ImGuiData.Value, EdithRestored:RunSave()["MoonPhase"])
			end)
		end
		if not ImGui.ElementExists("edithDebugModeTabRedHoodAlwaysShowMoonPhase") then
			ImGui.AddCheckbox(
				"edithDebugModeTabRedHood",
				"edithDebugModeTabRedHoodAlwaysShowMoonPhase",
				"Always show Moon phase",
				function(newVal)
					EdithRestored:SetDebugValue("AlwaysShowMoonPhase", newVal)
					EdithRestored.SetRedMoon(newVal == 5 or EdithRestored:GetDebugValue("AlwaysRedMoon"))
				end,
				EdithRestored:GetDebugValue("AlwaysShowMoonPhase")
			)
			ImGui.AddCallback("edithDebugModeTabRedHoodAlwaysShowMoonPhase", ImGuiCallback.Render, function()
				ImGui.UpdateData(
					"edithDebugModeTabRedHoodAlwaysShowMoonPhase",
					ImGuiData.Value,
					EdithRestored:GetDebugValue("AlwaysShowMoonPhase")
				)
			end)
		end
		if not ImGui.ElementExists("edithDebugModeTabRedHoodAdvance") then
			ImGui.AddCheckbox(
				"edithDebugModeTabRedHood",
				"edithDebugModeTabRedHoodAdvance",
				"Disable Moon phase advancement",
				function(newVal)
					EdithRestored:SetDebugValue("DisableMoonProgression", newVal)
				end,
				EdithRestored:GetDebugValue("DisableMoonProgression")
			)
			ImGui.AddCallback("edithDebugModeTabRedHoodAdvance", ImGuiCallback.Render, function()
				ImGui.UpdateData(
					"edithDebugModeTabRedHoodAdvance",
					ImGuiData.Value,
					EdithRestored:GetDebugValue("DisableMoonProgression")
				)
			end)
		end
		if not ImGui.ElementExists("edithDebugModeTabRedHoodAlwaysRedMoon") then
			ImGui.AddCheckbox(
				"edithDebugModeTabRedHood",
				"edithDebugModeTabRedHoodAlwaysRedMoon",
				"Always Red moon phase",
				function(newVal)
					EdithRestored:SetDebugValue("AlwaysRedMoon", newVal)
					EdithRestored.SetRedMoon(EdithRestored:RunSave()["MoonPhase"] == 5 or newVal)
				end,
				EdithRestored:GetDebugValue("AlwaysRedMoon")
			)
			ImGui.AddCallback("edithDebugModeTabRedHoodAlwaysRedMoon", ImGuiCallback.Render, function()
				ImGui.UpdateData(
					"edithDebugModeTabRedHoodAlwaysRedMoon",
					ImGuiData.Value,
					EdithRestored:GetDebugValue("AlwaysRedMoon")
				)
			end)
		end
	else
		for _, text in ipairs({
			"edithDebugModeTabRedHoodPhase",
			"edithDebugModeTabRedHoodAlwaysShowMoonPhase",
			"edithDebugModeTabRedHoodAdvance",
			"edithDebugModeTabRedHoodAlwaysRedMoon",
		}) do
			if ImGui.ElementExists(text) then
				ImGui.RemoveElement(text)
			end
		end
		if
			not ImGui.ElementExists("edithDebugModeTabRedHoodText") and ImGui.ElementExists("edithDebugModeTabRedHood")
		then
			ImGui.AddText(
				"edithDebugModeTabRedHood",
				"Enter run for options to appear",
				true,
				"edithDebugModeTabRedHoodText"
			)
		end
	end
end

local function UpdateImGuiMenu(IsDataInitialized)
	UpdateSettingsMenu(IsDataInitialized)
	UpdateBlackListMenu(IsDataInitialized)
end

local function UpdateDebugMode()
	if EdithRestored.DebugMode then
		--#region Init ImGui menu
		if not ImGui.ElementExists("edithDebugModeSettings") then
			ImGui.AddElement(
				"EdithRestored",
				"edithDebugModeSettings",
				ImGuiElement.MenuItem,
				"\u{f188} Debug Mode Settings"
			)
		end

		if not ImGui.ElementExists("edithWindowDebugModeSettings") then
			ImGui.CreateWindow("edithWindowDebugModeSettings", "Debug Mode Settings")
			ImGui.LinkWindowToElement("edithWindowDebugModeSettings", "edithDebugModeSettings")
			ImGui.SetWindowSize("edithWindowDebugModeSettings", 800, 350)
		end

		if ImGui.ElementExists("edithDebugModeTabBar") then
			ImGui.RemoveElement("edithDebugModeTabBar")
		end

		ImGui.AddTabBar("edithWindowDebugModeSettings", "edithDebugModeTabBar")

		ImGui.AddTab("edithDebugModeTabBar", "edithDebugModeTabEdith", "Edith")
		ImGui.AddTab("edithDebugModeTabBar", "edithDebugModeTabPeppermintCloud", "Peppermint Cloud")
		ImGui.AddTab("edithDebugModeTabBar", "edithDebugModeTabRedHood", "Red Hood")
		ImGui.AddTab("edithDebugModeTabBar", "edithDebugModeTabMisc", "Miscellaneous")

		--#endregion

		--#region Edith specific
		ImGui.AddSliderInteger("edithDebugModeTabEdith", "edithDebugModeStompRadius", "Stomp radius", function(newVal)
			EdithRestored:SetDebugValue("StompRadius", newVal)
		end, EdithRestored:GetDebugValue("StompRadius"), 30, 100)

		ImGui.AddButton("edithDebugModeTabEdith", "edithDebugModeStompRadiusButtonReset", "Reset", function(newVal)
			EdithRestored:SetDefaultDebugValue("StompRadius")
			ImGui.UpdateData("edithDebugModeStompRadius", ImGuiData.Value, EdithRestored:GetDebugValue("StompRadius"))
		end, false)

		ImGui.AddSliderFloat("edithDebugModeTabEdith", "edithDebugModeJumpHeight", "Jump Height", function(newVal)
			EdithRestored:SetDebugValue("JumpHeight", newVal)
		end, EdithRestored:GetDebugValue("JumpHeight"), 1, 10, "%.2f")

		if ImGui.ElementExists("edithDebugModeJumpHeightButtonReset") then
			ImGui.RemoveElement("edithDebugModeJumpHeightButtonReset")
		end

		ImGui.AddButton("edithDebugModeTabEdith", "edithDebugModeJumpHeightButtonReset", "Reset", function(newVal)
			EdithRestored:SetDefaultDebugValue("JumpHeight")
			ImGui.UpdateData("edithDebugModeJumpHeight", ImGuiData.Value, EdithRestored:GetDebugValue("JumpHeight"))
		end, false)

		ImGui.AddSliderFloat("edithDebugModeTabEdith", "edithDebugModeJumpGravity", "Jump Gravity", function(newVal)
			EdithRestored:SetDebugValue("Gravity", newVal)
		end, EdithRestored:GetDebugValue("Gravity"), 0.1, 5, "%.2f")

		ImGui.AddButton("edithDebugModeTabEdith", "edithDebugModeJumpGravityButtonReset", "Reset", function(newVal)
			EdithRestored:SetDefaultDebugValue("Gravity")
			ImGui.UpdateData("edithDebugModeJumpGravity", ImGuiData.Value, EdithRestored:GetDebugValue("Gravity"))
		end, false)

		ImGui.AddSliderInteger(
			"edithDebugModeTabEdith",
			"edithDebugModeJumpLandingIFrames",
			"Post-landing i-frames",
			function(newVal)
				EdithRestored:SetDebugValue("IFrames", newVal)
			end,
			EdithRestored:GetDebugValue("IFrames"),
			1,
			300
		)

		ImGui.AddButton(
			"edithDebugModeTabEdith",
			"edithDebugModeJumpLandingIFramesButtonReset",
			"Reset",
			function(newVal)
				EdithRestored:SetDefaultDebugValue("IFrames")
				ImGui.UpdateData(
					"edithDebugModeJumpLandingIFrames",
					ImGuiData.Value,
					EdithRestored:GetDebugValue("IFrames")
				)
			end,
			false
		)

		ImGui.AddCheckbox(
			"edithDebugModeTabEdith",
			"edithDebugModeJumpLandingIFramesCheck",
			"Use debug i-frames",
			function(newVal)
				EdithRestored:SetDebugValue("UseIFrames", newVal)
			end,
			EdithRestored:GetDebugValue("UseIFrames")
		)

		ImGui.AddCheckbox(
			"edithDebugModeTabEdith",
			"edithDebugModeInstaJumpCharge",
			"Instant Jump Charge",
			function(newVal)
				EdithRestored:SetDebugValue("InstantJumpCharge", newVal)
			end,
			EdithRestored:GetDebugValue("InstantJumpCharge")
		)

		ImGui.AddCheckbox("edithDebugModeTabEdith", "edithDebugModeIgnoreStomp", "Ignore stomp damage", function(newVal)
			EdithRestored:SetDebugValue("IgnoreStompDamage", newVal)
		end, EdithRestored:GetDebugValue("IgnoreStompDamage"))

		ImGui.UpdateData("edithDebugModeStompRadius", ImGuiData.Value, EdithRestored:GetDebugValue("StompRadius"))
		ImGui.UpdateData(
			"edithDebugModeInstaJumpCharge",
			ImGuiData.Value,
			EdithRestored:GetDebugValue("InstantJumpCharge")
		)

		ImGui.UpdateData("edithDebugModeJumpHeight", ImGuiData.Value, EdithRestored:GetDebugValue("JumpHeight"))
		ImGui.UpdateData("edithDebugModeJumpGravity", ImGuiData.Value, EdithRestored:GetDebugValue("Gravity"))
		ImGui.UpdateData("edithDebugModeIgnoreStomp", ImGuiData.Value, EdithRestored:GetDebugValue("IgnoreStompDamage"))

		--#endregion

		--#region Peppermint specific
		ImGui.AddSliderInteger(
			"edithDebugModeTabPeppermintCloud",
			"edithDebugModePeppermintCharge",
			"Peppermint Max Charge",
			function(newVal)
				EdithRestored:SetDebugValue("PeppermintCharge", newVal)
			end,
			EdithRestored:GetDebugValue("PeppermintCharge"),
			1,
			210
		)

		ImGui.AddButton(
			"edithDebugModeTabPeppermintCloud",
			"edithDebugModePeppermintChargeReset",
			"Reset",
			function(newVal)
				EdithRestored:SetDefaultDebugValue("PeppermintCharge")
				ImGui.UpdateData(
					"edithDebugModePeppermintCharge",
					ImGuiData.Value,
					EdithRestored:GetDebugValue("PeppermintCharge")
				)
			end,
			false
		)

		ImGui.UpdateData(
			"edithDebugModePeppermintCharge",
			ImGuiData.Value,
			EdithRestored:GetDebugValue("PeppermintCharge")
		)

		ImGui.AddSliderInteger(
			"edithDebugModeTabPeppermintCloud",
			"edithDebugModePeppermintCloudSize",
			"Peppermint Cloud Size",
			function(newVal)
				EdithRestored:SetDebugValue("PeppermintCloudSize", newVal)
			end,
			EdithRestored:GetDebugValue("PeppermintCloudSize"),
			1,
			100
		)

		ImGui.AddButton(
			"edithDebugModeTabPeppermintCloud",
			"edithDebugModePeppermintCloudSizeReset",
			"Reset",
			function(newVal)
				EdithRestored:SetDefaultDebugValue("PeppermintCloudSize")
				ImGui.UpdateData(
					"edithDebugModePeppermintCloudSize",
					ImGuiData.Value,
					EdithRestored:GetDebugValue("PeppermintCloudSize")
				)
			end,
			false
		)
		ImGui.UpdateData(
			"edithDebugModePeppermintCloudSize",
			ImGuiData.Value,
			EdithRestored:GetDebugValue("PeppermintCloudSize")
		)

		ImGui.AddSliderInteger(
			"edithDebugModeTabPeppermintCloud",
			"edithDebugModePeppermintCloudPosOffsetX",
			"Peppermint Cloud Position X Offset",
			function(newVal)
				EdithRestored:SetDebugValue("PeppermintCloudPosOffsetX", newVal)
			end,
			EdithRestored:GetDebugValue("PeppermintCloudPosOffsetX"),
			-100,
			100
		)
		ImGui.UpdateData(
			"edithDebugModePeppermintCloudPosOffsetX",
			ImGuiData.Value,
			EdithRestored:GetDebugValue("PeppermintCloudPosOffsetX")
		)

		ImGui.AddSliderInteger(
			"edithDebugModeTabPeppermintCloud",
			"edithDebugModePeppermintCloudPosOffsetY",
			"Peppermint Cloud Position Y Offset",
			function(newVal)
				EdithRestored:SetDebugValue("PeppermintCloudPosOffsetY", newVal)
			end,
			EdithRestored:GetDebugValue("PeppermintCloudPosOffsetY"),
			-100,
			100
		)

		ImGui.AddButton(
			"edithDebugModeTabPeppermintCloud",
			"edithDebugModePeppermintCloudPosOffsetReset",
			"Reset",
			function(newVal)
				EdithRestored:SetDefaultDebugValue("PeppermintCloudPosOffsetX")
				EdithRestored:SetDefaultDebugValue("PeppermintCloudPosOffsetY")
				ImGui.UpdateData(
					"edithDebugModePeppermintCloudPosOffsetX",
					ImGuiData.Value,
					EdithRestored:GetDebugValue("PeppermintCloudPosOffsetX")
				)
				ImGui.UpdateData(
					"edithDebugModePeppermintCloudPosOffsetY",
					ImGuiData.Value,
					EdithRestored:GetDebugValue("PeppermintCloudPosOffsetY")
				)
			end,
			false
		)
		ImGui.UpdateData(
			"edithDebugModePeppermintCloudPosOffsetY",
			ImGuiData.Value,
			EdithRestored:GetDebugValue("PeppermintCloudPosOffsetY")
		)

		ImGui.AddSliderFloat(
			"edithDebugModeTabPeppermintCloud",
			"edithDebugModePeppermintCloudSizeXMult",
			"Peppermint Cloud Position X Offset",
			function(newVal)
				EdithRestored:SetDebugValue("PeppermintCloudSizeXMult", newVal)
			end,
			EdithRestored:GetDebugValue("PeppermintCloudSizeXMult"),
			0.1,
			5
		)
		ImGui.UpdateData(
			"edithDebugModePeppermintCloudSizeXMult",
			ImGuiData.Value,
			EdithRestored:GetDebugValue("PeppermintCloudSizeXMult")
		)

		ImGui.AddSliderFloat(
			"edithDebugModeTabPeppermintCloud",
			"edithDebugModePeppermintCloudSizeYMult",
			"Peppermint Cloud Position Y Offset",
			function(newVal)
				EdithRestored:SetDebugValue("PeppermintCloudSizeYMult", newVal)
			end,
			EdithRestored:GetDebugValue("PeppermintCloudSizeYMult"),
			0.1,
			5
		)

		ImGui.AddButton(
			"edithDebugModeTabPeppermintCloud",
			"edithDebugModePeppermintCloudSizeMultReset",
			"Reset",
			function(newVal)
				EdithRestored:SetDefaultDebugValue("PeppermintCloudSizeXMult")
				EdithRestored:SetDefaultDebugValue("PeppermintCloudPosOffsetY")
				ImGui.UpdateData(
					"edithDebugModePeppermintCloudSizeXMult",
					ImGuiData.Value,
					EdithRestored:GetDebugValue("PeppermintCloudSizeXMult")
				)
				ImGui.UpdateData(
					"edithDebugModePeppermintCloudSizeYMult",
					ImGuiData.Value,
					EdithRestored:GetDebugValue("PeppermintCloudSizeYMult")
				)
			end,
			false
		)
		ImGui.UpdateData(
			"edithDebugModePeppermintCloudSizeYMult",
			ImGuiData.Value,
			EdithRestored:GetDebugValue("PeppermintCloudSizeYMult")
		)

		--#endregion

		--#region Misc specific
		ImGui.AddSliderInteger(
			"edithDebugModeTabMisc",
			"edithDebugModeBlastingBootsCd",
			"Blasting Boots cooldown",
			function(newVal)
				EdithRestored:SetDebugValue("BlastingBootsCd", newVal)
			end,
			EdithRestored:GetDebugValue("BlastingBootsCd"),
			30,
			150
		)

		ImGui.AddButton("edithDebugModeTabMisc", "edithDebugModeBlastingBootsCdReset", "Reset", function(newVal)
			EdithRestored:SetDefaultDebugValue("BlastingBootsCd")
			ImGui.UpdateData(
				"edithDebugModeBlastingBootsCd",
				ImGuiData.Value,
				EdithRestored:GetDebugValue("BlastingBootsCd")
			)
		end, false)
		ImGui.UpdateData(
			"edithDebugModeBlastingBootsCd",
			ImGuiData.Value,
			EdithRestored:GetDebugValue("BlastingBootsCd")
		)

		ImGui.AddCheckbox(
			"edithDebugModeTabMisc",
			"edithDebugModeBlastingBootsDisable",
			"Disable Blasting Boots cooldown",
			function(newVal)
				EdithRestored:SetDebugValue("BlastingBootsDisable", newVal)
			end,
			EdithRestored:GetDebugValue("BlastingBootsDisable")
		)
		ImGui.UpdateData(
			"edithDebugModeBlastingBootsDisable",
			ImGuiData.Value,
			EdithRestored:GetDebugValue("BlastingBootsDisable")
		)
		--#endregion

		--#region Red Hood specific

		RedMoonSilder(EdithRestored.SaveManager.IsLoaded())
		--#endregion
		ImGui.SetVisible("edithWindowDebugModeSettings", true)
	else
		if ImGui.ElementExists("edithDebugModeSettings") then
			ImGui.RemoveElement("edithDebugModeSettings")
		end
		if ImGui.ElementExists("edithWindowDebugModeSettings") then
			ImGui.RemoveWindow("edithWindowDebugModeSettings")
		end
	end
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

	local marksA = EdithRestored.Enums.Achievements.Unlocks.ASide
	local marksB = EdithRestored.Enums.Achievements.Unlocks.BSide

	local challenges = EdithRestored.Enums.Achievements.Unlocks.Challenges

	local function LockAchievementA(id)
		if type(id) == "number" then
			Isaac.ExecuteCommand("lockachievement " .. id)
		end
	end

	local function UnLockAchievementA(id)
		if type(id) == "number" then
			if not pgd:Unlocked(id) then
				Isaac.ExecuteCommand("achievement " .. id)
			end
		end
	end

	local function SetHelpMarker(tab, func, ach, elem)
		for _, item in pairs(tab) do
			local conf = func(itemConfig, item)
			if conf then
				if conf.AchievementID > 0 and ach and ach == conf.AchievementID then
					ImGui.SetHelpmarker(elem, "Unlocks " .. RemoveZeroWidthSpace(conf.Name))
					break
				end
			end
		end
	end

	if ImGui.ElementExists("edithMarks") then
		ImGui.RemoveElement("edithMarks")
	end

	ImGui.AddTabBar("edithWindowUnlocks", "edithMarks")
	--#region Edith unlocks
	ImGui.AddTab("edithMarks", "edithUnlocksA", "Edith")
	ImGui.AddTab("edithMarks", "edithUnlocksB", "Tainted Edith")

	if ImGui.ElementExists("edithMarksBTainted") then
		ImGui.RemoveElement("edithMarksBTainted")
	end
	ImGui.AddCombobox("edithUnlocksB", "edithMarksBTainted", "Tainted Edith", function(index, val)
		if index == 1 then
			UnLockAchievementA(EdithRestored.Enums.Achievements.Characters.TAINTED)
		else
			LockAchievementA(EdithRestored.Enums.Achievements.Characters.TAINTED)
		end
		UpdateBlackListMenu()
	end, { "Locked", "Unlocked" }, 0, true)
	ImGui.AddCallback("edithMarksBTainted", ImGuiCallback.Render, function()
		ImGui.UpdateData(
			"edithMarksBTainted",
			ImGuiData.Value,
			pgd:Unlocked(EdithRestored.Enums.Achievements.Characters.TAINTED) and 1 or 0
		)
	end)

	for tab, prefix in pairs({ ["edithUnlocksA"] = "edithMarksA", ["edithUnlocksB"] = "edithMarksB" }) do
		local pType = prefix == "edithMarksA" and EdithRestored.Enums.PlayerType.EDITH
			or EdithRestored.Enums.PlayerType.EDITH_B
		local achievements = prefix == "edithMarksA" and marksA or marksB
		for ach, data in pairs(achievements) do
			if data.Name ~= nil and data.Difficulty ~= nil and ach > 0 then
				if ImGui.ElementExists(prefix .. data.Name) then
					ImGui.RemoveElement(prefix .. data.Name)
				end
				ImGui.AddCombobox(tab, prefix .. data.Name, data.Name, function(index, val)
					if index == 1 then
						for _, mark in pairs(data.Marks) do
							local diff = data.Difficulty ~= nil and data.Difficulty or 2
							Isaac.SetCompletionMark(pType, mark, math.max(diff, Isaac.GetCompletionMark(pType, mark)))
						end
						UnLockAchievementA(ach)
					else
						for _, mark in pairs(data.Marks) do
							Isaac.SetCompletionMark(pType, mark, 0)
						end
						LockAchievementA(ach)
					end
					if data.Function then
						data.Function(index)
					end
					UpdateBlackListMenu()
				end, { "Locked", "Unlocked" }, 0, true)
				ImGui.AddCallback(prefix .. data.Name, ImGuiCallback.Render, function()
					ImGui.UpdateData(prefix .. data.Name, ImGuiData.Value, pgd:Unlocked(ach) and 1 or 0)
				end)

				SetHelpMarker(EdithRestored.Enums.CollectibleType, itemConfig.GetCollectible, ach, prefix .. data.Name)
				SetHelpMarker(EdithRestored.Enums.TrinketType, itemConfig.GetTrinket, ach, prefix .. data.Name)
				SetHelpMarker(EdithRestored.Enums.Pickups.Cards, itemConfig.GetCard, ach, prefix .. data.Name)
				if data.ExtraData then
					data.ExtraData(prefix .. data.Name)
				end
			end
		end
	end

	--ImGui.SetTooltip()

	ImGui.AddCombobox("edithUnlocksA", "edithMarksAAll", "All Marks", function(index, val)
		if index < 1 then
			Isaac.ExecuteCommand("lockachievement " .. EdithRestored.Enums.Achievements.CompletionMarks.PRUDENCE)
		elseif not pgd:Unlocked(EdithRestored.Enums.Achievements.CompletionMarks.PRUDENCE) then
			for key, val in pairs(marksA) do
				if not pgd:Unlocked(key) then
					Isaac.ExecuteCommand("achievement " .. key)
				end
				for _, mark in pairs(val.Marks) do
					Isaac.SetCompletionMark(EdithRestored.Enums.PlayerType.EDITH, mark, 2)
				end
			end
			Isaac.ExecuteCommand("achievement " .. EdithRestored.Enums.Achievements.CompletionMarks.PRUDENCE)
		end
		UpdateBlackListMenu()
	end, { "Locked", "Unlocked" }, 0, true)

	ImGui.AddCallback("edithMarksAAll", ImGuiCallback.Render, function()
		local unlocked = pgd:Unlocked(EdithRestored.Enums.Achievements.CompletionMarks.PRUDENCE)
		ImGui.UpdateData("edithMarksAAll", ImGuiData.Value, unlocked and 1 or 0)
	end)

	local cardConf = itemConfig:GetCard(EdithRestored.Enums.Pickups.Cards.CARD_PRUDENCE)
	if cardConf then
		ImGui.SetHelpmarker("edithMarksAAll", "Unlocks " .. RemoveZeroWidthSpace(cardConf.Name))
	end
	--#endregion

	--#region Challenges unlocks
	ImGui.AddTab("edithMarks", "edithChallenges", "Challenges")

	for key, val in pairs(challenges) do
		if ImGui.ElementExists("edithChallenge" .. val.Name) then
			ImGui.RemoveElement("edithChallenge" .. val.Name)
		end

		ImGui.AddCombobox("edithChallenges", "edithChallenge" .. val.Name, val.Name, function(index, value)
			if index == 0 then
				Isaac.ExecuteCommand("lockachievement " .. key)
			end
			if index > 0 then
				if not pgd:Unlocked(key) then
					Isaac.ExecuteCommand("achievement " .. key)
				end
			end
			if val.Function then
				val.Function(index)
			end
			UpdateBlackListMenu()
		end, { "Locked", "Unlocked" }, 0, true)

		ImGui.AddCallback("edithChallenge" .. val.Name, ImGuiCallback.Render, function()
			ImGui.UpdateData("edithChallenge" .. val.Name, ImGuiData.Value, pgd:Unlocked(key) and 1 or 0)
		end)

		SetHelpMarker(EdithRestored.Enums.CollectibleType, itemConfig.GetCollectible, key, "edithChallenge" .. val.Name)
		SetHelpMarker(EdithRestored.Enums.TrinketType, itemConfig.GetTrinket, key, "edithChallenge" .. val.Name)
		SetHelpMarker(EdithRestored.Enums.Pickups.Cards, itemConfig.GetCard, key, "edithChallenge" .. val.Name)
		if val.ExtraData then
			val.ExtraData("edithChallenge" .. val.Name)
		end
	end
	--#endregion

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
UpdateDebugMode()

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

EdithRestored:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, 1000, function()
	RedMoonSilder(EdithRestored.SaveManager.IsLoaded())
end)

EdithRestored:AddPriorityCallback(ModCallbacks.MC_PRE_GAME_EXIT, -1000, function()
	RedMoonSilder(false)
end)

EdithRestored:AddCallback(ModCallbacks.MC_EXECUTE_CMD, function(_, cmd, args)
	if cmd == "edithdebug" then
		if args == "enable" then
			EdithRestored.DebugMode = true
			EdithRestored:Log("Edith Debug Mode is enabled.", true)
			UpdateDebugMode()
		elseif args == "disable" then
			EdithRestored.DebugMode = false
			EdithRestored:Log("Edith Debug Mode is disabled.", true)
			UpdateDebugMode()
		end
	end
end)
